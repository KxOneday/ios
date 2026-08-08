import SwiftUI

struct AddEventView: View {
    @EnvironmentObject private var eventStore: EventStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedDate = Date()
    @State private var isLunar = false
    @State private var isCountdown = true
    @State private var selectedCategory = "其他"
    @State private var selectedTheme = "starSea"
    @State private var reminderDays = 0
    @State private var repeatYearly = false

    @State private var lunarYear = 2025
    @State private var lunarMonth = 1
    @State private var lunarDay = 1
    @State private var isLeapMonth = false

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("事件名称（如：生日、纪念日）", text: $name)
                        .font(.body)

                    Picker("类型", selection: $isCountdown) {
                        Text("倒数日（未来）").tag(true)
                        Text("纪念日（过去）").tag(false)
                    }
                    .pickerStyle(.segmented)

                    Picker("分类", selection: $selectedCategory) {
                        ForEach(CountdownEvent.categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                }

                Section {
                    Toggle(isOn: $isLunar) {
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundStyle(.purple)
                            Text("农历日期")
                        }
                    }
                    .onChange(of: isLunar) { newValue in
                        if newValue {
                            let comps = LunarCalendar.lunarComponents(from: selectedDate)
                            lunarYear = comps.year
                            lunarMonth = comps.month
                            lunarDay = comps.day
                            isLeapMonth = comps.isLeapMonth
                        } else {
                            if let gregorianDate = LunarCalendar.gregorianFromLunar(
                                year: lunarYear, month: lunarMonth, day: lunarDay,
                                isLeapMonth: isLeapMonth) {
                                selectedDate = gregorianDate
                            }
                        }
                    }

                    if isLunar {
                        lunarDatePicker
                    } else {
                        DatePicker("选择日期", selection: $selectedDate,
                                   displayedComponents: .date)
                            .environment(\.locale, Locale(identifier: "zh_CN"))
                    }

                    HStack {
                        Text("公历")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(LunarCalendar.gregorianDateString(from: effectiveDate))
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                    HStack {
                        Text("农历")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(LunarCalendar.lunarDateString(from: effectiveDate))
                            .font(.caption)
                            .foregroundStyle(.purple)
                    }
                } header: {
                    Label("日期设置", systemImage: "calendar")
                } footer: {
                    Text(isCountdown ?
                         "选择一个未来的日期，系统会计算剩余天数" :
                         "选择一个过去的日期，系统会计算已过天数")
                }

                Section("卡片主题") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(ThemeManager.themes) { theme in
                            ThemeOptionView(theme: theme,
                                            isSelected: selectedTheme == theme.id) {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedTheme = theme.id
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("提醒设置") {
                    Toggle(isOn: $repeatYearly) {
                        Label("每年重复", systemImage: "repeat")
                    }

                    Picker("提前提醒", selection: $reminderDays) {
                        Text("不提醒").tag(0)
                        Text("提前1天").tag(1)
                        Text("提前3天").tag(3)
                        Text("提前7天").tag(7)
                        Text("提前14天").tag(14)
                        Text("提前30天").tag(30)
                    }
                }

                Section("快捷模板") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                        TemplateButton(title: "生日", icon: "🎂", color: .pink) {
                            name = name.isEmpty ? "我的生日" : name
                            selectedCategory = "生日"
                            selectedTheme = "birthday"
                        }
                        TemplateButton(title: "纪念日", icon: "💕", color: .red) {
                            name = name.isEmpty ? "纪念日" : name
                            selectedCategory = "纪念日"
                            selectedTheme = "anniversary"
                        }
                        TemplateButton(title: "考试", icon: "📚", color: .blue) {
                            name = name.isEmpty ? "考试" : name
                            selectedCategory = "考试"
                            selectedTheme = "study"
                        }
                        TemplateButton(title: "节日", icon: "🎄", color: .green) {
                            name = name.isEmpty ? "节日" : name
                            selectedCategory = "节日"
                            selectedTheme = "festival"
                        }
                        TemplateButton(title: "工作", icon: "💼", color: .orange) {
                            name = name.isEmpty ? "工作截止" : name
                            selectedCategory = "工作"
                        }
                        TemplateButton(title: "自定义", icon: "✨", color: .purple) {
                            selectedTheme = "custom"
                        }
                    }
                }
            }
            .navigationTitle("添加事件")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { saveEvent() }
                        .disabled(!isFormValid)
                        .fontWeight(.semibold)
                }
            }
            .onAppear {
                let comps = LunarCalendar.lunarComponents(from: selectedDate)
                lunarYear = comps.year
                lunarMonth = comps.month
                lunarDay = comps.day
            }
        }
    }

    // MARK: - Lunar Date Picker
    private var lunarDatePicker: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                VStack(alignment: .leading) {
                    Text("年").font(.caption).foregroundStyle(.secondary)
                    Picker("年", selection: $lunarYear) {
                        ForEach(1900...2100, id: \.self) { year in
                            Text("\(year)").tag(year)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)
                    .clipped()
                }

                VStack(alignment: .leading) {
                    Text("月").font(.caption).foregroundStyle(.secondary)
                    Picker("月", selection: $lunarMonth) {
                        ForEach(1...12, id: \.self) { month in
                            Text("\(month)").tag(month)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)
                    .clipped()
                }

                VStack(alignment: .leading) {
                    Text("日").font(.caption).foregroundStyle(.secondary)
                    Picker("日", selection: $lunarDay) {
                        ForEach(1...30, id: \.self) { day in
                            Text("\(day)").tag(day)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)
                    .clipped()
                }
            }

            Toggle("闰月", isOn: $isLeapMonth)
                .font(.subheadline)
        }
    }

    private var effectiveDate: Date {
        if isLunar {
            return LunarCalendar.gregorianFromLunar(
                year: lunarYear, month: lunarMonth, day: lunarDay,
                isLeapMonth: isLeapMonth
            ) ?? selectedDate
        }
        return selectedDate
    }

    private func saveEvent() {
        let dateToSave = effectiveDate
        let event = CountdownEvent(
            name: name.trimmingCharacters(in: .whitespaces),
            targetDate: dateToSave,
            isLunar: isLunar,
            isCountdown: isCountdown,
            category: selectedCategory,
            themeName: selectedTheme,
            reminderDaysBefore: reminderDays,
            repeatYearly: repeatYearly
        )
        eventStore.add(event)
        NotificationManager.scheduleNotification(for: event)
        dismiss()
    }
}

// MARK: - Theme Option
struct ThemeOptionView: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(colors: theme.gradient,
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                        )
                        .frame(width: 44, height: 44)

                    if isSelected {
                        Circle()
                            .strokeBorder(.white, lineWidth: 2.5)
                            .frame(width: 44, height: 44)
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                    }
                }
                Text(theme.name)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Template Button
struct TemplateButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(color.opacity(0.3), lineWidth: 1)
            )
        }
        .foregroundStyle(color)
    }
}
