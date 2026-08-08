import SwiftUI
import SwiftData

struct EventDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    let event: CountdownEvent

    @State private var showDeleteAlert = false
    @State private var showEditSheet = false
    @State private var animateNumber = false

    private var theme: AppTheme {
        ThemeManager.theme(for: event.themeName)
    }

    private var gradientColors: [Color] {
        colorScheme == .dark ? theme.darkGradient : theme.gradient
    }

    var body: some View {
        ZStack {
            // Full background gradient
            LinearGradient(colors: gradientColors,
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            // Decorative elements
            decorativeBackground

            ScrollView {
                VStack(spacing: 32) {
                    // Main countdown display
                    mainCountdownView

                    // Info cards
                    infoCardsSection

                    // Action buttons
                    actionButtons
                }
                .padding(.top, 40)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        event.isPinned.toggle()
                        try? modelContext.save()
                    } label: {
                        Label(event.isPinned ? "取消置顶" : "置顶",
                              systemImage: event.isPinned ? "pin.slash" : "pin")
                    }

                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("删除", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(.white)
                }
            }
        }
        .alert("确认删除", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                NotificationManager.cancelNotification(for: event)
                modelContext.delete(event)
                dismiss()
            }
        } message: {
            Text("确定要删除「\(event.name)」吗？此操作不可撤销。")
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                animateNumber = true
            }
        }
    }

    // MARK: - Main Countdown
    private var mainCountdownView: some View {
        VStack(spacing: 16) {
            // Category badge
            Text(event.category)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())

            // Event name
            Text(event.name)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            // Big number
            ZStack {
                // Glow effect
                Text("\(abs(event.displayDays))")
                    .font(.system(size: 96, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white.opacity(0.15))
                    .blur(radius: 10)
                    .scaleEffect(animateNumber ? 1 : 0.5)

                Text("\(abs(event.displayDays))")
                    .font(.system(size: 96, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                    .scaleEffect(animateNumber ? 1 : 0.5)
            }

            Text(event.isCountdown ?
                 (event.daysRemaining >= 0 ? "天后" : "天前已过") :
                 "天前")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(0.8))

            // Calendar type badge
            HStack(spacing: 6) {
                Image(systemName: event.isLunar ? "moon.fill" : "sun.max.fill")
                    .font(.caption)
                Text(event.isLunar ? "农历" : "公历")
                    .font(.caption)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
        }
    }

    // MARK: - Info Cards
    private var infoCardsSection: some View {
        VStack(spacing: 12) {
            // Gregorian date card
            InfoCard(
                icon: "calendar",
                title: "公历日期",
                value: LunarCalendar.gregorianDateString(from: event.targetDate),
                subtitle: LunarCalendar.monthDay(from: event.targetDate)
            )

            // Lunar date card
            InfoCard(
                icon: "moon.stars",
                title: "农历日期",
                value: LunarCalendar.lunarDateString(from: event.targetDate),
                subtitle: {
                    let comps = LunarCalendar.lunarComponents(from: event.targetDate)
                    return comps.isLeapMonth ? "闰月" : ""
                }()
            )

            // Status card
            InfoCard(
                icon: event.isCountdown ? "clock.arrow.circlepath" : "clock.badge.checkmark",
                title: event.isCountdown ? "倒数日" : "纪念日",
                value: event.isCountdown ?
                    (event.daysRemaining >= 0 ? "还有 \(event.daysRemaining) 天" : "已过 \(abs(event.daysRemaining)) 天") :
                    "已过 \(event.daysPassed) 天",
                subtitle: event.repeatYearly ? "每年重复" : ""
            )
        }
        .padding(.horizontal)
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button {
                showEditSheet = true
            } label: {
                Label("编辑", systemImage: "pencil")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .foregroundStyle(.white)

            Button {
                shareEvent()
            } label: {
                Label("分享", systemImage: "square.and.arrow.up")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.white.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .foregroundStyle(.white)
        }
        .padding(.horizontal)
    }

    // MARK: - Decorative Background
    @ViewBuilder
    private var decorativeBackground: some View {
        GeometryReader { geo in
            // Soft decorative circles
            ForEach(0..<6, id: \.self) { i in
                Circle()
                    .fill(.white.opacity(0.03))
                    .frame(width: CGFloat(60 + i * 30))
                    .position(
                        x: CGFloat.random(in: 50...geo.size.width - 50),
                        y: CGFloat.random(in: 100...geo.size.height - 100)
                    )
            }
        }
    }

    // MARK: - Share
    private func shareEvent() {
        let text = event.isCountdown ?
            "距离「\(event.name)」还有 \(event.daysRemaining) 天！" :
            "「\(event.name)」已经 \(event.daysPassed) 天了！"
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(av, animated: true)
        }
    }
}

// MARK: - Info Card
struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(.white.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }

            Spacer()
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
