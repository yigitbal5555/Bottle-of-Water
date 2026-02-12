//
//  Bottle_of_WaterApp.swift
//  Bottle of Water
//
//  Created by Yiğit Bal on 8.01.2026.
//

import SwiftUI

@main
struct Bottle_of_WaterApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct MainView: View {
    var body: some View {
        VStack {
            Image("bottle")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .foregroundStyle(.tint)
            
            Text("Bottle of Water")
        }
        .padding()
    }
}
