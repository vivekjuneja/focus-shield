import AppKit
import ServiceManagement
import SwiftUI
import UserNotifications

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate, NSWindowDelegate {
    private let state = ShieldState.shared
    private let blocker = BrowserBlocker()
    private var statusItem: NSStatusItem!
    private var clock: Timer?
    private var persuasionWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        BlockedPage.install()

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let menu = NSMenu()
        menu.delegate = self
        statusItem.menu = menu

        blocker.onPermissionChange = { [weak self] in self?.refreshStatusButton() }
        blocker.start()

        clock = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in self?.tickClock() }
        tickClock()

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    // MARK: Status item

    private func tickClock() {
        if let until = state.pausedUntil, Date() >= until {
            state.resume()
            notify(title: "Focus Shield is back on", body: "Break's over. YouTube, Netflix, X, Instagram, LinkedIn and Prime Video are blocked again.")
        }
        refreshStatusButton()
    }

    private func refreshStatusButton() {
        guard let button = statusItem.button else { return }
        let blocking = state.isBlocking
        let symbol = blocking ? "shield.lefthalf.filled" : "shield.slash"
        button.image = NSImage(systemSymbolName: symbol, accessibilityDescription: "Focus Shield")
        button.image?.isTemplate = true
        button.imagePosition = .imageLeading

        if !blocking {
            button.title = " " + Self.format(state.remainingPause)
            button.font = .monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        } else if !blocker.deniedBrowsers.isEmpty {
            button.title = " !"
        } else {
            button.title = ""
        }
    }

    private static func format(_ interval: TimeInterval) -> String {
        let total = Int(interval.rounded(.up))
        return String(format: "%d:%02d", total / 60, total % 60)
    }

    // MARK: Menu

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()

        if state.isBlocking {
            menu.addItem(disabledItem("🛡️  Shield is ON"))
            menu.addItem(disabledItem("Blocking YouTube, Netflix, X, Instagram, LinkedIn and Prime Video"))
            menu.addItem(.separator())
            menu.addItem(item("Pause the Shield…", #selector(beginDisable)))
        } else {
            menu.addItem(disabledItem("⏸  Shield paused — back on in \(Self.format(state.remainingPause))"))
            menu.addItem(.separator())
            menu.addItem(item("Turn the Shield Back On Now", #selector(resumeNow)))
        }

        for name in blocker.deniedBrowsers.sorted() {
            menu.addItem(.separator())
            menu.addItem(disabledItem("⚠️  Can't control \(name)"))
            menu.addItem(item("Grant Automation Access…", #selector(openAutomationSettings)))
        }

        menu.addItem(.separator())
        let login = item("Launch at Login", #selector(toggleLaunchAtLogin))
        login.state = SMAppService.mainApp.status == .enabled ? .on : .off
        menu.addItem(login)

        // Quitting would bypass the shield, so it's only offered while paused.
        if !state.isBlocking {
            menu.addItem(item("Quit Focus Shield", #selector(quit)))
        }
    }

    private func item(_ title: String, _ action: Selector) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        return item
    }

    private func disabledItem(_ title: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.isEnabled = false
        return item
    }

    // MARK: Actions

    @objc private func beginDisable() {
        if let window = persuasionWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let view = PersuasionView(
            facts: FactLibrary.pickUnique(3),
            onStayFocused: { [weak self] in self?.closePersuasion() },
            onPause: { [weak self] minutes in
                self?.state.pause(minutes: minutes)
                self?.refreshStatusButton()
                self?.closePersuasion()
            })

        let window = NSWindow(contentViewController: NSHostingController(rootView: view))
        window.styleMask = [.titled, .closable, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.level = .floating
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.center()
        persuasionWindow = window

        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    private func closePersuasion() {
        persuasionWindow?.close()
    }

    func windowWillClose(_ notification: Notification) {
        if (notification.object as? NSWindow) === persuasionWindow {
            persuasionWindow = nil
        }
    }

    @objc private func resumeNow() {
        state.resume()
        refreshStatusButton()
    }

    @objc private func toggleLaunchAtLogin() {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            let alert = NSAlert()
            alert.messageText = "Couldn't change Launch at Login"
            alert.informativeText = "\(error.localizedDescription)\n\nMove Focus Shield to /Applications and try again."
            NSApp.activate(ignoringOtherApps: true)
            alert.runModal()
        }
    }

    @objc private func openAutomationSettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation")!
        NSWorkspace.shared.open(url)
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    private func notify(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
