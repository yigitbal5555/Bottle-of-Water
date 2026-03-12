//
//  OnboardingView.swift
//  Bottle of Water
//
//  Created by Yiğit Bal on 8.01.2026.
//

import SwiftUI

// MARK: - Profile Enums

enum OnboardingGender: String, CaseIterable {
    case male, female, nonBinary, preferNotToSay

    var label: String {
        switch self {
        case .male:           return "Male"
        case .female:         return "Female"
        case .nonBinary:      return "Non-binary"
        case .preferNotToSay: return "Prefer not to say"
        }
    }
    var icon: String {
        switch self {
        case .male:           return "figure.stand"
        case .female:         return "figure.stand.dress"
        case .nonBinary:      return "person.2.fill"
        case .preferNotToSay: return "questionmark.circle.fill"
        }
    }
    var color: Color {
        switch self {
        case .male:           return .blue
        case .female:         return .pink
        case .nonBinary:      return .purple
        case .preferNotToSay: return .gray
        }
    }
}

enum OnboardingClimate: String, CaseIterable {
    case veryHot, hot, moderate, cold, veryCold

    var label: String {
        switch self {
        case .veryHot:  return "Very Hot"
        case .hot:      return "Hot"
        case .moderate: return "Moderate"
        case .cold:     return "Cold"
        case .veryCold: return "Very Cold"
        }
    }
    var subtitle: String {
        switch self {
        case .veryHot:  return "35°C+ / 95°F+ — Desert or tropical"
        case .hot:      return "25–35°C / 77–95°F — Warm summers"
        case .moderate: return "15–25°C / 59–77°F — Comfortable year-round"
        case .cold:     return "5–15°C / 41–59°F — Cool or rainy"
        case .veryCold: return "Below 5°C / 41°F — Snow & frost"
        }
    }
    var icon: String {
        switch self {
        case .veryHot:  return "sun.max.fill"
        case .hot:      return "sun.haze.fill"
        case .moderate: return "cloud.sun.fill"
        case .cold:     return "cloud.rain.fill"
        case .veryCold: return "snowflake"
        }
    }
    var color: Color {
        switch self {
        case .veryHot:  return .orange
        case .hot:      return .yellow
        case .moderate: return .blue
        case .cold:     return .cyan
        case .veryCold: return .indigo
        }
    }
}

enum OnboardingActivity: String, CaseIterable {
    case sedentary, light, moderate, active, veryActive

    var label: String {
        switch self {
        case .sedentary:  return "Sedentary"
        case .light:      return "Light"
        case .moderate:   return "Moderate"
        case .active:     return "Active"
        case .veryActive: return "Very Active"
        }
    }
    var subtitle: String {
        switch self {
        case .sedentary:  return "Mostly sitting, desk job"
        case .light:      return "Light walks, some movement"
        case .moderate:   return "Exercise 3–4× per week"
        case .active:     return "Daily exercise, physical job"
        case .veryActive: return "Intense training every day"
        }
    }
    var icon: String {
        switch self {
        case .sedentary:  return "laptopcomputer"
        case .light:      return "figure.walk"
        case .moderate:   return "figure.run"
        case .active:     return "dumbbell.fill"
        case .veryActive: return "flame.fill"
        }
    }
    var color: Color {
        switch self {
        case .sedentary:  return .secondary
        case .light:      return .blue
        case .moderate:   return .cyan
        case .active:     return .green
        case .veryActive: return .orange
        }
    }
}

// MARK: - OnboardingView

struct OnboardingView: View {
    var onComplete: () -> Void

    // Navigation
    @State private var step: Int = 0
    private let totalSteps = 8

    // Profile inputs
    @State private var gender: OnboardingGender = .male
    @State private var age: Int = 25
    @State private var heightCM: Int = 170
    @State private var weightKG: Double = 70.0
    @State private var isMetric: Bool = true
    @State private var climate: OnboardingClimate = .moderate
    @State private var activity: OnboardingActivity = .moderate

    // Goal reveal
    @State private var recommendedGlasses: Int = 8
    @State private var finalGoal: Int = 8

    // Notifications
    @State private var notificationsGranted: Bool = false

    // MARK: Body

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.12), Color.cyan.opacity(0.06)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                progressHeader
                    .padding(.horizontal, 24)
                    .padding(.top, 52)
                    .padding(.bottom, 16)

                Group {
                    switch step {
                    case 0: welcomeStep
                    case 1: genderStep
                    case 2: ageStep
                    case 3: bodyStep
                    case 4: climateStep
                    case 5: activityStep
                    case 6: goalRevealStep
                    case 7: notificationStep
                    default: welcomeStep
                    }
                }
                .id(step)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal:   .move(edge: .leading).combined(with: .opacity)
                ))
                .animation(.easeInOut(duration: 0.32), value: step)
            }
        }
    }

    // MARK: - Progress Header

    private var progressHeader: some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.blue.opacity(0.12))
                        .frame(height: 4)
                    Capsule()
                        .fill(LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .leading, endPoint: .trailing
                        ))
                        .frame(
                            width: max(8, geo.size.width * CGFloat(step) / CGFloat(totalSteps - 1)),
                            height: 4
                        )
                        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: step)
                }
            }
            .frame(height: 4)

            HStack {
                if step > 0 {
                    Button(action: { withAnimation { step -= 1 } }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(.blue)
                    }
                } else {
                    Color.clear.frame(width: 50, height: 1)
                }
                Spacer()
                Text("Step \(step + 1) of \(totalSteps)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Step 0: Welcome

    private var welcomeStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                Spacer(minLength: 16)

                ZStack {
                    Circle()
                        .fill(Color.cyan.opacity(0.1))
                        .frame(width: 150, height: 150)
                    Image(systemName: "drop.fill")
                        .font(.system(size: 76))
                        .foregroundStyle(
                            LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom)
                        )
                }

                VStack(spacing: 14) {
                    Text("Bottle of Water")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("Let's build your personal hydration plan.\nWe'll ask a few questions to get it right.")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                VStack(spacing: 10) {
                    featurePill(icon: "person.fill",     text: "Personalized for your body & age")
                    featurePill(icon: "cloud.sun.fill",  text: "Adjusted for your climate")
                    featurePill(icon: "flame.fill",      text: "Tuned to your activity level")
                    featurePill(icon: "bell.fill",       text: "Smart reminders at the right moments")
                }
                .padding(.horizontal, 4)

                primaryButton(title: "Get Started") {
                    withAnimation { step = 1 }
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Step 1: Gender

    private var genderStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                stepHeader(
                    icon: "person.fill", iconColor: .blue,
                    title: "Tell us about yourself",
                    subtitle: "Gender helps fine-tune your baseline hydration amount."
                )

                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                    spacing: 12
                ) {
                    ForEach(OnboardingGender.allCases, id: \.self) { g in
                        selectionCard(
                            isSelected: gender == g,
                            icon: g.icon, iconColor: g.color,
                            title: g.label, subtitle: nil
                        ) { withAnimation(.easeInOut(duration: 0.15)) { gender = g } }
                    }
                }
                .padding(.horizontal, 24)

                primaryButton(title: "Continue") {
                    withAnimation { step = 2 }
                }
                Spacer(minLength: 40)
            }
        }
    }

    // MARK: - Step 2: Age

    private var ageStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                stepHeader(
                    icon: "calendar.circle.fill", iconColor: .cyan,
                    title: "How old are you?",
                    subtitle: "Age affects daily hydration requirements, especially for younger and older adults."
                )

                HStack(spacing: 36) {
                    Button(action: { if age > 10 { age -= 1 } }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(age > 10 ? .blue : .blue.opacity(0.2))
                    }
                    .disabled(age <= 10)

                    VStack(spacing: 4) {
                        Text("\(age)")
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                            .contentTransition(.numericText())
                            .animation(.spring(response: 0.28), value: age)
                        Text("years old")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .frame(minWidth: 90)

                    Button(action: { if age < 99 { age += 1 } }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(age < 99 ? .blue : .blue.opacity(0.2))
                    }
                    .disabled(age >= 99)
                }
                .padding(28)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.blue.opacity(0.06))
                        .overlay(RoundedRectangle(cornerRadius: 22)
                            .stroke(Color.blue.opacity(0.12), lineWidth: 1))
                )
                .padding(.horizontal, 24)

                if age < 18 {
                    infoNote(icon: "info.circle.fill",
                             text: "Young people need slightly more water relative to body weight — we'll account for this.",
                             color: .blue)
                    .padding(.horizontal, 24)
                } else if age >= 60 {
                    infoNote(icon: "heart.fill",
                             text: "Older adults often have a reduced sense of thirst. Regular reminders help a lot!",
                             color: .cyan)
                    .padding(.horizontal, 24)
                }

                primaryButton(title: "Continue") {
                    withAnimation { step = 3 }
                }
                Spacer(minLength: 40)
            }
        }
    }

    // MARK: - Step 3: Body (Height + Weight)

    private var bodyStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                stepHeader(
                    icon: "figure.arms.open", iconColor: .purple,
                    title: "Your body",
                    subtitle: "Weight is the primary factor in calculating your daily water needs."
                )

                Picker("Units", selection: $isMetric) {
                    Text("Metric (cm, kg)").tag(true)
                    Text("Imperial (ft, lbs)").tag(false)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 24)

                // Height
                measureCard(
                    icon: "ruler.fill", iconColor: .blue,
                    label: "Height", valueText: heightDisplay,
                    canMinus: heightCM > 100, canPlus: heightCM < 230,
                    onMinus: { if heightCM > 100 { heightCM -= 1 } },
                    onPlus:  { if heightCM < 230 { heightCM += 1 } }
                )
                .padding(.horizontal, 24)

                // Weight
                measureCard(
                    icon: "scalemass.fill", iconColor: .cyan,
                    label: "Weight", valueText: weightDisplay,
                    canMinus: weightKG > 30, canPlus: weightKG < 200,
                    onMinus: { if weightKG > 30  { weightKG = max(30,  weightKG - weightStep) } },
                    onPlus:  { if weightKG < 200 { weightKG = min(200, weightKG + weightStep) } }
                )
                .padding(.horizontal, 24)

                infoNote(icon: "drop.fill",
                         text: "Science-backed formula: weight (kg) × 0.033 = daily water need in litres.",
                         color: .blue)
                .padding(.horizontal, 24)

                primaryButton(title: "Continue") {
                    withAnimation { step = 4 }
                }
                Spacer(minLength: 40)
            }
        }
    }

    // MARK: - Step 4: Climate

    private var climateStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                stepHeader(
                    icon: "thermometer.medium", iconColor: .orange,
                    title: "Where do you live?",
                    subtitle: "Hot climates can double your daily water needs through sweat and heat."
                )

                VStack(spacing: 10) {
                    ForEach(OnboardingClimate.allCases, id: \.self) { c in
                        selectionCard(
                            isSelected: climate == c,
                            icon: c.icon, iconColor: c.color,
                            title: c.label, subtitle: c.subtitle
                        ) { withAnimation(.easeInOut(duration: 0.15)) { climate = c } }
                    }
                }
                .padding(.horizontal, 24)

                primaryButton(title: "Continue") {
                    withAnimation { step = 5 }
                }
                Spacer(minLength: 40)
            }
        }
    }

    // MARK: - Step 5: Activity Level

    private var activityStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                stepHeader(
                    icon: "figure.run", iconColor: .green,
                    title: "How active are you?",
                    subtitle: "Physical activity significantly increases water lost through sweat."
                )

                VStack(spacing: 10) {
                    ForEach(OnboardingActivity.allCases, id: \.self) { a in
                        selectionCard(
                            isSelected: activity == a,
                            icon: a.icon, iconColor: a.color,
                            title: a.label, subtitle: a.subtitle
                        ) { withAnimation(.easeInOut(duration: 0.15)) { activity = a } }
                    }
                }
                .padding(.horizontal, 24)

                primaryButton(title: "Calculate my goal") {
                    let result = calculateRecommendation()
                    recommendedGlasses = result.glasses
                    finalGoal = result.glasses
                    withAnimation { step = 6 }
                }
                Spacer(minLength: 40)
            }
        }
    }

    // MARK: - Step 6: Goal Reveal

    private var goalRevealStep: some View {
        let result = calculateRecommendation()

        return ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                VStack(spacing: 6) {
                    Text("Your personalized goal")
                        .font(.system(size: 23, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("Based on your body, climate & lifestyle")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)

                // Big goal circle
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color.cyan.opacity(0.12), Color.blue.opacity(0.08)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 188, height: 188)
                    Circle()
                        .stroke(
                            LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 3
                        )
                        .frame(width: 188, height: 188)
                    VStack(spacing: 4) {
                        Text("\(finalGoal)")
                            .font(.system(size: 66, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom)
                            )
                            .contentTransition(.numericText())
                            .animation(.spring(response: 0.3), value: finalGoal)
                        Text("glasses / day")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                        Text("≈ \(finalGoal * WaterGoalStore.glassVolume) ml")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                }

                // Adjust +/-
                HStack(spacing: 28) {
                    Button(action: { if finalGoal > 4  { finalGoal -= 1 } }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(finalGoal > 4  ? .blue : .blue.opacity(0.2))
                    }
                    .disabled(finalGoal <= 4)

                    Text("Fine-tune")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)

                    Button(action: { if finalGoal < 20 { finalGoal += 1 } }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(finalGoal < 20 ? .blue : .blue.opacity(0.2))
                    }
                    .disabled(finalGoal >= 20)
                }

                // Breakdown card
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 8) {
                        Image(systemName: "function")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.blue)
                        Text("How we calculated this")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 12)

                    ForEach(result.items.indices, id: \.self) { i in
                        let item = result.items[i]
                        HStack(alignment: .center) {
                            Text(item.label)
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(item.isAddition ? "+" : "−")\(item.value) glass\(item.value == 1 ? "" : "es")")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(item.isAddition ? .blue : .orange)
                        }
                        .padding(.vertical, 8)

                        if i < result.items.count - 1 {
                            Divider()
                        }
                    }

                    Divider().padding(.vertical, 2)

                    HStack {
                        Text("Recommended")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                        Spacer()
                        Text("\(recommendedGlasses) glasses/day")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 6)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.blue.opacity(0.05))
                        .overlay(RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.blue.opacity(0.12), lineWidth: 1))
                )
                .padding(.horizontal, 24)

                if finalGoal != recommendedGlasses {
                    infoNote(
                        icon: "lightbulb.fill",
                        text: "You've adjusted from the recommendation (\(recommendedGlasses)). You can always change this later in the Calendar tab.",
                        color: .orange
                    )
                    .padding(.horizontal, 24)
                }

                primaryButton(title: "Set this as my goal") {
                    WaterGoalStore.setGoal(finalGoal, for: Date())
                    saveProfile()
                    withAnimation { step = 7 }
                }
                Spacer(minLength: 40)
            }
        }
    }

    // MARK: - Step 7: Notifications

    private var notificationStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                Spacer(minLength: 12)

                ZStack {
                    Circle()
                        .fill(notificationsGranted ? Color.green.opacity(0.12) : Color.orange.opacity(0.1))
                        .frame(width: 124, height: 124)
                        .animation(.easeInOut(duration: 0.3), value: notificationsGranted)
                    Image(systemName: notificationsGranted ? "bell.badge.fill" : "bell.fill")
                        .font(.system(size: 58))
                        .foregroundColor(notificationsGranted ? .green : .orange)
                        .animation(.spring(), value: notificationsGranted)
                }

                VStack(spacing: 10) {
                    Text("Stay reminded")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("Get gentle nudges at the right moments—morning, after coffee, before bed, and more. Fully configurable.")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 8)
                }
                .padding(.horizontal, 24)

                if notificationsGranted {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                        Text("Notifications enabled!")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.green.opacity(0.1)))
                    .transition(.scale.combined(with: .opacity))
                }

                VStack(spacing: 12) {
                    if !notificationsGranted {
                        primaryButton(title: "Enable Notifications") {
                            NotificationManager.requestPermission { granted in
                                withAnimation { notificationsGranted = granted }
                                if granted {
                                    NotificationManager.scheduleRoutineNotifications(
                                        routines: RoutinesStore.routines
                                    )
                                }
                            }
                        }
                    }

                    Button(action: finishOnboarding) {
                        Text(notificationsGranted ? "Start Tracking! 💧" : "Skip for now")
                            .font(.system(size: 16,
                                          weight: notificationsGranted ? .bold : .medium,
                                          design: .rounded))
                            .foregroundColor(notificationsGranted ? .white : .secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(notificationsGranted ? Color.blue : Color.secondary.opacity(0.12))
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 24)
                    .animation(.easeInOut(duration: 0.25), value: notificationsGranted)
                }

                Spacer(minLength: 40)
            }
        }
        .onAppear {
            NotificationManager.checkPermissionStatus { status in
                notificationsGranted = (status == .authorized)
            }
        }
    }

    // MARK: - Reusable Components

    @ViewBuilder
    private func stepHeader(icon: String, iconColor: Color, title: String, subtitle: String) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle().fill(iconColor.opacity(0.1)).frame(width: 100, height: 100)
                Image(systemName: icon)
                    .font(.system(size: 46))
                    .foregroundColor(iconColor)
            }
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 24)
            }
        }
    }

    @ViewBuilder
    private func selectionCard(
        isSelected: Bool,
        icon: String, iconColor: Color,
        title: String, subtitle: String?,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(isSelected ? 0.18 : 0.08))
                        .frame(width: 46, height: 46)
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(iconColor)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                Spacer(minLength: 0)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? iconColor : Color.secondary.opacity(0.3))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? iconColor.opacity(0.07) : Color.gray.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                isSelected ? iconColor.opacity(0.3) : Color.gray.opacity(0.15),
                                lineWidth: 1.2
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func measureCard(
        icon: String, iconColor: Color,
        label: String, valueText: String,
        canMinus: Bool, canPlus: Bool,
        onMinus: @escaping () -> Void,
        onPlus:  @escaping () -> Void
    ) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: icon).font(.system(size: 17)).foregroundColor(iconColor)
                Text(label)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
                Text(valueText)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(iconColor)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.25), value: valueText)
            }
            HStack {
                Button(action: onMinus) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 38))
                        .foregroundColor(canMinus ? iconColor : iconColor.opacity(0.2))
                }
                .disabled(!canMinus)
                Spacer()
                Button(action: onPlus) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 38))
                        .foregroundColor(canPlus ? iconColor : iconColor.opacity(0.2))
                }
                .disabled(!canPlus)
            }
            .padding(.horizontal, 20)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(iconColor.opacity(0.06))
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .stroke(iconColor.opacity(0.15), lineWidth: 1))
        )
    }

    @ViewBuilder
    private func infoNote(icon: String, text: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
            Text(text)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.06))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(color.opacity(0.15), lineWidth: 1))
        )
    }

    @ViewBuilder
    private func featurePill(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.blue)
                .frame(width: 30, height: 30)
                .background(Circle().fill(Color.blue.opacity(0.1)))
            Text(text)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.blue.opacity(0.1), lineWidth: 1))
        )
    }

    private func primaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(LinearGradient(colors: [.cyan, .blue],
                                            startPoint: .leading, endPoint: .trailing))
                )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 24)
    }

    // MARK: - Display helpers

    private var heightDisplay: String {
        if isMetric { return "\(heightCM) cm" }
        let totalInches = Double(heightCM) / 2.54
        let ft = Int(totalInches / 12)
        let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
        return "\(ft)' \(inches)\""
    }

    private var weightDisplay: String {
        isMetric
            ? String(format: "%.1f kg", weightKG)
            : "\(Int((weightKG * 2.20462).rounded())) lbs"
    }

    private var weightStep: Double { isMetric ? 0.5 : 0.454 }

    // MARK: - Recommendation engine

    private struct BreakdownItem {
        let label: String
        let value: Int       // always positive; sign is expressed by isAddition
        let isAddition: Bool
    }

    private func calculateRecommendation() -> (glasses: Int, items: [BreakdownItem]) {
        let glassML = Double(WaterGoalStore.glassVolume)
        var totalLiters = 0.0
        var items: [BreakdownItem] = []

        // 1. Base from weight (main driver)
        let baseLiters = weightKG * 0.033
        totalLiters += baseLiters
        let baseG = max(1, Int((baseLiters * 1000 / glassML).rounded()))
        items.append(BreakdownItem(label: "Body weight (\(Int(weightKG)) kg)", value: baseG, isAddition: true))

        // 2. Gender
        let genderExtra: Double
        switch gender {
        case .male:           genderExtra = 0.35
        case .female:         genderExtra = 0.0
        case .nonBinary:      genderExtra = 0.15
        case .preferNotToSay: genderExtra = 0.0
        }
        if genderExtra > 0 {
            totalLiters += genderExtra
            let g = max(1, Int((genderExtra * 1000 / glassML).rounded()))
            items.append(BreakdownItem(label: "Gender (\(gender.label))", value: g, isAddition: true))
        }

        // 3. Age adjustment
        let ageExtra: Double
        if      age < 18  { ageExtra =  0.2 }
        else if age >= 60 { ageExtra =  0.3 }
        else              { ageExtra =  0.0 }
        if ageExtra != 0 {
            totalLiters += ageExtra
            let g = max(1, Int((abs(ageExtra) * 1000 / glassML).rounded()))
            items.append(BreakdownItem(label: "Age (\(age))", value: g, isAddition: ageExtra > 0))
        }

        // 4. Climate
        let climateExtra: Double
        switch climate {
        case .veryHot:  climateExtra =  1.0
        case .hot:      climateExtra =  0.5
        case .moderate: climateExtra =  0.0
        case .cold:     climateExtra = -0.2
        case .veryCold: climateExtra = -0.4
        }
        if climateExtra != 0 {
            totalLiters += climateExtra
            let g = max(1, Int((abs(climateExtra) * 1000 / glassML).rounded()))
            items.append(BreakdownItem(label: "Climate (\(climate.label))", value: g, isAddition: climateExtra > 0))
        }

        // 5. Activity level
        let activityExtra: Double
        switch activity {
        case .sedentary:  activityExtra = 0.0
        case .light:      activityExtra = 0.3
        case .moderate:   activityExtra = 0.6
        case .active:     activityExtra = 0.9
        case .veryActive: activityExtra = 1.2
        }
        if activityExtra > 0 {
            totalLiters += activityExtra
            let g = max(1, Int((activityExtra * 1000 / glassML).rounded()))
            items.append(BreakdownItem(label: "Activity (\(activity.label))", value: g, isAddition: true))
        }

        let glasses = max(4, min(20, Int((totalLiters * 1000 / glassML).rounded())))
        return (glasses, items)
    }

    // MARK: - Save & finish

    private func saveProfile() {
        let d = UserDefaults.standard
        d.set(gender.rawValue,   forKey: "profile_gender")
        d.set(age,               forKey: "profile_age")
        d.set(heightCM,          forKey: "profile_heightCM")
        d.set(weightKG,          forKey: "profile_weightKG")
        d.set(climate.rawValue,  forKey: "profile_climate")
        d.set(activity.rawValue, forKey: "profile_activityLevel")
    }

    private func finishOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        onComplete()
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
