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

    // Water drop character
    @State private var isFloating = false
    @State private var isBreathing = false
    @State private var eyesClosed = false
    @State private var eyebrowsRaised = false
    @State private var lookDirection: CGFloat = 0

    let blinkTimer = Timer.publish(every: 3.2, on: .main, in: .common).autoconnect()
    let lookTimer  = Timer.publish(every: 2.8, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Same gradient as app background
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.cyan.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Ripple ring behind the character
                ZStack {
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
                            .frame(width: 180 + CGFloat(i) * 44,
                                   height: 180 + CGFloat(i) * 44)
                            .scaleEffect(rippleScale)
                            .opacity(rippleOpacity / Double(i + 1))
                    }

                    // Water drop mascot
                    LaunchDropCharacter(
                        isFloating: isFloating,
                        isBreathing: isBreathing,
                        eyesClosed: eyesClosed,
                        eyebrowsRaised: eyebrowsRaised,
                        lookDirection: lookDirection
                    )
                    .frame(width: 200, height: 280)
                    .scaleEffect(dropScale)
                    .opacity(dropOpacity)
                }

                Spacer().frame(height: 32)

                // App title
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
        .onReceive(blinkTimer) { _ in blink() }
        .onReceive(lookTimer)  { _ in randomLook() }
    }

    // MARK: - Entrance sequence

    private func runEntrance() {
        // 1. Pop the drop in
        withAnimation(.spring(response: 0.55, dampingFraction: 0.58)) {
            dropScale   = 1.0
            dropOpacity = 1.0
        }

        // 2. Expand ripples
        withAnimation(.easeOut(duration: 1.1)) {
            rippleScale   = 1.0
            rippleOpacity = 0.0
        }

        // 3. Slide title up
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.easeOut(duration: 0.45)) {
                titleOpacity = 1.0
                titleOffset  = 0
            }
        }

        // 4. Start idle animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isFloating = true
            }
            withAnimation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true)) {
                isBreathing = true
            }
        }

        // 5. Dismiss after 2.6 s
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6, execute: onFinish)
    }

    // MARK: - Idle face animations

    private func blink() {
        withAnimation(.easeInOut(duration: 0.08)) { eyesClosed = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.13) {
            withAnimation(.easeInOut(duration: 0.08)) { eyesClosed = false }
        }
    }

    private func randomLook() {
        let dirs: [CGFloat] = [-1, -0.5, 0, 0, 0.5, 1]
        withAnimation(.easeInOut(duration: 0.35)) {
            lookDirection = dirs.randomElement() ?? 0
        }
    }
}

// MARK: - Self-contained Launch Drop Character

private struct LaunchDropCharacter: View {
    let isFloating: Bool
    let isBreathing: Bool
    let eyesClosed: Bool
    let eyebrowsRaised: Bool
    let lookDirection: CGFloat

    var body: some View {
        GeometryReader { geo in
            let cx = geo.size.width / 2
            let cy = geo.size.height * 0.5

            ZStack {
                // Body
                WaterDropBodyShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.cyan.opacity(0.7),
                                Color.blue.opacity(0.8),
                                Color.cyan.opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        WaterDropBodyShape()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.6),
                                        Color.white.opacity(0.2),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .center
                                )
                            )
                    )
                    .overlay(
                        WaterDropBodyShape()
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.7), Color.cyan.opacity(0.4)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 3
                            )
                    )
                    .shadow(color: .cyan.opacity(0.35), radius: 14, x: 0, y: 8)

                // Face
                VStack(spacing: 0) {
                    // Eyebrows
                    HStack(spacing: geo.size.width * 0.22) {
                        EyebrowView(isRaised: eyebrowsRaised, isLeft: true,  width: geo.size.width * 0.12)
                        EyebrowView(isRaised: eyebrowsRaised, isLeft: false, width: geo.size.width * 0.12)
                    }
                    .offset(y: eyebrowsRaised ? -3 : 0)

                    // Eyes
                    HStack(spacing: geo.size.width * 0.18) {
                        EyeView(isClosed: eyesClosed, lookDirection: lookDirection, size: geo.size.width * 0.16)
                        EyeView(isClosed: eyesClosed, lookDirection: lookDirection, size: geo.size.width * 0.16)
                    }
                    .padding(.top, 4)

                    // Nose
                    NoseView(size: geo.size.width * 0.06)
                        .padding(.top, 8)

                    // Always smiling on launch
                    SmileMouth(width: geo.size.width * 0.25, height: geo.size.width * 0.12)
                        .padding(.top, 6)
                }
                .position(x: cx, y: cy)
            }
        }
        .offset(y: isFloating ? -8 : 8)
        .scaleEffect(isBreathing ? 1.03 : 0.97)
        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isFloating)
        .animation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true), value: isBreathing)
    }
}

#Preview {
    LaunchScreenView(onFinish: {})
}
