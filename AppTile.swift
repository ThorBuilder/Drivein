import SwiftUI

struct AppTile: View {
    let app: StreamingApp
    let locked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                VStack(alignment: .leading) {
                    Text(app.subtitle)
                        .font(.caption.weight(.semibold))
                        .opacity(0.85)
                    Spacer(minLength: 8)
                    Text(app.name)
                        .font(.system(.title3, design: .rounded).weight(.heavy))
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(16)
                .foregroundStyle(.white)
                .background(app.tint)
                .saturation(locked ? 0.25 : 1)

                if locked {
                    Color.night.opacity(0.75)
                    VStack(spacing: 6) {
                        Image(systemName: "lock.fill")
                        Text("Unlocks when parked")
                            .font(.caption.weight(.bold))
                    }
                    .foregroundStyle(Color.ink)
                }
            }
            .aspectRatio(16.0 / 10.0, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(TilePressStyle())
        .accessibilityLabel(locked ? "\(app.name), locked until parked" : app.name)
    }
}

private struct TilePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}
