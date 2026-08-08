import Foundation

struct CountdownEvent: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var targetDate: Date
    var isLunar: Bool
    var isCountdown: Bool
    var category: String
    var themeName: String
    var reminderDaysBefore: Int
    var repeatYearly: Bool
    var isPinned: Bool
    var createdAt: Date

    init(name: String,
         targetDate: Date,
         isLunar: Bool = false,
         isCountdown: Bool = true,
         category: String = "其他",
         themeName: String = "starSea",
         reminderDaysBefore: Int = 0,
         repeatYearly: Bool = false,
         isPinned: Bool = false) {
        self.id = UUID()
        self.name = name
        self.targetDate = targetDate
        self.isLunar = isLunar
        self.isCountdown = isCountdown
        self.category = category
        self.themeName = themeName
        self.reminderDaysBefore = reminderDaysBefore
        self.repeatYearly = repeatYearly
        self.isPinned = isPinned
        self.createdAt = Date()
    }

    var daysRemaining: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.startOfDay(for: targetDate)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    var daysPassed: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: targetDate)
        let end = calendar.startOfDay(for: Date())
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    var displayDays: Int {
        isCountdown ? daysRemaining : daysPassed
    }

    static let categories = ["生日", "纪念日", "节日", "考试", "工作", "其他"]
}

// MARK: - Event Store (UserDefaults-based)
class EventStore: ObservableObject {
    @Published var events: [CountdownEvent] = []

    private let key = "countdown_events"

    init() {
        load()
    }

    func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([CountdownEvent].self, from: data) else {
            events = []
            return
        }
        events = decoded
    }

    func save() {
        if let data = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func add(_ event: CountdownEvent) {
        events.append(event)
        save()
    }

    func delete(_ event: CountdownEvent) {
        events.removeAll { $0.id == event.id }
        save()
    }

    func update(_ event: CountdownEvent) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
            save()
        }
    }

    func togglePin(_ event: CountdownEvent) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index].isPinned.toggle()
            save()
        }
    }

    var sortedEvents: [CountdownEvent] {
        events.sorted { a, b in
            if a.isPinned != b.isPinned { return a.isPinned }
            return a.targetDate < b.targetDate
        }
    }
}
