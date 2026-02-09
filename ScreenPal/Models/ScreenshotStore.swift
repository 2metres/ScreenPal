import Foundation
import AppKit
import Combine

class ScreenshotStore: ObservableObject {
    @Published var screenshots: [Screenshot] = []

    private var screenshotDirectory: URL
    private var fileWatcher: DispatchSourceFileSystemObject?

    init(directory: URL? = nil) {
        if let directory = directory {
            screenshotDirectory = directory
        } else {
            screenshotDirectory = ScreenshotDirectoryManager().directoryURL
        }
        loadScreenshots()
        startWatching()
    }

    func updateDirectory(_ newDirectory: URL) {
        stopWatching()
        screenshotDirectory = newDirectory
        screenshots = []
        loadScreenshots()
        startWatching()
    }

    func loadScreenshots() {
        let fileManager = FileManager.default

        do {
            let files = try fileManager.contentsOfDirectory(at: screenshotDirectory, includingPropertiesForKeys: [.creationDateKey])

            var loaded = files
                .filter { $0.pathExtension.lowercased() == "png" && $0.lastPathComponent.contains("Screenshot") }
                .map { Screenshot(url: $0) }
                .sorted { $0.createdAt > $1.createdAt }
                .prefix(30)
                .map { $0 }

            for i in loaded.indices {
                loaded[i].image = NSImage(contentsOf: loaded[i].url)
            }

            screenshots = loaded
        } catch {
            print("Error loading screenshots: \(error)")
        }
    }

    private func startWatching() {
        let fd = open(screenshotDirectory.path, O_EVTONLY)
        guard fd != -1 else { return }

        fileWatcher = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fd, eventMask: .write, queue: .main)

        fileWatcher?.setEventHandler { [weak self] in
            self?.loadScreenshots()
        }

        fileWatcher?.setCancelHandler {
            close(fd)
        }

        fileWatcher?.resume()
    }

    private func stopWatching() {
        fileWatcher?.cancel()
        fileWatcher = nil
    }

    deinit {
        stopWatching()
    }
}
