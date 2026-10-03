import SwiftUI
import UIKit

struct HomeView: View {
    @EnvironmentObject private var drive: DriveMonitor
    @State private var playing: StreamingApp?
    @State private var showSettings = false
    @State private var missingApp: StreamingApp?

    private let columns = [GridItem(.adaptive(minimum: 150, maximum: 260), spacing: 14)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    header
                    DriveBanner()

                    section("Watch") {
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(StreamingApp.watch) { app in
                                AppTile(app: app, locked: !drive.videoUnlocked) { open(app) }
                            }
                        }
                    }

                    section("Listen") {
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(StreamingApp.listen) { app in
                                AppTile(app: app, locked: false) { open(app) }
                            }
                        }
                    }

                    Text("Video in DriveIn only plays while the car is parked. Sign in to each service once inside DriveIn and it remembers you.")
                        .font(.footnote)
                        .foregroundStyle(Color.muted)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color.night.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .toolbarBackground(Color.night, for: .navigationBar)
            .fullScreenCover(item: $playing) { app in
                PlayerScreen(app: app)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(item: $missingApp) { app in
                MissingAppSheet(app: app)
                    .presentationDetents([.height(260)])
            }
        }
    }

    private var header: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Wordmark(size: 44)
                Text("Your car is the cinema.")
                    .foregroundStyle(Color.muted)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 10) {
                MarqueeBulbs()
                DriveStatusPill()
            }
        }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.caption.weight(.bold))
                .tracking(1.6)
                .foregroundStyle(Color.muted)
            content()
        }
    }

    private func open(_ app: StreamingApp) {
        if app.kind == .video && !drive.videoUnlocked {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            return
        }
        if app.playsInside {
            playing = app
            return
        }
        Task {
            let opened = await AppLauncher.open(app)
            if !opened { missingApp = app }
        }
    }
}

/// Shown when a service's app isn't installed on this iPhone.
struct MissingAppSheet: View {
    let app: StreamingApp
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(app.name) isn't installed")
                .font(.title3.weight(.bold))
            Text("Get the app from the App Store, then come back to DriveIn and tap it again.")
                .foregroundStyle(Color.muted)
            HStack(spacing: 12) {
                if app.appStoreURL != nil {
                    Button {
                        AppLauncher.openURL(app.appStoreURL)
                        dismiss()
                    } label: {
                        Text("Get on App Store").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                Button {
                    AppLauncher.openURL(URL(string: app.webURL))
                    dismiss()
                } label: {
                    Text("Open website").frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .controlSize(.large)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.panel.ignoresSafeArea())
    }
}
