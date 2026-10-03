import SwiftUI
import WebKit

/// Lets the toolbar drive the web view (back, reload).
@MainActor
final class WebController: ObservableObject {
    weak var webView: WKWebView?
    @Published var canGoBack = false
    @Published var isLoading = false

    func goBack() { webView?.goBack() }
    func reload() { webView?.reload() }
}

/// Plays a streaming service inside DriveIn. When the car moves, the picture is covered
/// (and optionally paused) so only the sound continues.
struct PlayerScreen: View {
    let app: StreamingApp

    @EnvironmentObject private var drive: DriveMonitor
    @Environment(\.dismiss) private var dismiss
    @AppStorage("keepAudioWhileDriving") private var keepAudioWhileDriving = true
    @StateObject private var web = WebController()
    @State private var desktop: Bool

    init(app: StreamingApp) {
        self.app = app
        let saved = UserDefaults.standard.object(forKey: "desktop.\(app.id)") as? Bool
        _desktop = State(initialValue: saved ?? app.desktopSite)
    }

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            ZStack {
                WebPlayer(
                    url: URL(string: app.webURL) ?? URL(string: "https://m.youtube.com")!,
                    desktop: desktop,
                    locked: !drive.videoUnlocked,
                    pauseWhenLocked: !keepAudioWhileDriving,
                    controller: web
                )
                if web.isLoading {
                    ProgressView().tint(.bulb)
                }
                if !drive.videoUnlocked {
                    LockedOverlay(audioContinues: keepAudioWhileDriving)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: drive.videoUnlocked)
        }
        .background(Color.night.ignoresSafeArea())
    }

    private var toolbar: some View {
        HStack(spacing: 18) {
            Button { dismiss() } label: {
                Label("Home", systemImage: "house.fill").labelStyle(.iconOnly)
            }
            .accessibilityLabel("Home")
            Button { web.goBack() } label: { Image(systemName: "chevron.left") }
                .disabled(!web.canGoBack)
                .accessibilityLabel("Back")
            Button { web.reload() } label: { Image(systemName: "arrow.clockwise") }
                .accessibilityLabel("Reload")

            Spacer(minLength: 8)
            Text(app.name)
                .font(.headline)
                .foregroundStyle(Color.ink)
                .lineLimit(1)
            Spacer(minLength: 8)

            Menu {
                Toggle("Desktop website", isOn: Binding(
                    get: { desktop },
                    set: { newValue in
                        desktop = newValue
                        UserDefaults.standard.set(newValue, forKey: "desktop.\(app.id)")
                    }
                ))
                Button("Open the \(app.name) app instead") {
                    Task {
                        if await AppLauncher.open(app) == false {
                            AppLauncher.openURL(app.appStoreURL)
                        }
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .accessibilityLabel("More")

            DriveStatusPill()
        }
        .font(.title3)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.panel)
    }
}

struct LockedOverlay: View {
    let audioContinues: Bool
    @EnvironmentObject private var drive: DriveMonitor

    var body: some View {
        ZStack {
            Color.night
            VStack(spacing: 14) {
                Image(systemName: drive.state == .moving ? "car.side.fill" : "location.slash.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.neon)
                Text(drive.state == .moving ? "Eyes on the road" : "Waiting until you're parked")
                    .font(.system(.title2, design: .rounded).weight(.heavy))
                    .foregroundStyle(Color.ink)
                Text(audioContinues
                     ? "The picture is hidden while you drive. The sound keeps playing.\nPark and it comes straight back."
                     : "Playback is paused while you drive.\nPark and press play to carry on.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.muted)
                if drive.state == .noPermission {
                    Button("Allow location") { AppLauncher.openSettings() }
                        .buttonStyle(.borderedProminent)
                }
            }
            .padding(24)
        }
        .contentShape(Rectangle()) // swallow taps so the video underneath can't be used
    }
}

/// The in-app browser that plays each service's website. Sign-ins are kept between launches.
struct WebPlayer: UIViewRepresentable {
    let url: URL
    let desktop: Bool
    let locked: Bool
    let pauseWhenLocked: Bool
    let controller: WebController

    func makeCoordinator() -> Coordinator { Coordinator(controller: controller, desktop: desktop) }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()                 // remember logins
        config.allowsInlineMediaPlayback = true
        config.allowsAirPlayForMediaPlayback = true          // AirPlay to a car screen when the car allows it
        config.allowsPictureInPictureMediaPlayback = false   // PiP would float video over the lock
        config.mediaTypesRequiringUserActionForPlayback = .all
        config.defaultWebpagePreferences.preferredContentMode = desktop ? .desktop : .mobile

        let web = WKWebView(frame: .zero, configuration: config)
        web.navigationDelegate = context.coordinator
        web.uiDelegate = context.coordinator
        web.isOpaque = false
        web.backgroundColor = .black
        web.scrollView.backgroundColor = .black
        web.allowsBackForwardNavigationGestures = true
        controller.webView = web
        web.load(URLRequest(url: url))
        return web
    }

    func updateUIView(_ web: WKWebView, context: Context) {
        let coordinator = context.coordinator
        if coordinator.desktop != desktop {
            coordinator.desktop = desktop
            web.configuration.defaultWebpagePreferences.preferredContentMode = desktop ? .desktop : .mobile
            web.load(URLRequest(url: web.url ?? url))
        }

        guard locked else { return }
        // Leave fullscreen so the lock overlay is on top, and pause if the user asked for that.
        var js = """
        (function(){
          if (document.webkitFullscreenElement && document.webkitExitFullscreen) { document.webkitExitFullscreen(); }
          if (document.fullscreenElement && document.exitFullscreen) { document.exitFullscreen(); }
          document.querySelectorAll('video').forEach(function(v){
            if (v.webkitDisplayingFullscreen && v.webkitExitFullscreen) { v.webkitExitFullscreen(); }
          });
        """
        if pauseWhenLocked {
            js += "document.querySelectorAll('video,audio').forEach(function(m){ m.pause(); });"
        }
        js += "})();"
        web.evaluateJavaScript(js, completionHandler: nil)
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        let controller: WebController
        var desktop: Bool

        init(controller: WebController, desktop: Bool) {
            self.controller = controller
            self.desktop = desktop
        }

        // Keep everything inside DriveIn: block jumps to other apps or the App Store.
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     preferences: WKWebpagePreferences,
                     decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
            preferences.preferredContentMode = desktop ? .desktop : .mobile
            let scheme = navigationAction.request.url?.scheme?.lowercased() ?? "https"
            let host = navigationAction.request.url?.host?.lowercased() ?? ""
            if !["http", "https", "about", "blob", "data"].contains(scheme) || host == "apps.apple.com" {
                decisionHandler(.cancel, preferences)
                return
            }
            decisionHandler(.allow, preferences)
        }

        // Links that try to open a new window load in the same view.
        func webView(_ webView: WKWebView,
                     createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction,
                     windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            update(webView, loading: true)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            update(webView, loading: false)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            update(webView, loading: false)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            update(webView, loading: false)
        }

        private func update(_ webView: WKWebView, loading: Bool) {
            let canGoBack = webView.canGoBack
            Task { @MainActor in
                self.controller.isLoading = loading
                self.controller.canGoBack = canGoBack
            }
        }
    }
}
