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

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                RootView()
                    .onAppear {
                        // Re-schedule notifications in case they were cleared
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
        }
    }
}
