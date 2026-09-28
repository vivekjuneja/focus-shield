import SwiftUI

private let palettes: [[Color]] = [
    [Color(red: 0.43, green: 0.16, blue: 0.85), Color(red: 0.05, green: 0.65, blue: 0.91)],
    [Color(red: 0.93, green: 0.29, blue: 0.47), Color(red: 0.98, green: 0.62, blue: 0.23)],
    [Color(red: 0.06, green: 0.73, blue: 0.51), Color(red: 0.23, green: 0.40, blue: 0.93)],
]

/// Three fact screens, each asking whether to stay focused or keep going, followed by
/// a screen to pick a pause length.
struct PersuasionView: View {
    let facts: [Fact]
    let onStayFocused: () -> Void
    let onPause: (Int) -> Void

    @State private var step = 0
    @State private var readSeconds = 0
    @State private var appeared = false

    private let readDelay = 5
    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var palette: [Color] { palettes[min(step, palettes.count - 1)] }
    private var canContinue: Bool { readSeconds >= readDelay }

    var body: some View {
        ZStack {
            background
            VStack(spacing: 0) {
                header
                Spacer(minLength: 20)
                Group {
                    if step < facts.count {
                        factCard(facts[step]).id(step)
                    } else {
                        durationPicker
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)))
                Spacer(minLength: 20)
                if step < facts.count { factButtons }
            }
            .padding(36)
        }
        .frame(width: 580, height: 660)
        .preferredColorScheme(.dark)
        .onReceive(ticker) { _ in if readSeconds < readDelay { readSeconds += 1 } }
        .onAppear { withAnimation(.easeOut(duration: 0.6)) { appeared = true } }
    }

    // MARK: Pieces

    private var background: some View {
        ZStack {
            Color(red: 0.04, green: 0.04, blue: 0.10)
            Circle().fill(palette[0]).frame(width: 420).blur(radius: 120)
                .offset(x: -170, y: -230).opacity(0.7)
            Circle().fill(palette[1]).frame(width: 380).blur(radius: 120)
                .offset(x: 190, y: 250).opacity(0.6)
        }
        .animation(.easeInOut(duration: 0.8), value: step)
        .ignoresSafeArea()
    }

    private var header: some View {
        VStack(spacing: 14) {
            HStack(spacing: 8) {
                ForEach(0..<facts.count + 1, id: \.self) { i in
                    Capsule()
                        .fill(i <= step ? Color.white : Color.white.opacity(0.2))
                        .frame(width: i == step ? 28 : 8, height: 8)
                }
            }
            .animation(.spring(response: 0.4), value: step)
            Text(step < facts.count ? "BEFORE YOU PAUSE THE SHIELD · \(step + 1) OF \(facts.count)"
                                    : "YOUR CHOICE")
                .font(.system(size: 11, weight: .semibold))
                .tracking(1.4)
                .foregroundStyle(.white.opacity(0.6))
        }
    }

    private func factCard(_ fact: Fact) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Image(systemName: fact.icon)
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(
                    LinearGradient(colors: palette, startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: palette[0].opacity(0.5), radius: 16, y: 6)

            Text(fact.headline)
                .font(.system(size: 34, weight: .bold, design: .serif))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            Text(fact.body)
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .lineSpacing(5)
                .foregroundStyle(.white.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)

            Text("— \(fact.source)")
                .font(.system(size: 13).italic())
                .foregroundStyle(.white.opacity(0.55))
        }
        .padding(28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous)
            .strokeBorder(.white.opacity(0.12)))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private var factButtons: some View {
        VStack(spacing: 12) {
            Text("Do you really want to turn off the shield?")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))

            Button(action: onStayFocused) {
                Label("You're right — keep me focused", systemImage: "shield.lefthalf.filled")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PillButtonStyle(filled: true))
            .keyboardShortcut(.defaultAction)

            Button(action: advance) {
                Text(continueLabel).frame(maxWidth: .infinity)
            }
            .buttonStyle(PillButtonStyle(filled: false))
            .disabled(!canContinue)
        }
    }

    private var continueLabel: String {
        if !canContinue { return "Take a moment to read… \(readDelay - readSeconds)" }
        return step < facts.count - 1 ? "I'm not convinced yet — show me another" : "I still want to pause it"
    }

    private var durationPicker: some View {
        VStack(spacing: 22) {
            Image(systemName: "hourglass")
                .font(.system(size: 34, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 72, height: 72)
                .background(LinearGradient(colors: palette, startPoint: .topLeading, endPoint: .bottomTrailing),
                            in: Circle())

            Text("Okay. How long do you need?")
                .font(.system(size: 30, weight: .bold, design: .serif))
                .foregroundStyle(.white)
            Text("The shield turns itself back on when the time is up.")
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))

            HStack(spacing: 14) {
                durationCard(minutes: 30, title: "30 minutes", subtitle: "A short break")
                durationCard(minutes: 60, title: "1 hour", subtitle: "Then back to focus")
            }
            .padding(.top, 6)

            Button(action: onStayFocused) {
                Label("Actually, keep me focused", systemImage: "shield.lefthalf.filled")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PillButtonStyle(filled: true))
            .keyboardShortcut(.defaultAction)
            .padding(.top, 10)
        }
    }

    private func durationCard(minutes: Int, title: String, subtitle: String) -> some View {
        Button { onPause(minutes) } label: {
            VStack(spacing: 6) {
                Text(title).font(.system(size: 20, weight: .semibold, design: .rounded))
                Text(subtitle).font(.system(size: 12)).foregroundStyle(.white.opacity(0.6))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(.white.opacity(0.15)))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func advance() {
        withAnimation(.spring(response: 0.55, dampingFraction: 0.85)) {
            step += 1
        }
        readSeconds = 0
    }
}

private struct PillButtonStyle: ButtonStyle {
    let filled: Bool
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .padding(.vertical, 13)
            .padding(.horizontal, 20)
            .foregroundStyle(filled ? Color.black : Color.white.opacity(isEnabled ? 0.9 : 0.4))
            .background(
                Capsule().fill(filled ? Color.white : Color.white.opacity(configuration.isPressed ? 0.16 : 0.08)))
            .overlay(Capsule().strokeBorder(.white.opacity(filled ? 0 : 0.18)))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
            .contentShape(Capsule())
    }
}
