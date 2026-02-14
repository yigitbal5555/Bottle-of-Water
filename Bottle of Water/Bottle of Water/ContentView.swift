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
    @State private var showSettings = false
    @State private var showWaterMoments = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.cyan.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HeaderView(
                    onSettingsTap: { showSettings = true },
                    onNotificationsTap: { showWaterMoments = true }
                )

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
        .sheet(isPresented: $showSettings) {
            SettingsView(onDismiss: { showSettings = false })
        }
        .sheet(isPresented: $showWaterMoments) {
            WaterMomentsView(onDismiss: { showWaterMoments = false })
        }
    }
}

// MARK: - Daily Water Goal Store (persisted per-date goals)

struct WaterGoalStore {
    private static let prefix = "dailyWaterGoal_"
    private static let defaultGlasses = 8
    private static let glassVolumeML = 250
    
    static func key(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return prefix + formatter.string(from: Calendar.current.startOfDay(for: date))
    }
    
    static func goal(for date: Date) -> Int {
        let value = UserDefaults.standard.object(forKey: key(for: date)) as? Int
        return value ?? defaultGlasses
    }
    
    static func setGoal(_ glasses: Int, for date: Date) {
        let clamped = max(1, min(20, glasses))
        UserDefaults.standard.set(clamped, forKey: key(for: date))
        NotificationCenter.default.post(name: .waterGoalDidChange, object: nil)
    }
    
    static var glassVolume: Int { glassVolumeML }
}

extension Notification.Name {
    static let waterGoalDidChange = Notification.Name("waterGoalDidChange")
    static let waterIntakeDidChange = Notification.Name("waterIntakeDidChange")
}

// MARK: - Home

struct HomeView: View {
    @State private var todayGoal: Int = WaterGoalStore.goal(for: Date())
    @State private var todayGlasses: Int = WaterIntakeStore.glasses(for: Date())
    @State private var lastLogHaptic = Date()
    @State private var showFeelingSheet = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Bottle of Water")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Tap mascot or use +1 button to log water
                WaterDropCharacterView(
                    currentGlasses: todayGlasses,
                    goalGlasses: todayGoal,
                    onLogWater: logWater
                )
                .frame(width: 220, height: 320)
                .frame(maxWidth: .infinity)
                
                // Progress counter + One-tap add button
                HStack(spacing: 16) {
                    ProgressCounterBadge(current: todayGlasses, goal: todayGoal)
                    Button(action: logWater) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                            Text("Add glass")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.cyan, Color.blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 8)
                
                // How do you feel? (body-based guidance)
                Button(action: { showFeelingSheet = true }) {
                    HStack(spacing: 10) {
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.pink.opacity(0.8))
                        Text("How do you feel?")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.pink.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.pink.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
                .padding(.top, 12)
                
                Spacer(minLength: 24)
            }
            .padding()
            .padding(.top, 20)
        }
        .onAppear {
            todayGoal = WaterGoalStore.goal(for: Date())
            todayGlasses = WaterIntakeStore.glasses(for: Date())
        }
        .onReceive(NotificationCenter.default.publisher(for: .waterGoalDidChange)) { _ in
            todayGoal = WaterGoalStore.goal(for: Date())
        }
        .onReceive(NotificationCenter.default.publisher(for: .waterIntakeDidChange)) { _ in
            todayGlasses = WaterIntakeStore.glasses(for: Date())
        }
        .sheet(isPresented: $showFeelingSheet) {
            BodyFeelingSheet(onDismiss: { showFeelingSheet = false })
        }
    }
    
    private func logWater() {
        WaterIntakeStore.addGlass(for: Date())
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

// MARK: - Progress Counter Badge (current / goal on Home)

struct ProgressCounterBadge: View {
    let current: Int
    let goal: Int
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "drop.fill")
                .font(.system(size: 18))
                .foregroundColor(.cyan)
            Text("\(current) / \(goal)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.blue)
            Text("glasses")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
            Text("(≈ \(goal * WaterGoalStore.glassVolume) ml goal)")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.blue.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Calendar

struct CalendarView: View {
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var goalForSelectedDate: Int = 8
    
    private let calendar = Calendar.current
    private let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private let glassVolumeML = 250
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                Text("Calendar")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Calendar card
                VStack(spacing: 16) {
                    // Month navigation
                    HStack {
                        Button(action: previousMonth) {
                            Image(systemName: "chevron.left.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.blue.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        Text(monthYearString(from: currentMonth))
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button(action: nextMonth) {
                            Image(systemName: "chevron.right.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.blue.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 8)
                    
                    // Weekday headers
                    HStack(spacing: 0) {
                        ForEach(weekdays, id: \.self) { day in
                            Text(day)
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    
                    // Days grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 8) {
                        ForEach(daysInMonth(), id: \.self) { date in
                            if let date = date {
                                DayCellView(
                                    date: date,
                                    isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                    isToday: calendar.isDateInToday(date),
                                    isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedDate = date
                                        goalForSelectedDate = WaterGoalStore.goal(for: date)
                                    }
                                }
                            } else {
                                Color.clear
                                    .frame(height: 36)
                            }
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.blue.opacity(0.15), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
                )
                
                // Water goal for selected day (editable: tap day then set goal)
                WaterGoalCardView(
                    date: selectedDate,
                    goalGlasses: goalForSelectedDate,
                    glassVolumeML: glassVolumeML,
                    isEditable: true,
                    onGoalChange: { newGoal in
                        goalForSelectedDate = newGoal
                        WaterGoalStore.setGoal(newGoal, for: selectedDate)
                    }
                )
                
                Spacer(minLength: 24)
            }
            .padding()
            .padding(.top, 12)
        }
        .onAppear {
            goalForSelectedDate = WaterGoalStore.goal(for: selectedDate)
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
    
    private func previousMonth() {
        withAnimation(.easeInOut(duration: 0.25)) {
            currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func nextMonth() {
        withAnimation(.easeInOut(duration: 0.25)) {
            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        let firstDay = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstDay) - 1
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 0
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        
        let remainder = days.count % 7
        if remainder != 0 {
            days.append(contentsOf: Array(repeating: nil, count: 7 - remainder))
        }
        
        return days
    }
}

// MARK: - Day Cell

struct DayCellView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let action: () -> Void
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        Button(action: action) {
            Text(dayNumber)
                .font(.system(size: 15, weight: isToday ? .bold : .medium, design: .rounded))
                .foregroundColor(foregroundColor)
                .frame(width: 36, height: 36)
                .background(backgroundColor)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
    
    private var foregroundColor: Color {
        if !isCurrentMonth {
            return .secondary.opacity(0.5)
        }
        if isSelected {
            return .white
        }
        if isToday {
            return .blue
        }
        return .primary
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .blue
        }
        if isToday && !isSelected {
            return .blue.opacity(0.15)
        }
        return Color.clear
    }
}

// MARK: - Water Goal Card

struct WaterGoalCardView: View {
    let date: Date
    let goalGlasses: Int
    let glassVolumeML: Int
    var isEditable: Bool = false
    var onGoalChange: ((Int) -> Void)?
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.cyan)
                
                Text(isToday ? "Today's water goal" : "Water goal for this day")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
            }
            
            Text(dateString)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 12) {
                if isEditable, let onGoalChange = onGoalChange {
                    // Editable: stepper to set goal
                    HStack(alignment: .center, spacing: 16) {
                        Button(action: {
                            let newValue = max(1, goalGlasses - 1)
                            onGoalChange(newValue)
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.blue.opacity(goalGlasses > 1 ? 0.9 : 0.4))
                        }
                        .disabled(goalGlasses <= 1)
                        
                        VStack(spacing: 2) {
                            Text("\(goalGlasses)")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.blue)
                            Text("glasses")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .frame(minWidth: 80)
                        
                        Button(action: {
                            let newValue = min(20, goalGlasses + 1)
                            onGoalChange(newValue)
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.blue.opacity(goalGlasses < 20 ? 0.9 : 0.4))
                        }
                        .disabled(goalGlasses >= 20)
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(goalGlasses)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                        Text("glasses")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                
                Text("≈ \(goalGlasses * glassVolumeML) ml")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.blue.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.blue.opacity(0.2), lineWidth: 1)
            )
            
            if isEditable {
                Text("This goal is shown on the Home screen for that day.")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.cyan.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        )
    }
}

// MARK: - Limitize

struct LimitItem: Identifiable {
    let id: String
    let name: String
    var progress: Double // 0...1
    let color: Color
}

struct CoffeeLimitStore {
    private static let keyPrefix = "coffeeLimit_"
    
    static func count(for id: String, date: Date = Date()) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateKey = formatter.string(from: Calendar.current.startOfDay(for: date))
        let key = keyPrefix + id + "_" + dateKey
        return UserDefaults.standard.integer(forKey: key)
    }
    
    static func addOne(for id: String, date: Date = Date()) {
        let c = count(for: id, date: date)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateKey = formatter.string(from: Calendar.current.startOfDay(for: date))
        let key = keyPrefix + id + "_" + dateKey
        UserDefaults.standard.set(min(10, c + 1), forKey: key)
    }
    
    static func progress(for id: String, maxCups: Int = 3, date: Date = Date()) -> Double {
        min(1, Double(count(for: id, date: date)) / Double(maxCups))
    }
}

struct LimitizeView: View {
    @State private var limits: [LimitItem] = [
        LimitItem(id: "espresso", name: "Espresso", progress: 0.6, color: Color.brown),
        LimitItem(id: "turkish", name: "Turkish Coffee", progress: 0.4, color: Color(red: 0.4, green: 0.26, blue: 0.13)),
        LimitItem(id: "americano", name: "Americano", progress: 0.75, color: Color(red: 0.55, green: 0.35, blue: 0.2)),
        LimitItem(id: "decaf", name: "Decaf Coffee", progress: 0.3, color: Color(red: 0.6, green: 0.45, blue: 0.3)),
        LimitItem(id: "latte", name: "Latte", progress: 0.9, color: Color(red: 0.87, green: 0.72, blue: 0.53)),
        LimitItem(id: "cappuccino", name: "Cappuccino", progress: 0.5, color: Color(red: 0.76, green: 0.6, blue: 0.42)),
        LimitItem(id: "mocha", name: "Mocha", progress: 0.65, color: Color(red: 0.45, green: 0.28, blue: 0.18)),
        LimitItem(id: "flatwhite", name: "Flat White", progress: 0.55, color: Color(red: 0.82, green: 0.68, blue: 0.5)),
    ]
    @State private var showWaterChaserAlert = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                Text("Limitize")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Tap to log coffee. Balance with water!")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary.opacity(0.9))
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(limits) { item in
                        CircleProgressLimitCard(item: item, onTap: {
                            CoffeeLimitStore.addOne(for: item.id)
                            showWaterChaserAlert = true
                        })
                    }
                }
                
                Spacer(minLength: 24)
            }
            .padding()
            .padding(.top, 12)
        }
        .onAppear {
            limits = limits.map { item in
                LimitItem(id: item.id, name: item.name, progress: CoffeeLimitStore.progress(for: item.id), color: item.color)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .waterIntakeDidChange)) { _ in }
        .onChange(of: showWaterChaserAlert) { _, isShowing in
            if !isShowing {
                limits = limits.map { item in
                    LimitItem(id: item.id, name: item.name, progress: CoffeeLimitStore.progress(for: item.id), color: item.color)
                }
            }
        }
        .alert("Water chaser?", isPresented: $showWaterChaserAlert) {
            Button("Add water") {
                WaterIntakeStore.addGlass(for: Date())
            }
            Button("Maybe later", role: .cancel) { }
        } message: {
            Text("Balance coffee with a glass of water. It helps hydration!")
        }
    }
}

// MARK: - Circle Progress Limit Card

struct CircleProgressLimitCard: View {
    let item: LimitItem
    var onTap: (() -> Void)? = nil
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                // Background track
                Circle()
                    .stroke(
                        item.color.opacity(0.2),
                        lineWidth: 8
                    )
                    .frame(width: 100, height: 100)
                
                // Progress arc
                Circle()
                    .trim(from: 0, to: animatedProgress)
                    .stroke(
                        item.color,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                
                // Center text (percentage)
                Text("\(Int(animatedProgress * 100))%")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(item.color)
            }
            .frame(height: 100)
            
            Text(item.name)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(item.color.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedProgress = item.progress
            }
        }
        .onChange(of: item.progress) { _, newVal in
            withAnimation(.easeOut(duration: 0.4)) {
                animatedProgress = newVal
            }
        }
    }
}

// MARK: - Statistics

// MARK: - Water Intake Store (sample data for demo; can switch to UserDefaults/real storage later)

struct WaterIntakeStore {
    static let glassesPerDayKey = "waterIntakeGlasses"
    
    /// Returns glasses of water for the given day (start of day as key).
    /// For today: returns stored value or 0. For past: uses sample data when no stored value.
    static func glasses(for date: Date) -> Int {
        let key = Calendar.current.startOfDay(for: date)
        if let value = UserDefaults.standard.object(forKey: keyString(key)) as? Int { return value }
        let cal = Calendar.current
        if cal.isDateInToday(key) { return 0 }
        return sampleGlasses(for: key)
    }
    
    static func setGlasses(_ value: Int, for date: Date) {
        let key = Calendar.current.startOfDay(for: date)
        UserDefaults.standard.set(max(0, min(99, value)), forKey: keyString(key))
        NotificationCenter.default.post(name: .waterIntakeDidChange, object: nil)
    }
    
    /// Add one glass for the given date (convenience for one-tap logging).
    static func addGlass(for date: Date) {
        let current = glasses(for: date)
        setGlasses(current + 1, for: date)
    }
    
    private static func keyString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return glassesPerDayKey + "_" + formatter.string(from: date)
    }
    
    /// Sample data for past ~400 days so all periods have values.
    private static func sampleGlasses(for date: Date) -> Int {
        let cal = Calendar.current
        let daysAgo = cal.dateComponents([.day], from: date, to: Date()).day ?? 0
        if daysAgo < 0 { return 6 }
        let seed = Int(date.timeIntervalSince1970 / 86400) % 1000
        let base = [5, 6, 7, 8, 9, 6, 7, 8, 7, 6, 8, 9, 7, 8, 6][seed % 15]
        let variation = (seed % 5) - 2
        return max(0, min(12, base + variation))
    }
    
    static func totalGlasses(from start: Date, to end: Date) -> Int {
        let cal = Calendar.current
        var total = 0
        var current = cal.startOfDay(for: start)
        let endDay = cal.startOfDay(for: end)
        while current <= endDay {
            total += glasses(for: current)
            current = cal.date(byAdding: .day, value: 1, to: current) ?? current
        }
        return total
    }
    
    /// Days in the past N days where goal was met.
    static func daysGoalMet(days: Int) -> Int {
        let cal = Calendar.current
        var count = 0
        var current = cal.startOfDay(for: Date())
        for _ in 0..<days {
            let g = WaterGoalStore.goal(for: current)
            let intake = glasses(for: current)
            if intake >= g { count += 1 }
            current = cal.date(byAdding: .day, value: -1, to: current) ?? current
        }
        return count
    }
}

// MARK: - Routines Store (Water moments: Morning, Post-workout, Before bed, etc.)

struct RoutineItem: Identifiable {
    let id: String
    var name: String
    var prompt: String
    var isEnabled: Bool
}

struct RoutinesStore {
    private static let key = "waterRoutines"
    
    static var routines: [RoutineItem] {
        get {
            guard let data = UserDefaults.standard.data(forKey: key),
                  let decoded = try? JSONDecoder().decode([RoutineItem].self, from: data) else {
                return defaultRoutines
            }
            return decoded
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: key)
            }
        }
    }
    
    private static var defaultRoutines: [RoutineItem] {
        [
            RoutineItem(id: "morning", name: "Morning", prompt: "Start your day with a glass of water", isEnabled: true),
            RoutineItem(id: "after_coffee", name: "After coffee", prompt: "Balance coffee with a glass of water", isEnabled: true),
            RoutineItem(id: "before_bed", name: "Before bed", prompt: "A small sip before sleep supports rest", isEnabled: true),
            RoutineItem(id: "post_workout", name: "Post-workout", prompt: "Replenish after exercise", isEnabled: true),
            RoutineItem(id: "afternoon", name: "Afternoon slump", prompt: "Water can help when you feel foggy", isEnabled: true),
        ]
    }
    
    static func toggle(id: String) {
        var items = routines
        if let i = items.firstIndex(where: { $0.id == id }) {
            items[i].isEnabled.toggle()
            routines = items
        }
    }
}

extension RoutineItem: Codable {}

// MARK: - Water Moments View (contextual prompts - bell opens this)

struct WaterMomentsView: View {
    var onDismiss: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    @State private var routines: [RoutineItem] = RoutinesStore.routines
    
    private func done() {
        RoutinesStore.routines = routines
        if let onDismiss = onDismiss {
            onDismiss()
        } else {
            dismiss()
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Water Moments")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text("Contextual reminders instead of generic \"drink water\" nudges.")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 12) {
                        ForEach(routines.indices, id: \.self) { i in
                            let routine = routines[i]
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(routine.name)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    Text(routine.prompt)
                                        .font(.system(size: 13, weight: .regular, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get: { routines[i].isEnabled },
                                    set: { newVal in
                                        routines[i].isEnabled = newVal
                                        RoutinesStore.routines = routines
                                    }
                                ))
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.blue.opacity(0.06))
                            )
                        }
                    }
                    Spacer(minLength: 40)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { done() }
                }
            }
            .onAppear { routines = RoutinesStore.routines }
        }
    }
}

// MARK: - Body Feeling Sheet (How do you feel? with water suggestions)

struct BodyFeelingOption: Identifiable {
    let id: String
    let emoji: String
    let label: String
    let suggestion: String
}

struct BodyFeelingSheet: View {
    var onDismiss: () -> Void
    @State private var selectedFeeling: String? = nil
    @State private var showSuggestion = false
    
    private let options: [BodyFeelingOption] = [
        BodyFeelingOption(id: "foggy", emoji: "🌫️", label: "Foggy", suggestion: "Dehydration often causes brain fog. Try a glass of water—it can help within minutes."),
        BodyFeelingOption(id: "headache", emoji: "🤕", label: "Headache", suggestion: "Headaches are a common sign of mild dehydration. A glass of water might help."),
        BodyFeelingOption(id: "tired", emoji: "😴", label: "Low energy", suggestion: "Fatigue can stem from dehydration. Water helps your body function better."),
        BodyFeelingOption(id: "fine", emoji: "😊", label: "Fine", suggestion: "Great! Keep up your hydration to stay that way."),
        BodyFeelingOption(id: "great", emoji: "🌟", label: "Great", suggestion: "Awesome! Staying hydrated is paying off."),
    ]
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                Text("How do you feel right now?")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                VStack(spacing: 12) {
                    ForEach(options) { opt in
                        Button(action: {
                            selectedFeeling = opt.id
                            showSuggestion = true
                        }) {
                            HStack(spacing: 16) {
                                Text(opt.emoji)
                                    .font(.system(size: 28))
                                Text(opt.label)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedFeeling == opt.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(selectedFeeling == opt.id ? Color.blue.opacity(0.12) : Color.gray.opacity(0.08))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                if showSuggestion, let opt = options.first(where: { $0.id == selectedFeeling }) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.yellow)
                        Text(opt.suggestion)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.yellow.opacity(0.08))
                    )
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { onDismiss() }
                }
            }
        }
    }
}

// MARK: - Settings View (Routines, app preferences)

struct SettingsView: View {
    var onDismiss: () -> Void
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(destination: WaterMomentsView()) {
                        Label("Water Moments", systemImage: "drop.circle")
                    }
                } header: {
                    Text("Routines")
                } footer: {
                    Text("Contextual reminders: morning, after coffee, before bed, etc.")
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { onDismiss() }
                }
            }
        }
    }
}

// MARK: - Statistics Period

enum StatisticsPeriod: String, CaseIterable, Identifiable {
    case daily = "Daily"
    case weekly = "Weekly"
    case twoWeeks = "2 Weeks"
    case threeWeeks = "3 Weeks"
    case monthly = "Monthly"
    case twoMonths = "2 Months"
    case threeMonths = "3 Months"
    case sixMonths = "6 Months"
    case yearly = "1 Year"
    
    var id: String { rawValue }
    
    var currentPeriodRange: (start: Date, end: Date) {
        let cal = Calendar.current
        let now = Date()
        switch self {
        case .daily:
            let start = cal.startOfDay(for: now)
            return (start, now)
        case .weekly:
            let start = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) ?? now
            return (start, now)
        case .twoWeeks:
            let start = cal.date(byAdding: .day, value: -13, to: cal.startOfDay(for: now)) ?? now
            return (start, now)
        case .threeWeeks:
            let start = cal.date(byAdding: .day, value: -20, to: cal.startOfDay(for: now)) ?? now
            return (start, now)
        case .monthly:
            let start = cal.date(from: cal.dateComponents([.year, .month], from: now)) ?? now
            return (start, now)
        case .twoMonths:
            let start = cal.date(byAdding: .month, value: -2, to: now) ?? now
            return (cal.startOfDay(for: start), now)
        case .threeMonths:
            let start = cal.date(byAdding: .month, value: -3, to: now) ?? now
            return (cal.startOfDay(for: start), now)
        case .sixMonths:
            let start = cal.date(byAdding: .month, value: -6, to: now) ?? now
            return (cal.startOfDay(for: start), now)
        case .yearly:
            let start = cal.date(from: cal.dateComponents([.year], from: now)) ?? now
            return (start, now)
        }
    }
    
    /// Previous period: same length as current, ending right before current start.
    var previousPeriodRange: (start: Date, end: Date) {
        let cal = Calendar.current
        let (curStart, _) = currentPeriodRange
        let prevEnd = cal.date(byAdding: .second, value: -1, to: curStart) ?? curStart
        
        let prevStart: Date
        switch self {
        case .daily:
            prevStart = cal.date(byAdding: .day, value: -1, to: cal.startOfDay(for: curStart)) ?? curStart
        case .weekly:
            prevStart = cal.date(byAdding: .day, value: -7, to: curStart) ?? curStart
        case .twoWeeks:
            prevStart = cal.date(byAdding: .day, value: -14, to: curStart) ?? curStart
        case .threeWeeks:
            prevStart = cal.date(byAdding: .day, value: -21, to: curStart) ?? curStart
        case .monthly:
            prevStart = cal.date(byAdding: .month, value: -1, to: curStart) ?? curStart
        case .twoMonths:
            prevStart = cal.date(byAdding: .month, value: -2, to: curStart) ?? curStart
        case .threeMonths:
            prevStart = cal.date(byAdding: .month, value: -3, to: curStart) ?? curStart
        case .sixMonths:
            prevStart = cal.date(byAdding: .month, value: -6, to: curStart) ?? curStart
        case .yearly:
            prevStart = cal.date(byAdding: .year, value: -1, to: curStart) ?? curStart
        }
        return (prevStart, prevEnd)
    }
}

// MARK: - Statistics View

struct StatisticsView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                Text("Statistics")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Gentle streaks - supportive framing
                GentleStreakCard()
                
                Text("Compared to previous period")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary.opacity(0.9))
                
                VStack(spacing: 12) {
                    ForEach(StatisticsPeriod.allCases) { period in
                        StatisticsPeriodCard(period: period)
                    }
                }
                
                Spacer(minLength: 24)
            }
            .padding()
            .padding(.top, 12)
        }
    }
}

// MARK: - Gentle Streak Card (supportive framing)

struct GentleStreakCard: View {
    private var daysGoalMet: Int {
        WaterIntakeStore.daysGoalMet(days: 7)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.yellow)
                Text("This week")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
            }
            Text("You've hit your water goal \(daysGoalMet) day\(daysGoalMet == 1 ? "" : "s") in the past 7 days. Every sip counts!")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.yellow.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Statistics Period Card

struct StatisticsPeriodCard: View {
    let period: StatisticsPeriod
    
    private var currentTotal: Int {
        let (start, end) = period.currentPeriodRange
        return WaterIntakeStore.totalGlasses(from: start, to: end)
    }
    
    private var previousTotal: Int {
        let (start, end) = period.previousPeriodRange
        return WaterIntakeStore.totalGlasses(from: start, to: end)
    }
    
    private var difference: Int { currentTotal - previousTotal }
    
    private var percentageChange: Int? {
        guard previousTotal > 0 else { return nil }
        return Int(round(Double(difference) / Double(previousTotal) * 100))
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Period label
            VStack(alignment: .leading, spacing: 4) {
                Text(period.rawValue)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(detailSubtitle)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Current total
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(currentTotal)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                Text("glasses")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            // Difference badge
            differenceBadge
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.12), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        )
    }
    
    private var detailSubtitle: String {
        switch period {
        case .daily:
            return "vs yesterday"
        case .weekly:
            return "vs last week"
        case .twoWeeks:
            return "vs previous 2 weeks"
        case .threeWeeks:
            return "vs previous 3 weeks"
        case .monthly:
            return "vs last month"
        case .twoMonths:
            return "vs previous 2 months"
        case .threeMonths:
            return "vs previous 3 months"
        case .sixMonths:
            return "vs previous 6 months"
        case .yearly:
            return "vs last year"
        }
    }
    
    @ViewBuilder
    private var differenceBadge: some View {
        let more = difference > 0
        let same = difference == 0
        let percentText: String = {
            guard let p = percentageChange, p != 0 else { return "" }
            return " (\(p > 0 ? "+" : "")\(p)%)"
        }()
        
        if same {
            Text("Same")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.secondary.opacity(0.15)))
        } else {
            HStack(spacing: 4) {
                Image(systemName: more ? "arrow.up.right" : "arrow.down.right")
                    .font(.system(size: 12, weight: .bold))
                Text("\(more ? "+" : "")\(difference) glass\(abs(difference) == 1 ? "" : "es")\(percentText)")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
            }
            .foregroundColor(more ? Color.green : Color.orange)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill((more ? Color.green : Color.orange).opacity(0.15)))
        }
    }
}

// MARK: - Water Drop Character View

struct WaterDropCharacterView: View {
    var currentGlasses: Int = 0
    var goalGlasses: Int = 8
    var onLogWater: (() -> Void)? = nil
    
    // Body animations
    @State private var isFloating = false
    @State private var isBreathing = false
    @State private var isWobbling = false
    @State private var isTapped = false
    @State private var isCelebrating = false
    
    // Face animations
    @State private var eyesClosed = false
    @State private var eyebrowsRaised = false
    @State private var mouthState: MouthState = .smile
    @State private var lookDirection: CGFloat = 0
    
    // Speech bubble
    @State private var showSpeechBubble = false
    @State private var speechBubbleText = "I want to drink water! 💧"
    @State private var isThirsty = false
    
    // Timers
    let blinkTimer = Timer.publish(every: 3.0, on: .main, in: .common).autoconnect()
    let eyebrowTimer = Timer.publish(every: 5.0, on: .main, in: .common).autoconnect()
    let mouthTimer = Timer.publish(every: 4.0, on: .main, in: .common).autoconnect()
    let lookTimer = Timer.publish(every: 2.5, on: .main, in: .common).autoconnect()
    let thirstyTimer = Timer.publish(every: 12.0, on: .main, in: .common).autoconnect()
    
    private var progressRatio: Double {
        guard goalGlasses > 0 else { return 1 }
        return min(1, Double(currentGlasses) / Double(goalGlasses))
    }
    
    private var computedThirsty: Bool { progressRatio < 0.5 }
    
    enum MouthState {
        case smile
        case open
        case talking
        case surprised
    }
    
    var body: some View {
        ZStack {
            // Speech Bubble
            if showSpeechBubble {
                SpeechBubbleView(text: speechBubbleText)
                    .offset(x: 60, y: -120)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(1)
            }
            
            // Water Drop Body
            GeometryReader { geo in
                let centerX = geo.size.width / 2
                let centerY = geo.size.height * 0.5
                
                ZStack {
                    // Body shape with gradient
                    WaterDropBodyShape()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.cyan.opacity(0.7),
                                    Color.blue.opacity(0.8),
                                    Color.cyan.opacity(0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            // Shine effect
                            WaterDropBodyShape()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.6),
                                            Color.white.opacity(0.2),
                                            Color.clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .center
                                    )
                                )
                        )
                        .overlay(
                            // Border glow
                            WaterDropBodyShape()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.7),
                                            Color.cyan.opacity(0.4)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 3
                                )
                        )
                        .shadow(color: .cyan.opacity(0.4), radius: 15, x: 0, y: 8)
                    
                    // Face container
                    VStack(spacing: 0) {
                        // Eyebrows
                        HStack(spacing: geo.size.width * 0.22) {
                            EyebrowView(isRaised: eyebrowsRaised, isLeft: true, width: geo.size.width * 0.12)
                            EyebrowView(isRaised: eyebrowsRaised, isLeft: false, width: geo.size.width * 0.12)
                        }
                        .offset(y: eyebrowsRaised ? -3 : 0)
                        
                        // Eyes
                        HStack(spacing: geo.size.width * 0.18) {
                            EyeView(isClosed: eyesClosed, lookDirection: lookDirection, size: geo.size.width * 0.16)
                            EyeView(isClosed: eyesClosed, lookDirection: lookDirection, size: geo.size.width * 0.16)
                        }
                        .padding(.top, 4)
                        
                        // Nose
                        NoseView(size: geo.size.width * 0.06)
                            .padding(.top, 8)
                        
                        // Mouth
                        AnimatedMouthView(state: mouthState, width: geo.size.width * 0.25, height: geo.size.width * 0.12)
                            .padding(.top, 6)
                    }
                    .position(x: centerX, y: centerY)
                    
                    // Thirsty sweat drop (when behind on hydration)
                    if isThirsty {
                        SweatDropView(size: geo.size.width * 0.08)
                            .offset(x: geo.size.width * 0.32, y: -geo.size.height * 0.05)
                            .transition(.opacity.combined(with: .scale))
                    }
                    
                    // Goal reached sparkles
                    if isCelebrating {
                        ForEach(0..<8, id: \.self) { i in
                            Image(systemName: "sparkle")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.yellow)
                                .offset(x: CGFloat(cos(Double(i) * .pi / 4)) * 60,
                                        y: CGFloat(sin(Double(i) * .pi / 4)) * 60)
                        }
                    }
                }
            }
            .offset(y: isFloating ? -8 : 8)
            .scaleEffect(isBreathing ? 1.03 : 0.97)
            .scaleEffect(progressRatio >= 1 ? 1.05 : 1.0)
            .rotationEffect(.degrees(isWobbling ? 2 : -2))
            .scaleEffect(isTapped ? 0.9 : 1.0)
        }
        .onTapGesture {
            triggerTap()
        }
        .onChange(of: currentGlasses) { _, newVal in
            if goalGlasses > 0 && newVal >= goalGlasses && !isCelebrating {
                triggerGoalReached()
            }
        }
        .onChange(of: computedThirsty) { _, newVal in
            isThirsty = newVal
        }
        .onAppear {
            isThirsty = computedThirsty
        }
        .onAppear {
            startAnimations()
        }
        .onReceive(blinkTimer) { _ in triggerBlink() }
        .onReceive(eyebrowTimer) { _ in triggerEyebrowRaise() }
        .onReceive(mouthTimer) { _ in triggerMouthMove() }
        .onReceive(lookTimer) { _ in triggerRandomLook() }
        .onReceive(thirstyTimer) { _ in triggerThirsty() }
    }
    
    // MARK: - Animation Functions
    
    private func startAnimations() {
        // Floating animation
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            isFloating = true
        }
        // Breathing animation
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            isBreathing = true
        }
        // Wobble animation
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            isWobbling = true
        }
    }
    
    private func triggerBlink() {
        // Random chance to blink
        guard Bool.random() || Bool.random() else { return }
        
        withAnimation(.easeInOut(duration: 0.08)) {
            eyesClosed = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.easeInOut(duration: 0.08)) {
                eyesClosed = false
            }
        }
        
        // Sometimes double blink
        if Bool.random() && Bool.random() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.08)) {
                    eyesClosed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    withAnimation(.easeInOut(duration: 0.08)) {
                        eyesClosed = false
                    }
                }
            }
        }
    }
    
    private func triggerEyebrowRaise() {
        // 40% chance to raise eyebrows
        guard Int.random(in: 0...10) < 4 else { return }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            eyebrowsRaised = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.8...1.5)) {
            withAnimation(.easeInOut(duration: 0.2)) {
                eyebrowsRaised = false
            }
        }
    }
    
    private func triggerMouthMove() {
        // Random mouth movement
        let states: [MouthState] = [.smile, .open, .surprised, .smile, .smile]
        let newState = states.randomElement() ?? .smile
        
        withAnimation(.easeInOut(duration: 0.2)) {
            mouthState = newState
        }
        
        // Return to smile after a bit
        if newState != .smile {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.5...1.2)) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    mouthState = .smile
                }
            }
        }
    }
    
    private func triggerRandomLook() {
        let directions: [CGFloat] = [-1, -0.5, 0, 0, 0.5, 1]
        withAnimation(.easeInOut(duration: 0.3)) {
            lookDirection = directions.randomElement() ?? 0
        }
    }
    
    private func triggerThirsty() {
        // 30% chance to become thirsty and show speech bubble (only when actually behind)
        guard computedThirsty, Int.random(in: 0...10) < 3 else { return }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            isThirsty = true
            speechBubbleText = "I want to drink water! 💧"
            showSpeechBubble = true
            eyebrowsRaised = true
            mouthState = .open
        }
        
        talkingAnimation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showSpeechBubble = false
                isThirsty = computedThirsty
                eyebrowsRaised = false
                mouthState = .smile
            }
        }
    }
    
    private func talkingAnimation() {
        for i in 0..<6 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    mouthState = i % 2 == 0 ? .talking : .open
                }
            }
        }
    }
    
    private func triggerTap() {
        // Bounce effect on tap
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            isTapped = true
        }
        
        withAnimation(.easeInOut(duration: 0.1)) {
            mouthState = .surprised
            eyebrowsRaised = true
        }
        
        // Log water if callback provided
        if let onLogWater = onLogWater {
            onLogWater()
            let goalReached = currentGlasses + 1 >= goalGlasses && goalGlasses > 0
            speechBubbleText = goalReached ? "You did it! 🎉" : (currentGlasses + 1 < goalGlasses ? "Thanks! 💧" : "One more! 🌟")
            showSpeechBubble = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isTapped = false
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.2)) {
                mouthState = .smile
                eyebrowsRaised = false
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showSpeechBubble = false
            }
        }
    }
    
    private func triggerGoalReached() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            isCelebrating = true
            speechBubbleText = "You did it! 🎉"
            showSpeechBubble = true
            mouthState = .open
            eyebrowsRaised = true
        }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeOut(duration: 0.5)) {
                isCelebrating = false
                showSpeechBubble = false
                mouthState = .smile
                eyebrowsRaised = false
            }
        }
    }
}

// MARK: - Eyebrow View

struct EyebrowView: View {
    var isRaised: Bool
    var isLeft: Bool
    var width: CGFloat
    
    var body: some View {
        Path { path in
            if isLeft {
                path.move(to: CGPoint(x: 0, y: isRaised ? 4 : 0))
                path.addQuadCurve(
                    to: CGPoint(x: width, y: isRaised ? 0 : 4),
                    control: CGPoint(x: width / 2, y: isRaised ? -4 : 8)
                )
            } else {
                path.move(to: CGPoint(x: 0, y: isRaised ? 0 : 4))
                path.addQuadCurve(
                    to: CGPoint(x: width, y: isRaised ? 4 : 0),
                    control: CGPoint(x: width / 2, y: isRaised ? -4 : 8)
                )
            }
        }
        .stroke(Color.black.opacity(0.7), style: StrokeStyle(lineWidth: 3, lineCap: .round))
        .frame(width: width, height: 12)
        .animation(.easeInOut(duration: 0.2), value: isRaised)
    }
}

// MARK: - Eye View

struct EyeView: View {
    var isClosed: Bool
    var lookDirection: CGFloat
    var size: CGFloat

    var body: some View {
        ZStack {
            // Eye white
            Ellipse()
                .fill(.white)
                .frame(width: size, height: isClosed ? size * 0.08 : size * 0.85)
                .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)

            if !isClosed {
                // Pupil
                Circle()
                    .fill(.black)
                    .frame(width: size * 0.45, height: size * 0.45)
                    .offset(x: lookDirection * size * 0.12, y: size * 0.03)

                // Eye shine
                Circle()
                    .fill(.white.opacity(0.9))
                    .frame(width: size * 0.18, height: size * 0.18)
                    .offset(x: -size * 0.08 + lookDirection * size * 0.08, y: -size * 0.1)
                
                // Secondary shine
                Circle()
                    .fill(.white.opacity(0.5))
                    .frame(width: size * 0.08, height: size * 0.08)
                    .offset(x: size * 0.1 + lookDirection * size * 0.05, y: size * 0.05)
            }
        }
        .animation(.easeInOut(duration: 0.08), value: isClosed)
        .animation(.easeInOut(duration: 0.3), value: lookDirection)
    }
}

// MARK: - Nose View

struct NoseView: View {
    var size: CGFloat
    
    var body: some View {
        Ellipse()
            .fill(
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.3),
                        Color.cyan.opacity(0.2)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: size, height: size * 0.6)
            .overlay(
                Ellipse()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Animated Mouth View

struct AnimatedMouthView: View {
    var state: WaterDropCharacterView.MouthState
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        ZStack {
            switch state {
            case .smile:
                SmileMouth(width: width, height: height)
            case .open:
                OpenMouthAnimated(width: width, height: height * 0.8)
            case .talking:
                TalkingMouth(width: width, height: height * 0.5)
            case .surprised:
                SurprisedMouth(width: width * 0.6, height: height)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: state)
    }
}

struct SmileMouth: View {
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
        .stroke(Color.black, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
        .frame(width: width, height: height)
    }
}

struct OpenMouthAnimated: View {
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color.black.opacity(0.85))
                .frame(width: width * 0.6, height: height)
            
            // Tongue
            Ellipse()
                .fill(Color.pink.opacity(0.7))
                .frame(width: width * 0.4, height: height * 0.5)
                .offset(y: height * 0.15)
        }
    }
}

struct TalkingMouth: View {
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        Ellipse()
            .fill(Color.black.opacity(0.85))
            .frame(width: width * 0.5, height: height)
    }
}

struct SurprisedMouth: View {
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.85))
                .frame(width: width, height: width)
            
            Circle()
                .fill(Color.pink.opacity(0.5))
                .frame(width: width * 0.5, height: width * 0.5)
                .offset(y: width * 0.1)
        }
    }
}

// MARK: - Speech Bubble View

struct SpeechBubbleView: View {
    var text: String
    @State private var isAnimating = false
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Bubble
            Text(text)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                )
            
            // Tail
            Triangle()
                .fill(Color.white)
                .frame(width: 15, height: 12)
                .offset(x: 10, y: 5)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
        }
        .scaleEffect(isAnimating ? 1.02 : 0.98)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Sweat Drop View

struct SweatDropView: View {
    var size: CGFloat
    @State private var wiggle: CGFloat = 0
    @State private var falling = false

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
                    .fill(Color.white.opacity(0.8))
                    .frame(width: size * 0.25, height: size * 0.25)
                    .offset(x: -size * 0.15, y: -size * 0.1)
            )
            .frame(width: size, height: size * 1.4)
            .rotationEffect(.degrees(Double(sin(wiggle) * 8)))
            .offset(y: falling ? 10 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    wiggle = .pi * 2
                }
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    falling = true
                }
            }
    }
}

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

// MARK: - Preview

#Preview {
    RootView()
}
