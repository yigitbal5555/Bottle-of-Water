//
//  OnboardingView.swift
//  Bottle of Water
//
//  Created by Yiğit Bal on 8.01.2026.
//

import SwiftUI

struct OnboardingView: View {
    var onComplete: () -> Void

    @State private var step: Int = 0
    @State private var dailyGoal: Int = 8
    @State private var notificationsGranted: Bool = false
    @State private var notificationStatusChecked: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.12), Color.cyan.opacity(0.06)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress dots
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { i in
                        Capsule()
                            .fill(i <= step ? Color.blue : Color.blue.opacity(0.2))
                            .frame(width: i == step ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.4), value: step)
                    }
                }
                .padding(.top, 60)
                .padding(.bottom, 32)

                Group {
                    switch step {
                    case 0: welcomeStep
                    case 1: goalStep
                    case 2: notificationStep
                    default: welcomeStep
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .animation(.easeInOut(duration: 0.35), value: step)

                Spacer()
            }
        }
    }

    // MARK: - Step 0: Welcome

    private var welcomeStep: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(Color.cyan.opacity(0.12))
                    .frame(width: 140, height: 140)
                Image(systemName: "drop.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(
                        LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom)
                    )
            }

            VStack(spacing: 12) {
                Text("Bottle of Water")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text("Your gentle hydration companion.\nTrack water, balance coffee, feel great.")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 24)

            primaryButton(title: "Get Started") {
                withAnimation { step = 1 }
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Step 1: Daily Goal

    private var goalStep: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 120, height: 120)
                Image(systemName: "target")
                    .font(.system(size: 56))
                    .foregroundColor(.blue)
            }

            VStack(spacing: 10) {
                Text("Set your daily goal")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text("How many glasses of water do you want to drink each day?")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .padding(.horizontal, 24)

            // Goal stepper
            HStack(spacing: 32) {
                Button(action: {
                    if dailyGoal > 1 { dailyGoal -= 1 }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(dailyGoal > 1 ? .blue : .blue.opacity(0.3))
                }
                .disabled(dailyGoal <= 1)

                VStack(spacing: 4) {
                    Text("\(dailyGoal)")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.3), value: dailyGoal)
                    Text("glasses / day")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    Text("≈ \(dailyGoal * WaterGoalStore.glassVolume) ml")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary.opacity(0.8))
                }

                Button(action: {
                    if dailyGoal < 20 { dailyGoal += 1 }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(dailyGoal < 20 ? .blue : .blue.opacity(0.3))
                }
                .disabled(dailyGoal >= 20)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.blue.opacity(0.07))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.blue.opacity(0.15), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)

            primaryButton(title: "Continue") {
                WaterGoalStore.setGoal(dailyGoal, for: Date())
                withAnimation { step = 2 }
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Step 2: Notifications

    private var notificationStep: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(notificationsGranted ? Color.green.opacity(0.12) : Color.orange.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .animation(.easeInOut, value: notificationsGranted)

                Image(systemName: notificationsGranted ? "bell.badge.fill" : "bell.fill")
                    .font(.system(size: 56))
                    .foregroundColor(notificationsGranted ? .green : .orange)
                    .animation(.spring(), value: notificationsGranted)
            }

            VStack(spacing: 10) {
                Text("Stay reminded")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text("Get gentle notifications at the right moments—morning, after coffee, before bed, and more.")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .padding(.horizontal, 24)

            if notificationsGranted {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Notifications enabled!")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.1))
                )
            }

            VStack(spacing: 12) {
                if !notificationsGranted {
                    primaryButton(title: "Enable Notifications") {
                        NotificationManager.requestPermission { granted in
                            notificationsGranted = granted
                            if granted {
                                NotificationManager.scheduleRoutineNotifications(
                                    routines: RoutinesStore.routines
                                )
                            }
                        }
                    }
                }

                Button(action: finishOnboarding) {
                    Text(notificationsGranted ? "Start Tracking!" : "Skip for now")
                        .font(.system(size: 16, weight: notificationsGranted ? .bold : .medium, design: .rounded))
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
            }
        }
        .padding(.horizontal, 24)
        .onAppear {
            NotificationManager.checkPermissionStatus { status in
                notificationsGranted = (status == .authorized)
            }
        }
    }

    // MARK: - Helpers

    private func primaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 24)
    }

    private func finishOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        onComplete()
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
