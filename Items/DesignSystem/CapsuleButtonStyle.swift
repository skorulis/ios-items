import SwiftUI

struct CapsuleButtonStyle: ButtonStyle {
    var foreground: Color = .white
    var background: Color = .accentColor
    var pressedBackground: Color? = nil
    var padding: EdgeInsets = EdgeInsets(top: 10, leading: 18, bottom: 10, trailing: 18)
    var shadow: Color = .black.opacity(0.15)

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(foreground)
            .padding(padding)
            .background(
                Capsule()
                    .fill((pressedBackground ?? background).opacity(configuration.isPressed ? 0.85 : 1.0))
            )
            .shadow(color: shadow, radius: configuration.isPressed ? 2 : 6, x: 0, y: configuration.isPressed ? 1 : 4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

#Preview("Capsule Button Style") {
    VStack(spacing: 16) {
        Button("Primary") {}
            .buttonStyle(CapsuleButtonStyle())
        Button("Custom") {}
            .buttonStyle(CapsuleButtonStyle(foreground: .black, background: .yellow, pressedBackground: .orange))
    }
    .padding()
}
