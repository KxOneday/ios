import Foundation
import SwiftData

@Model
final class CountdownEvent {
    var id: UUID
    var name: String
    var targetDate: Date
    var isLunar: Bool
    var isCountdown: Bool // true=倒数日, false=纪念日
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
