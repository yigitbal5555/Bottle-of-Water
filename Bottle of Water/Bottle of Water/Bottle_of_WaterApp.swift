//
//  Bottle_of_WaterApp.swift
//  Bottle of Water
//
//  Created by Yiğit Bal on 8.01.2026.
//

import SwiftUI
import UserNotifications

@main
struct Bottle_of_WaterApp: App {
    @State private var hasCompletedOnboarding: Bool =
        UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    @State private var showLaunchScreen: Bool = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Main content underneath
                if hasCompletedOnboarding {
                    RootView()
                        .onAppear {
                            NotificationManager.checkPermissionStatus { status in
                                if status == .authorized {
                                    NotificationManager.scheduleRoutineNotifications(
                                        routines: RoutinesStore.routines
                                    )
                                }
                            }
                        }
                } else {
                    OnboardingView {
                        hasCompletedOnboarding = true
                    }
                }

                // Launch screen fades out on top
                if showLaunchScreen {
                    LaunchScreenView {
                        withAnimation(.easeInOut(duration: 0.45)) {
                            showLaunchScreen = false
                        }
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
        }
    }
}
