import AppKit

/// Polls the open tabs of Chrome and Safari via Apple Events and redirects any tab
/// showing a blocked site to the local "shield is on" page.
final class BrowserBlocker {
    struct Browser {
        let name: String
        let bundleID: String
    }

    static let browsers = [
        Browser(name: "Google Chrome", bundleID: "com.google.Chrome"),
        Browser(name: "Safari", bundleID: "com.apple.Safari"),
    ]

    /// Browsers that refused Automation permission (error -1743). Read on the main thread.
    private(set) var deniedBrowsers: Set<String> = []
    var onPermissionChange: (() -> Void)?

    private let queue = DispatchQueue(label: "focusshield.blocker")
    private var timer: Timer?
    private var inFlight = false
    private var listScripts: [String: NSAppleScript] = [:]  // touched only on `queue`

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.75, repeats: true) { [weak self] _ in
            self?.tick()
        }
        timer?.tolerance = 0.1
    }

    private func tick() {
        guard ShieldState.shared.isBlocking, !inFlight else { return }
        let running = Self.browsers.filter {
            !NSRunningApplication.runningApplications(withBundleIdentifier: $0.bundleID).isEmpty
        }
        guard !running.isEmpty else { return }

        inFlight = true
        queue.async { [weak self] in
            guard let self else { return }
            var denied: Set<String> = []
            for browser in running where self.sweep(browser) == .denied {
                denied.insert(browser.name)
            }
            DispatchQueue.main.async {
                self.inFlight = false
                // Only browsers we actually checked can change state.
                let checked = Set(running.map(\.name))
                let updated = self.deniedBrowsers.subtracting(checked).union(denied)
                if updated != self.deniedBrowsers {
                    self.deniedBrowsers = updated
                    self.onPermissionChange?()
                }
            }
        }
    }

    private enum SweepResult { case ok, denied, failed }

    private func sweep(_ browser: Browser) -> SweepResult {
        let script = listScript(for: browser)
        var error: NSDictionary?
        let result = script.executeAndReturnError(&error)
        if let error {
            let code = error[NSAppleScript.errorNumber] as? Int ?? 0
            return code == -1743 ? .denied : .failed
        }
        guard let text = result.stringValue, !text.isEmpty else { return .ok }

        for line in text.split(separator: "\n") {
            let parts = line.split(separator: "\t", maxSplits: 2).map(String.init)
            guard parts.count == 3, let w = Int(parts[0]), let t = Int(parts[1]) else { continue }
            let url = parts[2]
            if BlockList.isBlocked(url) {
                redirect(browser, window: w, tab: t, blockedURL: url)
            }
        }
        return .ok
    }

    private func listScript(for browser: Browser) -> NSAppleScript {
        if let cached = listScripts[browser.bundleID] { return cached }
        let source = """
        set sep to character id 9
        set out to {}
        tell application id "\(browser.bundleID)"
            set n to count of windows
            repeat with i from 1 to n
                try
                    set urls to URL of tabs of window i
                    repeat with j from 1 to count of urls
                        set u to item j of urls
                        if u is not missing value then set end of out to (i as text) & sep & (j as text) & sep & u
                    end repeat
                end try
            end repeat
        end tell
        set AppleScript's text item delimiters to linefeed
        return out as text
        """
        let script = NSAppleScript(source: source)!
        script.compileAndReturnError(nil)
        listScripts[browser.bundleID] = script
        return script
    }

    private func redirect(_ browser: Browser, window: Int, tab: Int, blockedURL: String) {
        let target = BlockedPage.url(for: BlockList.displayHost(blockedURL)).absoluteString
            .replacingOccurrences(of: "\"", with: "%22")
        let source = """
        tell application id "\(browser.bundleID)" to set URL of tab \(tab) of window \(window) to "\(target)"
        """
        var error: NSDictionary?
        NSAppleScript(source: source)?.executeAndReturnError(&error)
    }
}
