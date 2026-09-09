#!/usr/bin/env python3
"""
GetNit App Store Review Monitor
Checks review status every 5 minutes and alerts when it changes.
"""
import jwt
import time
import requests
import json
import subprocess
import sys
from datetime import datetime

KEY_ID = "GC93JBVR9N"
ISSUER_ID = "685c0558-b91d-4ee4-947c-c7915cad849f"
KEY_FILE = "/Users/digitalgaff/.appstoreconnect/private_keys/AuthKey_GC93JBVR9N.p8"
APP_ID = "6810416446"
VERSION_ID = "f633e29f-d8d3-4379-a0a0-7277cc03810c"
CHECK_INTERVAL = 300  # 5 minutes

with open(KEY_FILE, "r") as f:
    private_key = f.read()

def make_token():
    payload = {"iss": ISSUER_ID, "iat": int(time.time()), "exp": int(time.time()) + 1200, "aud": "appstoreconnect-v1"}
    headers = {"alg": "ES256", "kid": KEY_ID, "typ": "JWT"}
    return jwt.encode(payload, private_key, algorithm="ES256", headers=headers)

def check_status():
    token = make_token()
    headers = {"Authorization": f"Bearer {token}"}
    
    # Check version status
    r = requests.get(f"https://api.appstoreconnect.apple.com/v1/appStoreVersions/{VERSION_ID}", headers=headers)
    if r.status_code != 200:
        return None, None, None
    
    attrs = r.json()["data"]["attributes"]
    state = attrs.get("appStoreState")
    
    # Check review submission
    r2 = requests.get(f"https://api.appstoreconnect.apple.com/v1/apps/{APP_ID}/reviewSubmissions", headers=headers)
    submission_state = None
    if r2.status_code == 200:
        for s in r2.json().get("data", []):
            submission_state = s["attributes"].get("state")
    
    # Check for rejection info
    rejection_info = None
    if state == "REJECTED":
        r3 = requests.get(f"https://api.appstoreconnect.apple.com/v1/appStoreVersions/{VERSION_ID}/appStoreVersionSubmissions", headers=headers)
        if r3.status_code == 200:
            rejection_info = r3.json()
    
    return state, submission_state, rejection_info

def notify(title, message):
    """Send a macOS notification"""
    subprocess.run([
        "osascript", "-e",
        f'display notification "{message}" with title "{title}" sound name "Glass"'
    ])
    # Also print to console
    print(f"\n{'='*50}")
    print(f"  {title}")
    print(f"  {message}")
    print(f"{'='*50}\n")

def main():
    print(f"GetNit Review Monitor - Started at {datetime.now().strftime('%H:%M:%S')}")
    print(f"Checking every {CHECK_INTERVAL}s ({CHECK_INTERVAL//60} min)")
    print(f"Press Ctrl+C to stop\n")
    print(f"{'='*50}")
    
    last_state = None
    check_count = 0
    
    while True:
        try:
            state, submission_state, rejection_info = check_status()
            now = datetime.now().strftime("%H:%M:%S")
            check_count += 1
            
            if state:
                status_line = f"[{now}] Check #{check_count} | Version: {state} | Submission: {submission_state or 'N/A'}"
                print(status_line)
                
                # State changed?
                if last_state and state != last_state:
                    if state == "READY_FOR_SALE":
                        notify("GetNit APPROVED!", "Your app is now available on the App Store!")
                    elif state == "REJECTED":
                        notify("GetNit Rejected", "Check App Store Connect for rejection details")
                    elif state == "IN_REVIEW":
                        notify("GetNit In Review", "Apple is now reviewing your app")
                    elif state == "DEVELOPER_REJECTED":
                        notify("GetNit Removed", "You removed the app from review")
                    else:
                        notify("GetNit Status Changed", f"New state: {state}")
                
                last_state = state
            else:
                print(f"[{now}] Check #{check_count} | Failed to get status")
            
            time.sleep(CHECK_INTERVAL)
            
        except KeyboardInterrupt:
            print("\n\nMonitoring stopped. Goodbye!")
            sys.exit(0)
        except Exception as e:
            print(f"[{datetime.now().strftime('%H:%M:%S')}] Error: {e}")
            time.sleep(CHECK_INTERVAL)

if __name__ == "__main__":
    main()
