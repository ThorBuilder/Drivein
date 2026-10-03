import UIKit

enum AppLauncher {
    /// Opens the installed app. Returns false when it isn't installed.
    @MainActor
    static func open(_ app: StreamingApp) async -> Bool {
        for link in app.universalLinks {
            guard let url = URL(string: link) else { continue }
            if await UIApplication.shared.open(url, options: [.universalLinksOnly: true]) {
                return true
            }
        }
        for scheme in app.schemes {
            guard let url = URL(string: scheme), UIApplication.shared.canOpenURL(url) else { continue }
            if await UIApplication.shared.open(url) {
                return true
            }
        }
        return false
    }

    @MainActor
    static func openURL(_ url: URL?) {
        guard let url else { return }
        UIApplication.shared.open(url)
    }

    @MainActor
    static func openSettings() {
        openURL(URL(string: UIApplication.openSettingsURLString))
    }
}
