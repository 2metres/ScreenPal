import Cocoa
import SwiftUI

extension Notification.Name {
    static let popoverDidClose = Notification.Name("popoverDidClose")
}

class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var statusMenu: NSMenu?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "photo.on.rectangle", accessibilityDescription: "Screenshots")
            button.action = #selector(togglePopover)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit ScreenPal", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem?.menu = nil
        self.statusMenu = menu

        popover = NSPopover()
        popover?.contentSize = NSSize(width: 320, height: 400)
        popover?.behavior = .transient
        popover?.delegate = self
        popover?.contentViewController = NSHostingController(rootView: MenubarPopover())
    }

    @objc func togglePopover() {
        guard let button = statusItem?.button else { return }
        let event = NSApp.currentEvent

        if event?.type == .rightMouseUp {
            popover?.performClose(nil)
            statusItem?.menu = statusMenu
            button.performClick(nil)
            statusItem?.menu = nil
            return
        }

        guard let popover = popover else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    func popoverDidClose(_ notification: Notification) {
        NotificationCenter.default.post(name: .popoverDidClose, object: nil)
    }
}
