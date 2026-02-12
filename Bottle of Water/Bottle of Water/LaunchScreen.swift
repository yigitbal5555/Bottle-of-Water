//
//  LaunchScreen.swift
//  Bottle of Water
//
//  Created by Yiğit Bal on 8.01.2026.
//

import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.2), Color.cyan.opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.cyan)
                
                Text("Bottle of Water")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}
