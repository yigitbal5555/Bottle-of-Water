//
//  LaunchScreen.swift
//  Bottle of Water
//
//  Created by Yiğit Bal on 8.01.2026.
//

import SwiftUI

struct LaunchScreenView: View {
    var onFinish: () -> Void

    // Entrance animation states
    @State private var dropScale: CGFloat = 0.2
    @State private var dropOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 20
    @State private var rippleScale: CGFloat = 0.6
    @State private var rippleOpacity: Double = 0.6

    var body: some View {
        ZStack {
            // Same gradient as the main app background
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.cyan.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    // Expanding ripple rings on entrance
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color.cyan.opacity(0.18), Color.blue.opacity(0.08)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                            .frame(
                                width:  180 + CGFloat(i) * 44,
                                height: 180 + CGFloat(i) * 44
                            )
                            .scaleEffect(rippleScale)
                            .opacity(rippleOpacity / Double(i + 1))
                    }

                    // The real animated water drop mascot — same character as the Home tab.
                    // currentGlasses: 5 / goalGlasses: 8 → progressRatio 0.625 → happy, not thirsty.
                    // All internal animations (float, breathe, wobble, blink, look, mouth) run automatically.
                    WaterDropCharacterView(currentGlasses: 5, goalGlasses: 8)
                        .frame(width: 200, height: 280)
                        .scaleEffect(dropScale)
                        .opacity(dropOpacity)
                        .allowsHitTesting(false) // no tap-to-log on launch screen
                }

                Spacer().frame(height: 32)

                // App title slides up after the drop lands
                VStack(spacing: 8) {
                    Text("Bottle of Water")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("Your hydration companion")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .opacity(titleOpacity)
                .offset(y: titleOffset)

                Spacer()
            }
        }
        .onAppear(perform: runEntrance)
    }

    // MARK: - Entrance sequence

    private func runEntrance() {
        // 1. Spring pop-in
        withAnimation(.spring(response: 0.55, dampingFraction: 0.58)) {
            dropScale   = 1.0
            dropOpacity = 1.0
        }

        // 2. Ripples expand and fade
        withAnimation(.easeOut(duration: 1.1)) {
            rippleScale   = 1.0
            rippleOpacity = 0.0
        }

        // 3. Title slides up
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.easeOut(duration: 0.45)) {
                titleOpacity = 1.0
                titleOffset  = 0
            }
        }

        // 4. Dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6, execute: onFinish)
    }
}

#Preview {
    LaunchScreenView(onFinish: {})
}
