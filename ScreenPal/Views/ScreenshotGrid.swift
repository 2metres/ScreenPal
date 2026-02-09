import SwiftUI

struct ScreenshotGrid: View {
    let screenshots: [Screenshot]
    let thumbnails: [URL: NSImage]
    @Binding var selectedID: UUID?
    var columnCount: Int = 3

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible()), count: columnCount)
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(screenshots) { screenshot in
                ScreenshotThumbnail(
                    screenshot: screenshot,
                    thumbnail: thumbnails[screenshot.url],
                    isSelected: selectedID == screenshot.id,
                    columnCount: columnCount,
                    onSelect: { selectedID = screenshot.id }
                )
                .id(screenshot.id)
            }
        }
    }
}
