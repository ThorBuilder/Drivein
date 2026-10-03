import SwiftUI

/// Speed + parked/driving pill shown at the top of every screen.
struct DriveStatusPill: View {
    @EnvironmentObject private var drive: DriveMonitor

    var body: some View {
        HStack(spacing: 10) {
            Text("\(Int(drive.speedKmh.rounded())) km/h")
                .font(.system(.footnote, design: .monospaced).weight(.medium))
                .monospacedDigit()
                .foregroundStyle(Color.muted)
            Text(label)
                .font(.caption.weight(.heavy))
                .tracking(1.2)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(color, in: Capsule())
                .foregroundStyle(Color.night)
        }
        .accessibilityElement(children: .combine)
    }

    private var label: String {
        switch drive.state {
        case .parked: return "PARKED"
        case .moving: return "DRIVING"
        case .checking: return "CHECKING"
        case .noPermission: return "NO GPS"
        }
    }

    private var color: Color {
        switch drive.state {
        case .parked: return .go
        case .moving: return .neon
        case .checking, .noPermission: return .muted
        }
    }
}

/// Explains the current lock state in one line.
struct DriveBanner: View {
    @EnvironmentObject private var drive: DriveMonitor

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(title).font(.headline).foregroundStyle(accent)
            Text(message).font(.subheadline).foregroundStyle(Color.ink.opacity(0.85))
            Spacer(minLength: 0)
            if drive.state == .noPermission {
                Button("Allow location") { AppLauncher.openSettings() }
                    .font(.subheadline.weight(.semibold))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(accent.opacity(0.35)))
    }

    private var accent: Color {
        switch drive.state {
        case .parked: return .go
        case .moving: return .neon
        default: return .bulb
        }
    }

    private var title: String {
        switch drive.state {
        case .parked: return "Parked"
        case .moving: return "Driving"
        case .checking: return "One moment"
        case .noPermission: return "Location is off"
        }
    }

    private var message: String {
        switch drive.state {
        case .parked: return "All apps unlocked. Enjoy the show."
        case .moving: return "Video is paused for safety. Music and podcasts keep playing."
        case .checking: return "Checking that the car is parked before video unlocks."
        case .noPermission: return "DriveIn needs your speed to unlock video when parked."
        }
    }
}
