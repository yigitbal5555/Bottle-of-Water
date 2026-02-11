//
//  CustomTabBar.swift
//  Bottle of Water
//
//  Created by Yiğit Bal on 8.01.2026.
//

import SwiftUI

enum TabItem: String, CaseIterable {
    case home = "Home"
    case calendar = "Calendar"
    case limitize = "Limitize"
    case statistics = "Statistics"
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .calendar: return "calendar"
        case .limitize: return "target"
        case .statistics: return "chart.bar.fill"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: TabItem
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Liquid Glass Background with animated blobs
            LiquidGlassBackground(offset: animationOffset)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 3)
                .shadow(color: Color.white.opacity(0.2), radius: 2, x: 0, y: -1)
            
            // Tab Bar Content
            HStack(spacing: 0) {
                ForEach(TabItem.allCases, id: \.self) { tab in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 22, weight: selectedTab == tab ? .semibold : .regular))
                                .foregroundColor(selectedTab == tab ? .blue : .gray)
                            
                            Text(tab.rawValue)
                                .font(.system(size: 10, weight: selectedTab == tab ? .semibold : .regular, design: .rounded))
                                .foregroundColor(selectedTab == tab ? .blue : .gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedTab == tab ? Color.blue.opacity(0.15) : Color.clear)
                        )
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(height: 70)
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: true)) {
                animationOffset = 100
            }
        }
    }
}

// MARK: - Liquid Glass Background
struct LiquidGlassBackground: View {
    let offset: CGFloat
    
    var body: some View {
        ZStack {
            // Base blur layer
            Rectangle()
                .fill(.ultraThinMaterial)
            
            // Animated liquid blobs
            GeometryReader { geometry in
                ZStack {
                    // Blob 1 - Top left
                    LiquidBlob(offset: offset, delay: 0)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.blue.opacity(0.2),
                                    Color.cyan.opacity(0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: geometry.size.width * 0.6, height: geometry.size.height * 0.5)
                        .offset(x: -geometry.size.width * 0.2, y: -geometry.size.height * 0.2)
                        .blur(radius: 15)
                    
                    // Blob 2 - Bottom right
                    LiquidBlob(offset: -offset, delay: 2)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.cyan.opacity(0.2),
                                    Color.blue.opacity(0.15)
                                ],
                                startPoint: .bottomTrailing,
                                endPoint: .topLeading
                            )
                        )
                        .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.6)
                        .offset(x: geometry.size.width * 0.15, y: geometry.size.height * 0.15)
                        .blur(radius: 20)
                    
                    // Blob 3 - Center
                    LiquidBlob(offset: offset * 0.7, delay: 1)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .center,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.4)
                        .offset(x: geometry.size.width * 0.25, y: geometry.size.height * 0.3)
                        .blur(radius: 12)
                }
            }
            
            // Glass overlay effect
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.4),
                            Color.white.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Highlight on top
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.8),
                            Color.white.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        }
    }
}

// MARK: - Liquid Blob Shape
struct LiquidBlob: Shape {
    var offset: CGFloat
    var delay: CGFloat
    
    var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let centerX = width / 2
        let centerY = height / 2
        
        // Create organic blob shape with animated curves
        let wave1 = sin(offset * 0.01 + delay) * 30
        let wave2 = cos(offset * 0.015 + delay) * 25
        let wave3 = sin(offset * 0.02 + delay * 1.5) * 20
        
        path.move(to: CGPoint(x: centerX, y: 0))
        
        // Top curve
        path.addCurve(
            to: CGPoint(x: width, y: centerY * 0.5),
            control1: CGPoint(x: centerX + wave1, y: height * 0.2),
            control2: CGPoint(x: width - 20 + wave2, y: height * 0.3)
        )
        
        // Right curve
        path.addCurve(
            to: CGPoint(x: width * 0.7, y: height),
            control1: CGPoint(x: width - 10 + wave3, y: centerY + wave1),
            control2: CGPoint(x: width * 0.8 + wave2, y: height - 30)
        )
        
        // Bottom curve
        path.addCurve(
            to: CGPoint(x: centerX * 0.3, y: height * 0.8),
            control1: CGPoint(x: centerX + wave1, y: height - 20 + wave3),
            control2: CGPoint(x: centerX * 0.5 + wave2, y: height * 0.9)
        )
        
        // Left curve
        path.addCurve(
            to: CGPoint(x: 0, y: centerY),
            control1: CGPoint(x: centerX * 0.2 + wave3, y: centerY + wave1),
            control2: CGPoint(x: 10 + wave2, y: centerY * 0.7)
        )
        
        // Top left curve back to start
        path.addCurve(
            to: CGPoint(x: centerX, y: 0),
            control1: CGPoint(x: centerX * 0.3 + wave1, y: centerY * 0.3 + wave3),
            control2: CGPoint(x: centerX - wave2, y: height * 0.1)
        )
        
        path.closeSubpath()
        
        return path
    }
}