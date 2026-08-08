import SwiftUI

struct EventDetailView: View {
    @EnvironmentObject private var eventStore: EventStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    let event: CountdownEvent

    @State private var showDeleteAlert = false
    @State private var animateNumber = false

    private var theme: AppTheme {
        ThemeManager.theme(for: event.themeName)
    }

    private var gradientColors: [Color] {
        colorScheme == .dark ? theme.darkGradient : theme.gradient
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: gradientColors,
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            decorativeBackground

            ScrollView {
                VStack(spacing: 32) {
                    mainCountdownView
                    infoCardsSection
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
                        eventStore.togglePin(event)
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
                eventStore.delete(event)
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
            Text(event.category)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())

            Text(event.name)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            ZStack {
                Text("\(abs(event.displayDays))")
                    .font(.system(size: 96, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white.opacity(0.15))
                    .blur(radius: 10)
                    .scaleEffect(animateNumber ? 1 : 0.5)

                Text("\(abs(event.displayDays))")
                    .font(.system(size: 96, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .scaleEffect(animateNumber ? 1 : 0.5)
            }

            Text(event.isCountdown ?
                 (event.daysRemaining >= 0 ? "天后" : "天前已过") :
                 "天前")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(0.8))

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
            InfoCard(
                icon: "calendar",
                title: "公历日期",
                value: LunarCalendar.gregorianDateString(from: event.targetDate),
                subtitle: LunarCalendar.monthDay(from: event.targetDate)
            )

            InfoCard(
                icon: "moon.stars",
                title: "农历日期",
                value: LunarCalendar.lunarDateString(from: event.targetDate),
                subtitle: {
                    let comps = LunarCalendar.lunarComponents(from: event.targetDate)
                    return comps.isLeapMonth ? "闰月" : ""
                }()
            )

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

    @ViewBuilder
    private var decorativeBackground: some View {
        GeometryReader { geo in
            ForEach(0..<6, id: \.self) { _ in
                Circle()
                    .fill(.white.opacity(0.03))
                    .frame(width: 80, height: 80)
                    .position(
                        x: CGFloat.random(in: 50...max(51, geo.size.width - 50)),
                        y: CGFloat.random(in: 100...max(101, geo.size.height - 100))
                    )
            }
        }
    }

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
