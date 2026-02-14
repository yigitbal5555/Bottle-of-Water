//
//  HeaderView.swift
//  Bottle of Water
//
//  Created by Yiğit Bal on 8.01.2026.
//

import SwiftUI

struct HeaderView: View {
    var onSettingsTap: (() -> Void)? = nil
    var onNotificationsTap: (() -> Void)? = nil
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        case 17..<22:
            return "Good Evening"
        default:
            return "Good Night"
        }
    }
    
    var greetingIcon: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "sunrise.fill"
        case 12..<17:
            return "sun.max.fill"
        case 17..<22:
            return "sunset.fill"
        default:
            return "moon.fill"
        }
    }
    
    private let adviceSentences: [String] = [
        "Start your day with a glass of water.",
        "Your body works better when you stay hydrated.",
        "Drink water before you feel thirsty.",
        "A sip now can prevent dehydration later.",
        "Water helps keep your energy steady.",
        "Hydration improves focus and clarity.",
        "Keep water close, keep yourself healthy.",
        "Drinking water supports your metabolism.",
        "Make water your first choice, not soda.",
        "A hydrated body is a happy body.",
        "Drink water to support your digestion.",
        "Water helps flush out toxins naturally.",
        "Stay hydrated to reduce fatigue.",
        "Your brain loves water—feed it often.",
        "Drink water during breaks to recharge.",
        "Hydration helps regulate body temperature.",
        "Water keeps your joints moving smoothly.",
        "A small sip is better than none.",
        "Drink water after every meal.",
        "Hydration supports better sleep quality.",
        "Water keeps your skin fresh and healthy.",
        "Make hydration a daily habit.",
        "Drinking water boosts overall wellness.",
        "Listen to your body—drink water.",
        "Hydration helps prevent headaches.",
        "Water improves concentration and memory.",
        "Take a sip and refresh your mind.",
        "Water fuels your body naturally.",
        "Drink water before and after exercise.",
        "Hydration helps balance your mood.",
        "Your muscles need water to work well.",
        "Choose water to stay energized longer.",
        "A bottle nearby means fewer reminders.",
        "Drink water, feel the difference.",
        "Hydration supports heart health.",
        "Water helps you feel lighter and fresher.",
        "Drink water to stay alert.",
        "Hydration keeps your body in balance.",
        "A healthy day starts with water.",
        "Drink water even on busy days.",
        "Water is the simplest self-care.",
        "Hydration keeps you moving forward.",
        "Drink water to support immunity.",
        "Every sip counts toward better health.",
        "Water helps your body recover faster.",
        "Stay hydrated, stay active.",
        "Water is essential, not optional.",
        "Drink water and treat yourself well.",
        "Hydration is a daily investment."
    ]
    
    var dailyAdvice: String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return adviceSentences[day % adviceSentences.count]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                HStack(spacing: 6) {
                    Text(greeting)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Image(systemName: greetingIcon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                Button(action: { onNotificationsTap?() }) {
                    Image(systemName: "bell")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                Button(action: { onSettingsTap?() }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.secondary)
                }
            }
            }
            
            Text(dailyAdvice)
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(.secondary.opacity(0.9))
                .lineLimit(2)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}
