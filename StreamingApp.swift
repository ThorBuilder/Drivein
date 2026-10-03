import SwiftUI

/// One service DriveIn can open. Video services lock while the car is moving; audio services never lock.
struct StreamingApp: Identifiable, Hashable {
    enum Kind { case video, audio }

    let id: String
    let name: String
    let subtitle: String
    let kind: Kind
    let tint: Color
    /// Plays inside DriveIn's own player instead of opening another app.
    let playsInside: Bool
    /// Website links that open the installed app directly (universal links).
    let universalLinks: [String]
    /// App URL schemes, tried after universal links. Each scheme must also be listed
    /// under LSApplicationQueriesSchemes in project.yml.
    let schemes: [String]
    let webURL: String
    /// Numeric App Store id, or nil for apps built into iOS.
    let appStoreID: String?
    /// Load the desktop version of the website. Many services only allow playback there.
    var desktopSite: Bool = false

    var appStoreURL: URL? {
        guard let appStoreID else { return nil }
        return URL(string: "https://apps.apple.com/app/id\(appStoreID)")
    }
}

extension StreamingApp {
    static let watch: [StreamingApp] = [
        .init(id: "youtube", name: "YouTube", subtitle: "Videos", kind: .video,
              tint: Color(hex: 0xE62117), playsInside: true,
              universalLinks: [], schemes: ["youtube://"],
              webURL: "https://m.youtube.com", appStoreID: "544007664"),
        .init(id: "netflix", name: "Netflix", subtitle: "Films & series", kind: .video,
              tint: Color(hex: 0xB20710), playsInside: true,
              universalLinks: ["https://www.netflix.com/browse"], schemes: ["nflx://"],
              webURL: "https://www.netflix.com/browse", appStoreID: "363590051", desktopSite: true),
        .init(id: "prime", name: "Prime Video", subtitle: "Films & series", kind: .video,
              tint: Color(hex: 0x1A98FF), playsInside: true,
              universalLinks: ["https://app.primevideo.com"], schemes: ["aiv://"],
              webURL: "https://www.primevideo.com", appStoreID: "545519333", desktopSite: true),
        .init(id: "disney", name: "Disney+", subtitle: "Films & series", kind: .video,
              tint: Color(hex: 0x0B2A7A), playsInside: true,
              universalLinks: ["https://www.disneyplus.com/home"], schemes: ["disneyplus://"],
              webURL: "https://www.disneyplus.com", appStoreID: "1446075923", desktopSite: true),
        .init(id: "max", name: "Max", subtitle: "Films & series", kind: .video,
              tint: Color(hex: 0x2C1FA8), playsInside: true,
              universalLinks: ["https://play.max.com"], schemes: ["max://", "hbomax://"],
              webURL: "https://play.max.com", appStoreID: "971265422", desktopSite: true),
        .init(id: "appletv", name: "Apple TV", subtitle: "Films & series", kind: .video,
              tint: Color(hex: 0x2A2A2E), playsInside: true,
              universalLinks: ["https://tv.apple.com"], schemes: ["videos://"],
              webURL: "https://tv.apple.com", appStoreID: "1174078549", desktopSite: true),
        .init(id: "twitch", name: "Twitch", subtitle: "Live streams", kind: .video,
              tint: Color(hex: 0x7A3FF2), playsInside: true,
              universalLinks: ["https://www.twitch.tv"], schemes: ["twitch://"],
              webURL: "https://m.twitch.tv", appStoreID: "460177396"),
        .init(id: "plex", name: "Plex", subtitle: "Your library", kind: .video,
              tint: Color(hex: 0xC98A07), playsInside: true,
              universalLinks: ["https://app.plex.tv"], schemes: ["plex://"],
              webURL: "https://app.plex.tv", appStoreID: "383457673"),
    ]

    static let listen: [StreamingApp] = [
        .init(id: "spotify", name: "Spotify", subtitle: "Music", kind: .audio,
              tint: Color(hex: 0x138A43), playsInside: false,
              universalLinks: ["https://open.spotify.com"], schemes: ["spotify://"],
              webURL: "https://open.spotify.com", appStoreID: "324684580"),
        .init(id: "ytmusic", name: "YouTube Music", subtitle: "Music", kind: .audio,
              tint: Color(hex: 0xC4140C), playsInside: false,
              universalLinks: ["https://music.youtube.com"], schemes: ["youtubemusic://"],
              webURL: "https://music.youtube.com", appStoreID: "1017492454"),
        .init(id: "applemusic", name: "Apple Music", subtitle: "Music", kind: .audio,
              tint: Color(hex: 0xD92B4A), playsInside: false,
              universalLinks: [], schemes: ["music://"],
              webURL: "https://music.apple.com", appStoreID: "1108187390"),
        .init(id: "podcasts", name: "Podcasts", subtitle: "Talk", kind: .audio,
              tint: Color(hex: 0x6B2FB3), playsInside: false,
              universalLinks: [], schemes: ["podcasts://"],
              webURL: "https://podcasts.apple.com", appStoreID: "525463029"),
    ]
}
