//
//  ContentView.swift
//  Bottle of Water
//
//  Created by Yiğit Bal on 8.01.2026.
//

import SwiftUI
import Combine

// MARK: - Root

struct RootView: View {
    @State private var selectedTab: TabItem = .home

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.cyan.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HeaderView()

                Group {
                    switch selectedTab {
                    case .home:
                        HomeView()
                    case .calendar:
                        CalendarView()
                    case .limitize:
                        LimitizeView()
                    case .statistics:
                        StatisticsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                CustomTabBar(selectedTab: $selectedTab)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 6)
            }
        }
    }
}

// MARK: - Home

struct HomeView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bottle of Water")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Image("waterDropImageNew")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 220, height: 300)
                .frame(maxWidth: .infinity)
            
            Spacer()
        }
        .padding()
        .padding(.top, 20)
    }
}

// MARK: - Calendar

struct CalendarView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Calendar")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding()
        .padding(.top, 20)
    }
}

// MARK: - Limitize

struct LimitizeView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Limitize")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding()
        .padding(.top, 20)
    }
}

// MARK: - Statistics

struct StatisticsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding()
        .padding(.top, 20)
    }
}

// MARK: - Water Drop Character

enum CharacterMood {
    case happy
    case thirsty
    case drinking
    case sleepy
}

struct WaterDropImageView: View {
    var fillLevel: CGFloat
    var amplitude: CGFloat
    var waveLength: CGFloat
    var speed: CGFloat

    @State private var phase: CGFloat = 0
    @State private var isFloating = false
    @State private var isBreathing = false
    @State private var isWobbling = false
    @State private var isTapped = false
    @State private var eyesClosed = false
    @State private var mouthOpen: CGFloat = 0
    @State private var currentMood: CharacterMood = .happy
    @State private var isThirsty = false
    @State private var isDrinking = false
    @State private var lookDirection: CGFloat = 0

    let blinkTimer = Timer.publish(every: 3.0, on: .main, in: .common).autoconnect()
    let moodTimer = Timer.publish(every: 8.0, on: .main, in: .common).autoconnect()
    let lookTimer = Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geo in
            let faceCenter = CGPoint(x: geo.size.width / 2, y: geo.size.height * 0.45)
            ZStack {
                WaterDropBodyShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.cyan.opacity(0.6),
                                Color.blue.opacity(0.7),
                                Color.cyan.opacity(0.5)
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
                                        Color.white.opacity(0.5),
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
                                    colors: [
                                        Color.white.opacity(0.6),
                                        Color.cyan.opacity(0.3)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 3
                            )
                    )
                    .shadow(color: .cyan.opacity(0.3), radius: 10, x: 0, y: 5)

                ZStack {
                    HStack(spacing: geo.size.width * 0.18) {
                        EyeView(isClosed: eyesClosed, lookDirection: lookDirection, size: geo.size.width * 0.14)
                        EyeView(isClosed: eyesClosed, lookDirection: lookDirection, size: geo.size.width * 0.14)
                    }
                    .offset(y: -geo.size.height * 0.02)

                    MouthView(
                        mood: currentMood,
                        openAmount: mouthOpen,
                        width: geo.size.width * 0.22,
                        height: geo.size.width * 0.12
                    )
                    .offset(y: geo.size.height * 0.1)

                    if isThirsty {
                        SweatDropView(size: geo.size.width * 0.06)
                            .offset(x: geo.size.width * 0.28, y: -geo.size.height * 0.08)
                            .transition(.opacity.combined(with: .scale))
                    }

                    if isDrinking {
                        DrinkingDropsView(size: geo.size.width * 0.05)
                            .offset(y: geo.size.height * 0.18)
                    }
                }
                .position(faceCenter)
            }
        }
        .offset(y: isFloating ? -6 : 6)
        .scaleEffect(isBreathing ? 1.02 : 0.98)
        .rotationEffect(.degrees(isWobbling ? 1.5 : -1.5))
        .scaleEffect(isTapped ? 0.92 : 1.0)
        .onTapGesture { triggerDrinking() }
        .onAppear { startAnimations() }
        .onReceive(blinkTimer) { _ in triggerBlink() }
        .onReceive(moodTimer) { _ in triggerRandomMood() }
        .onReceive(lookTimer) { _ in triggerRandomLook() }
    }

    private func startAnimations() {
        withAnimation(.linear(duration: 1 / max(speed, 0.1)).repeatForever(autoreverses: false)) {
            phase = .pi * 2
        }
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            isFloating = true
        }
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            isBreathing = true
        }
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            isWobbling = true
        }
    }

    private func triggerBlink() {
        guard Bool.random() || Bool.random() else { return }
        withAnimation(.easeInOut(duration: 0.1)) {
            eyesClosed = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeInOut(duration: 0.1)) {
                eyesClosed = false
            }
        }
        if Bool.random() && Bool.random() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    eyesClosed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        eyesClosed = false
                    }
                }
            }
        }
    }

    private func triggerRandomMood() {
        if Int.random(in: 0...10) < 3 {
            withAnimation(.easeInOut(duration: 0.3)) {
                isThirsty = true
                currentMood = .thirsty
            }
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                mouthOpen = 0.3
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isThirsty = false
                    currentMood = .happy
                    mouthOpen = 0
                }
            }
        }
    }

    private func triggerRandomLook() {
        let directions: [CGFloat] = [-1, -0.5, 0, 0.5, 1]
        withAnimation(.easeInOut(duration: 0.3)) {
            lookDirection = directions.randomElement() ?? 0
        }
    }

    private func triggerDrinking() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            isTapped = true
        }
        withAnimation(.easeInOut(duration: 0.2)) {
            isDrinking = true
            currentMood = .drinking
            isThirsty = false
        }
        drinkingMouthAnimation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isTapped = false
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isDrinking = false
                currentMood = .happy
                mouthOpen = 0
            }
        }
    }

    private func drinkingMouthAnimation() {
        for i in 0..<4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.4) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    mouthOpen = 0.8
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        mouthOpen = 0.2
                    }
                }
            }
        }
    }
}

// MARK: - Eye View

struct EyeView: View {
    var isClosed: Bool
    var lookDirection: CGFloat
    var size: CGFloat

    var body: some View {
        ZStack {
            Ellipse()
                .fill(.white)
                .frame(width: size, height: isClosed ? size * 0.1 : size * 0.9)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)

            if !isClosed {
                Circle()
                    .fill(.black)
                    .frame(width: size * 0.45, height: size * 0.45)
                    .offset(x: lookDirection * size * 0.15, y: size * 0.05)

                Circle()
                    .fill(.white.opacity(0.8))
                    .frame(width: size * 0.15, height: size * 0.15)
                    .offset(x: -size * 0.08 + lookDirection * size * 0.1, y: -size * 0.08)
            }
        }
        .animation(.easeInOut(duration: 0.1), value: isClosed)
    }
}

// MARK: - Mouth View

struct MouthView: View {
    var mood: CharacterMood
    var openAmount: CGFloat
    var width: CGFloat
    var height: CGFloat

    var body: some View {
        ZStack {
            switch mood {
            case .happy:
                HappyMouth(width: width, height: height)
            case .thirsty:
                OpenMouth(width: width, height: height * (0.5 + openAmount))
            case .drinking:
                DrinkingMouth(width: width * 0.6, height: height * (0.3 + openAmount * 0.7))
            case .sleepy:
                SleepyMouth(width: width, height: height)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: mood)
        .animation(.easeInOut(duration: 0.15), value: openAmount)
    }
}

struct HappyMouth: View {
    var width: CGFloat
    var height: CGFloat

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addQuadCurve(
                to: CGPoint(x: width, y: 0),
                control: CGPoint(x: width / 2, y: height)
            )
        }
        .stroke(Color.black, style: StrokeStyle(lineWidth: 3, lineCap: .round))
        .frame(width: width, height: height)
    }
}

struct OpenMouth: View {
    var width: CGFloat
    var height: CGFloat

    var body: some View {
        Ellipse()
            .fill(Color.black.opacity(0.8))
            .frame(width: width * 0.7, height: max(height, 5))
            .overlay(
                Ellipse()
                    .fill(Color.pink.opacity(0.6))
                    .frame(width: width * 0.5, height: max(height * 0.6, 3))
                    .offset(y: height * 0.1)
            )
    }
}

struct DrinkingMouth: View {
    var width: CGFloat
    var height: CGFloat

    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color.black.opacity(0.85))
                .frame(width: width, height: max(height, 8))
            Ellipse()
                .fill(Color.pink.opacity(0.5))
                .frame(width: width * 0.6, height: max(height * 0.5, 4))
        }
    }
}

struct SleepyMouth: View {
    var width: CGFloat
    var height: CGFloat

    var body: some View {
        Capsule()
            .fill(Color.black)
            .frame(width: width * 0.5, height: 3)
    }
}

// MARK: - Sweat Drop View

private struct SweatDropShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let top = CGPoint(x: w / 2, y: 0)
        let left = CGPoint(x: 0, y: h * 0.6)
        let right = CGPoint(x: w, y: h * 0.6)

        path.move(to: top)
        path.addQuadCurve(to: right, control: CGPoint(x: w, y: h * 0.15))
        path.addQuadCurve(to: left, control: CGPoint(x: w / 2, y: h))
        path.addQuadCurve(to: top, control: CGPoint(x: 0, y: h * 0.15))
        path.closeSubpath()
        return path
    }
}

struct SweatDropView: View {
    var size: CGFloat
    @State private var wiggle: CGFloat = 0

    var body: some View {
        SweatDropShape()
            .fill(
                LinearGradient(
                    colors: [
                        Color.cyan.opacity(0.9),
                        Color.blue.opacity(0.8),
                        Color.cyan.opacity(0.7)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                SweatDropShape()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.7),
                                Color.white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .overlay(
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.7),
                                Color.white.opacity(0.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: size * 0.25, height: size * 0.25)
                    .offset(x: -size * 0.15, y: -size * 0.05)
                    .blur(radius: size * 0.05)
                    .opacity(0.9)
            )
            .frame(width: size, height: size * 1.4)
            .rotationEffect(.degrees(Double(sin(wiggle) * 6)))
            .offset(y: sin(wiggle * 0.8) * (size * 0.06))
            .onAppear {
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                    wiggle = .pi * 2
                }
            }
    }
}

// MARK: - Drinking Drops View

struct DrinkingDropsView: View {
    var size: CGFloat
    @State private var drops: [Bool] = [false, false, false]

    var body: some View {
        HStack(spacing: size * 0.5) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: "drop.fill")
                    .font(.system(size: size))
                    .foregroundColor(.cyan)
                    .opacity(drops[index] ? 1 : 0)
                    .offset(y: drops[index] ? 10 : -5)
            }
        }
        .onAppear {
            animateDrops()
        }
    }

    private func animateDrops() {
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                withAnimation(.easeIn(duration: 0.3)) {
                    drops[i] = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        drops[i] = false
                    }
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            animateDrops()
        }
    }
}

// MARK: - Water Drop Body Shape

struct WaterDropBodyShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height

        let topPoint = CGPoint(x: width / 2, y: 0)
        let leftTopControl = CGPoint(x: width * 0.1, y: height * 0.25)
        let leftBottomControl = CGPoint(x: -width * 0.05, y: height * 0.65)
        let bottomLeft = CGPoint(x: width * 0.15, y: height * 0.85)
        let rightTopControl = CGPoint(x: width * 0.9, y: height * 0.25)
        let rightBottomControl = CGPoint(x: width * 1.05, y: height * 0.65)
        let bottomRight = CGPoint(x: width * 0.85, y: height * 0.85)
        let bottomCenter = CGPoint(x: width / 2, y: height)

        path.move(to: topPoint)
        path.addCurve(to: bottomLeft, control1: leftTopControl, control2: leftBottomControl)
        path.addQuadCurve(to: bottomRight, control: bottomCenter)
        path.addCurve(to: topPoint, control1: rightBottomControl, control2: rightTopControl)
        path.closeSubpath()

        return path
    }
}

// MARK: - Wave Shape

struct WaveShape: Shape {
    var phase: CGFloat
    var amplitude: CGFloat
    var waveLength: CGFloat
    var fillLevel: CGFloat

    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let clamped = min(max(fillLevel, 0), 1)
        let waterY = rect.maxY - rect.height * clamped

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: waterY))

        var x: CGFloat = 0
        while x <= rect.width {
            let y = waterY + sin((x / waveLength) * .pi * 2 + phase) * amplitude
            path.addLine(to: CGPoint(x: rect.minX + x, y: y))
            x += 2
        }

        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()

        return path
    }
}

// MARK: - Preview

#Preview {
    RootView()
}
