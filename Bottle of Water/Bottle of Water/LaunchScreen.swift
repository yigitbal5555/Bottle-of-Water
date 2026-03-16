//
//  LaunchScreen.swift
//  Bottle of Water
//
//  Created by Yiğit Bal on 8.01.2026.
//

import SwiftUI

struct LaunchScreenView: View {
    var onFinish: () -> Void

    // Water wave rising from bottom
    @State private var waveHeight: CGFloat = 0

    // Drop falls from above
    @State private var dropOffsetY: CGFloat = -420
    @State private var dropOpacity: Double = 0
    @State private var dropScaleX: CGFloat = 1.0
    @State private var dropScaleY: CGFloat = 1.0

    // Splash rings after landing
    @State private var splashScale: CGFloat = 0.05
    @State private var splashOpacity: Double = 0.0

    // Title slides up
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 28

    var body: some View {
        ZStack {
            // Static gradient background
            LinearGradient(
                colors: [Color.blue.opacity(0.09), Color.cyan.opacity(0.04)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Rising water fill from the bottom
            GeometryReader { geo in
                LinearGradient(
                    colors: [Color.cyan.opacity(0.28), Color.blue.opacity(0.14)],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: geo.size.height * waveHeight)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .ignoresSafeArea()
            }

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    // Splash rings — radiate outward after drop lands
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .stroke(
                                Color.cyan.opacity(0.4 / Double(i + 1)),
                                lineWidth: 1.5
                            )
                            .frame(
                                width:  165 + CGFloat(i) * 50,
                                height: 165 + CGFloat(i) * 50
                            )
                            .scaleEffect(splashScale)
                            .opacity(splashOpacity / Double(i + 1))
                    }

                    // Water drop mascot — falls in from above
                    WaterDropCharacterView(currentGlasses: 5, goalGlasses: 8)
                        .frame(width: 200, height: 280)
                        .scaleEffect(x: dropScaleX, y: dropScaleY, anchor: .bottom)
                        .opacity(dropOpacity)
                        .offset(y: dropOffsetY)
                        .allowsHitTesting(false)
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
        // Phase 1 (0.0s): Water wave rises from the bottom
        withAnimation(.easeOut(duration: 0.75)) {
            waveHeight = 0.50
        }

        // Phase 2 (0.2s): Drop becomes visible and falls with spring physics
        dropOpacity = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.interpolatingSpring(stiffness: 170, damping: 11)) {
                dropOffsetY = 0
            }
        }

        // Phase 3 (0.68s): Squash on landing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.68) {
            withAnimation(.easeOut(duration: 0.09)) {
                dropScaleX = 1.20
                dropScaleY = 0.80
            }
            // Restore with a springy bounce
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.48)) {
                    dropScaleX = 1.0
                    dropScaleY = 1.0
                }
            }
        }

        // Phase 4 (0.75s): Splash rings radiate outward
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            splashOpacity = 0.75
            withAnimation(.easeOut(duration: 1.0)) {
                splashScale   = 1.0
                splashOpacity = 0.0
            }
        }

        // Phase 5 (0.90s): Title slides up
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.90) {
            withAnimation(.easeOut(duration: 0.45)) {
                titleOpacity = 1.0
                titleOffset  = 0
            }
        }

        // Phase 6 (2.8s): Dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8, execute: onFinish)
    }
}

#Preview {
    LaunchScreenView(onFinish: {})
}
