import SwiftUI

struct AppTheme: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
    let gradient: [Color]
    let accentColor: Color
    let darkGradient: [Color]

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: AppTheme, rhs: AppTheme) -> Bool { lhs.id == rhs.id }
}

struct ThemeManager {
    static let themes: [AppTheme] = [
        AppTheme(
            id: "flowerField",
            name: "花间",
            icon: "🌸",
            gradient: [Color(hex: "FFB7C5"), Color(hex: "FF69B4"), Color(hex: "C71585")],
            accentColor: Color(hex: "C71585"),
            darkGradient: [Color(hex: "2D1B2E"), Color(hex: "4A2040"), Color(hex: "1A0A1E")]
        ),
        AppTheme(
            id: "starSea",
            name: "星海",
            icon: "🌌",
            gradient: [Color(hex: "0F0C29"), Color(hex: "302B63"), Color(hex: "24243E")],
            accentColor: Color(hex: "7B68EE"),
            darkGradient: [Color(hex: "0A0A1A"), Color(hex: "1A1A3E"), Color(hex: "0D0D20")]
        ),
        AppTheme(
            id: "summer",
            name: "夏日",
            icon: "🏖️",
            gradient: [Color(hex: "FF9A56"), Color(hex: "FF6B6B"), Color(hex: "EE5A24")],
            accentColor: Color(hex: "EE5A24"),
            darkGradient: [Color(hex: "2D1F0E"), Color(hex: "3D1A1A"), Color(hex: "1E0F08")]
        ),
        AppTheme(
            id: "winterSnow",
            name: "冬雪",
            icon: "❄️",
            gradient: [Color(hex: "E8EAF6"), Color(hex: "9FA8DA"), Color(hex: "7986CB")],
            accentColor: Color(hex: "3F51B5"),
            darkGradient: [Color(hex: "1A1C2E"), Color(hex: "252840"), Color(hex: "0F1020")]
        ),
        AppTheme(
            id: "moonNight",
            name: "月夜",
            icon: "🌙",
            gradient: [Color(hex: "1A1A2E"), Color(hex: "16213E"), Color(hex: "0F3460")],
            accentColor: Color(hex: "E94560"),
            darkGradient: [Color(hex: "0D0D1A"), Color(hex: "101030"), Color(hex: "080820")]
        ),
        AppTheme(
            id: "birthday",
            name: "生日",
            icon: "🎂",
            gradient: [Color(hex: "F8BBD0"), Color(hex: "CE93D8"), Color(hex: "BA68C8")],
            accentColor: Color(hex: "8E24AA"),
            darkGradient: [Color(hex: "2A1525"), Color(hex: "201030"), Color(hex: "150A1A")]
        ),
        AppTheme(
            id: "anniversary",
            name: "纪念日",
            icon: "💕",
            gradient: [Color(hex: "F48FB1"), Color(hex: "EF5350"), Color(hex: "E53935")],
            accentColor: Color(hex: "C62828"),
            darkGradient: [Color(hex: "2D1520"), Color(hex: "2D1010"), Color(hex: "1A0A0A")]
        ),
        AppTheme(
            id: "study",
            name: "考试",
            icon: "📚",
            gradient: [Color(hex: "81D4FA"), Color(hex: "4FC3F7"), Color(hex: "29B6F6")],
            accentColor: Color(hex: "0277BD"),
            darkGradient: [Color(hex: "0E1E2D"), Color(hex: "152535"), Color(hex: "0A1520")]
        ),
        AppTheme(
            id: "festival",
            name: "节日",
            icon: "🎄",
            gradient: [Color(hex: "A5D6A7"), Color(hex: "66BB6A"), Color(hex: "EF5350")],
            accentColor: Color(hex: "2E7D32"),
            darkGradient: [Color(hex: "1A2D1A"), Color(hex: "1A1515"), Color(hex: "0A150A")]
        ),
        AppTheme(
            id: "custom",
            name: "自定义",
            icon: "🎨",
            gradient: [Color(hex: "CE93D8"), Color(hex: "90CAF9"), Color(hex: "80CBC4")],
            accentColor: Color(hex: "00897B"),
            darkGradient: [Color(hex: "201530"), Color(hex: "152030"), Color(hex: "102020")]
        )
    ]

    static func theme(for id: String) -> AppTheme {
        themes.first { $0.id == id } ?? themes[1]
    }
}

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
