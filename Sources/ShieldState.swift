import Foundation

/// Persisted on/off state. The shield is always on unless a timed pause is running.
final class ShieldState {
    static let shared = ShieldState()

    private let defaults = UserDefaults.standard
    private let pausedUntilKey = "pausedUntil"

    var pausedUntil: Date? {
        get { defaults.object(forKey: pausedUntilKey) as? Date }
        set { defaults.set(newValue, forKey: pausedUntilKey) }
    }

    var isBlocking: Bool {
        guard let until = pausedUntil else { return true }
        return Date() >= until
    }

    var remainingPause: TimeInterval {
        guard let until = pausedUntil else { return 0 }
        return max(0, until.timeIntervalSinceNow)
    }

    func pause(minutes: Int) {
        pausedUntil = Date().addingTimeInterval(TimeInterval(minutes * 60))
    }

    func resume() {
        pausedUntil = nil
    }
}

enum BlockList {
    static let domains = [
        "youtube.com", "youtu.be", "youtube-nocookie.com",
        "netflix.com",
        "x.com", "twitter.com", "t.co",
        "instagram.com", "instagr.am",
        "linkedin.com", "lnkd.in",
        "primevideo.com",
    ]

    /// Prime Video also lives under amazon.<tld>; only the video paths are blocked
    /// so regular shopping still works.
    static let amazonVideoPaths = ["/gp/video", "/prime-video", "/amazon-video", "/primevideo"]

    static func isBlocked(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString),
              let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https",
              let host = url.host?.lowercased() else { return false }

        if domains.contains(where: { host == $0 || host.hasSuffix("." + $0) }) {
            return true
        }
        let labels = host.split(separator: ".")
        if labels.contains("amazon") {
            let path = url.path.lowercased()
            return amazonVideoPaths.contains { path.hasPrefix($0) }
        }
        return false
    }

    static func displayHost(_ urlString: String) -> String {
        guard let host = URL(string: urlString)?.host?.lowercased() else { return "This site" }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }
}
