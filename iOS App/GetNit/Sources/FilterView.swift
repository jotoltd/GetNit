import SwiftUI
import Photos

struct FilterView: View {
    @ObservedObject var manager: PhotoLibraryManager
    @Environment(\.dismiss) var dismiss

    @State private var screenshotsOnly: Bool
    @State private var selectedAlbumIndex: Int
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var useStartDate: Bool
    @State private var useEndDate: Bool
    @State private var rememberReviewed: Bool

    init(manager: PhotoLibraryManager) {
        self.manager = manager
        _screenshotsOnly = State(initialValue: manager.filters.screenshotsOnly)
        _selectedAlbumIndex = State(initialValue: manager.filters.album == nil ? 0 : (manager.albums.firstIndex(of: manager.filters.album!) ?? 0) + 1)
        _startDate = State(initialValue: manager.filters.startDate ?? Date().addingTimeInterval(-30 * 24 * 3600))
        _endDate = State(initialValue: manager.filters.endDate ?? Date())
        _useStartDate = State(initialValue: manager.filters.startDate != nil)
        _useEndDate = State(initialValue: manager.filters.endDate != nil)
        _rememberReviewed = State(initialValue: manager.rememberReviewed)
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Album") {
                    Picker("Source", selection: $selectedAlbumIndex) {
                        Text("All Photos").tag(0)
                        ForEach(Array(manager.albums.enumerated()), id: \.offset) { idx, album in
                            Text(album.localizedTitle ?? "Unknown").tag(idx + 1)
                        }
                    }
                }

                Section("Type") {
                    Toggle("Screenshots Only", isOn: $screenshotsOnly)
                }

                Section("Date Range") {
                    Toggle("From", isOn: $useStartDate)
                    if useStartDate {
                        DatePicker("Start Date", selection: $startDate, in: ...endDate, displayedComponents: .date)
                    }
                    Toggle("Until", isOn: $useEndDate)
                    if useEndDate {
                        DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
                    }
                }

                Section("Review History") {
                    Toggle("Remember Reviewed Photos", isOn: $rememberReviewed)
                    Button("Clear Review History") {
                        manager.clearReviewHistory()
                        dismiss()
                    }
                    .foregroundColor(.red)
                }

                Section {
                    Button("Apply Filters") {
                        applyFilters()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func applyFilters() {
        manager.setRememberReviewed(rememberReviewed)
        manager.filters.screenshotsOnly = screenshotsOnly
        manager.filters.album = selectedAlbumIndex == 0 ? nil : manager.albums[selectedAlbumIndex - 1]
        manager.filters.startDate = useStartDate ? startDate : nil
        manager.filters.endDate = useEndDate ? endDate : nil
        manager.loadAssets()
    }
}
