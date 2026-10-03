import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }

    static let night = Color(hex: 0x0D1024)
    static let panel = Color(hex: 0x161A36)
    static let panel2 = Color(hex: 0x1F2447)
    static let line = Color(hex: 0x2C3260)
    static let ink = Color(hex: 0xF3EFE6)
    static let muted = Color(hex: 0x9AA0C7)
    static let bulb = Color(hex: 0xFFB547)
    static let neon = Color(hex: 0xFF5D6C)
    static let go = Color(hex: 0x45D39A)
}

/// The glowing marquee wordmark.
struct Wordmark: View {
    var size: CGFloat = 40

    var body: some View {
        Text("DriveIn")
            .font(.system(size: size, weight: .black, design: .rounded))
            .tracking(1)
            .foregroundStyle(Color.bulb)
            .shadow(color: .bulb.opacity(0.55), radius: 14)
    }
}

/// Row of blinking marquee bulbs.
struct MarqueeBulbs: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var on = false

    var body: some View {
        HStack(spacing: 7) {
            ForEach(0..<7, id: \.self) { i in
                Circle()
                    .fill(Color.bulb)
                    .frame(width: 8, height: 8)
                    .shadow(color: .bulb, radius: 4)
                    .opacity(reduceMotion ? 1 : ((i % 2 == 0) == on ? 1 : 0.25))
            }
        }
        .accessibilityHidden(true)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 0.8).repeatForever()) { on.toggle() }
        }
    }
}
