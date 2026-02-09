import SwiftUI

struct MenubarPopover: View {
    @StateObject private var directoryManager = ScreenshotDirectoryManager()
    @StateObject private var store = ScreenshotStore()
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 0) {
            if showSettings {
                // Settings pane
                HStack {
                    Button(action: { showSettings = false }) {
                        Image(systemName: "chevron.left")
                    }
                    .buttonStyle(.borderless)
                    Text("Settings")
                        .font(.headline)
                    Spacer()
                }
                .padding()

                Divider()

                SettingsView(directoryManager: directoryManager) { newURL in
                    store.updateDirectory(newURL)
                }

                Spacer()
            } else {
                // Main pane
                HStack {
                    Text("Screenshots")
                        .font(.headline)
                    Spacer()
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape")
                    }
                    .buttonStyle(.borderless)

                    Button(action: { store.loadScreenshots() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.borderless)
                }
                .padding()

                Divider()

                if store.screenshots.isEmpty {
                    VStack {
                        Spacer()
                        Text("No screenshots found")
                            .foregroundColor(.secondary)
                        Text("Take a screenshot with \u{2318}\u{21E7}3 or \u{2318}\u{21E7}4")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        ScreenshotGrid(screenshots: store.screenshots)
                            .padding()
                    }
                }
            }
        }
        .frame(width: 320, height: 400)
        .onReceive(NotificationCenter.default.publisher(for: .popoverDidClose)) { _ in
            showSettings = false
        }
    }
}
