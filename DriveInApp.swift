import SwiftUI

@main
struct DriveInApp: App {
    @StateObject private var drive = DriveMonitor()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(drive)
                .preferredColorScheme(.dark)
                .tint(.bulb)
                .onAppear { drive.start() }
        }
    }
}
