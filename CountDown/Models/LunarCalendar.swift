import Foundation

struct LunarCalendar {
    static let chineseCalendar = Calendar(identifier: .chinese)

    static func lunarDateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = chineseCalendar
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }

    static func lunarMonthDay(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = chineseCalendar
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "MM月dd日"
        return formatter.string(from: date)
    }

    static func lunarYear(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = chineseCalendar
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年"
        return formatter.string(from: date)
    }

    static func gregorianFromLunar(year: Int, month: Int, day: Int, isLeapMonth: Bool = false) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.isLeapMonth = isLeapMonth
        return chineseCalendar.date(from: components)
    }

    static func lunarComponents(from date: Date) -> (year: Int, month: Int, day: Int, isLeapMonth: Bool) {
        let components = chineseCalendar.dateComponents([.year, .month, .day], from: date)
        return (year: components.year ?? 0,
                month: components.month ?? 0,
                day: components.day ?? 0,
                isLeapMonth: components.isLeapMonth ?? false)
    }

    static func gregorianDateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }

    static func monthDay(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "MM月dd日"
        return formatter.string(from: date)
    }
}
