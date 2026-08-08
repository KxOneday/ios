import WidgetKit
import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255
            g = Double((int >> 8) & 0xFF) / 255
            b = Double(int & 0xFF) / 255
        default:
            r = 0; g = 0; b = 0
        }
        self.init(red: r, green: g, blue: b)
    }
}

struct CountDownWidget: Widget {
    let kind: String = "CountDownWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CountDownTimelineProvider()) { entry in
            CountDownWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("倒数日")
        .description("查看你的倒数日和纪念日")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct CountDownTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> CountDownEntry {
        CountDownEntry(date: Date(), events: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (CountDownEntry) -> Void) {
        let entry = CountDownEntry(date: Date(), events: loadSampleEvents())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CountDownEntry>) -> Void) {
        let entry = CountDownEntry(date: Date(), events: loadSampleEvents())
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadSampleEvents() -> [WidgetEvent] {
        // Load from shared UserDefaults or App Group
        guard let data = UserDefaults(suiteName: "group.com.countdown.app")?.data(forKey: "events"),
              let events = try? JSONDecoder().decode([WidgetEvent].self, from: data) else {
            return []
        }
        return events
    }
}

struct CountDownEntry: TimelineEntry {
    let date: Date
    let events: [WidgetEvent]
}

struct WidgetEvent: Codable, Identifiable {
    let id: String
    let name: String
    let targetDate: Date
    let themeName: String
    let isCountdown: Bool

    var daysRemaining: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.startOfDay(for: targetDate)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    var displayDays: Int {
        let days = daysRemaining
        return isCountdown ? days : -days
    }
}

struct CountDownWidgetEntryView: View {
    var entry: CountDownEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        case .systemLarge:
            largeWidget
        default:
            smallWidget
        }
    }

    // MARK: - Small Widget
    private var smallWidget: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "302B63"), Color(hex: "24243E")],
                           startPoint: .topLeading, endPoint: .bottomTrailing)

            if let event = entry.events.first {
                VStack(spacing: 8) {
                    Text(event.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.8))
                        .lineLimit(1)

                    Text("\(abs(event.daysRemaining))")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(event.isCountdown ? "天后" : "天前")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding()
            } else {
                VStack(spacing: 6) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.title2)
                    Text("添加事件")
                        .font(.caption)
                }
                .foregroundStyle(.white.opacity(0.7))
            }
        }
    }

    // MARK: - Medium Widget
    private var mediumWidget: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0F0C29"), Color(hex: "302B63")],
                           startPoint: .leading, endPoint: .trailing)

            HStack(spacing: 16) {
                ForEach(entry.events.prefix(3)) { event in
                    VStack(spacing: 6) {
                        Text(event.name)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                            .lineLimit(1)
                        Text("\(abs(event.daysRemaining))")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text(event.isCountdown ? "天后" : "天前")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
        }
    }

    // MARK: - Large Widget
    private var largeWidget: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0F0C29"), Color(hex: "302B63"), Color(hex: "24243E")],
                           startPoint: .top, endPoint: .bottom)

            VStack(spacing: 12) {
                Text("倒数日")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .leading)

                ForEach(entry.events.prefix(5)) { event in
                    HStack {
                        Text(event.name)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        Spacer()
                        Text("\(abs(event.daysRemaining))")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text(event.isCountdown ? "天后" : "天前")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(.vertical, 4)

                    if event.id != entry.events.prefix(5).last?.id {
                        Divider().background(.white.opacity(0.2))
                    }
                }

                Spacer()
            }
            .padding()
        }
    }
}

// Widget bundle
@main
struct CountDownWidgetBundle: WidgetBundle {
    var body: some Widget {
        CountDownWidget()
    }
}
