import SwiftUI
import AppKit

struct SettingsView: View {
    @ObservedObject var directoryManager: ScreenshotDirectoryManager
    var onDirectoryChanged: (URL) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Screenshot Folder")
                .font(.subheadline)
                .fontWeight(.medium)

            Text(directoryManager.displayPath)
                .font(.system(.caption, design: .monospaced))
                .padding(6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(4)

            if directoryManager.source == .osDefault {
                Text("Detected from macOS settings")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            HStack {
                Button("Choose Folder...") {
                    chooseFolder()
                }

                if directoryManager.source == .custom {
                    Button("Reset to Default") {
                        directoryManager.resetToOSDefault()
                        onDirectoryChanged(directoryManager.directoryURL)
                    }
                }
            }
        }
        .padding()
    }

    private func chooseFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.level = .floating
        panel.prompt = "Choose"

        if panel.runModal() == .OK, let url = panel.url {
            directoryManager.setCustomDirectory(url)
            onDirectoryChanged(url)
        }
    }
}
