import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\CountdownEvent.isPinned, order: .reverse),
                  SortDescriptor(\CountdownEvent.targetDate)])
    private var events: [CountdownEvent]

    @State private var showingAddSheet = false
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil
    @State private var colorScheme: ColorScheme = .light

    var filteredEvents: [CountdownEvent] {
        events.filter { event in
            (searchText.isEmpty || event.name.localizedCaseInsensitiveContains(searchText)) &&
            (selectedCategory == nil || event.category == selectedCategory)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(colors: [Color(.systemBackground), Color(.systemGroupedBackground)],
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Category filter
                    categoryFilterBar

                    if filteredEvents.isEmpty {
                        emptyStateView
                    } else {
                        eventListView
                    }
                }
            }
            .navigationTitle("倒数日")
            .searchable(text: $searchText, prompt: "搜索事件")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button(action: { colorScheme = .light }) {
                            Label("浅色模式", systemImage: "sun.max.fill")
                        }
                        Button(action: { colorScheme = .dark }) {
                            Label("深色模式", systemImage: "moon.fill")
                        }
                    } label: {
                        Image(systemName: colorScheme == .dark ? "moon.fill" : "sun.max.fill")
                            .font(.body)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddEventView()
            }
            .preferredColorScheme(colorScheme)
        }
    }

    // MARK: - Category Filter
    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                CategoryChip(title: "全部", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(CountdownEvent.categories, id: \.self) { cat in
                    CategoryChip(title: cat, isSelected: selectedCategory == cat) {
                        selectedCategory = selectedCategory == cat ? nil : cat
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Event List
    private var eventListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredEvents) { event in
                    NavigationLink(destination: EventDetailView(event: event)) {
                        EventCardView(event: event)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("还没有事件")
                .font(.title2)
                .fontWeight(.medium)
            Text("点击右上角 + 添加你的第一个倒数日")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Event Card
struct EventCardView: View {
    let event: CountdownEvent
    @Environment(\.colorScheme) private var colorScheme

    private var theme: AppTheme {
        ThemeManager.theme(for: event.themeName)
    }

    private var gradientColors: [Color] {
        colorScheme == .dark ? theme.darkGradient : theme.gradient
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background gradient
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(colors: gradientColors,
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                )
                .frame(height: 160)

            // Decorative pattern overlay
            decorativePattern
                .clipShape(RoundedRectangle(cornerRadius: 20))

            // Frosted glass info layer
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(event.category)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())

                    Spacer()

                    if event.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                    }

                    Text(event.isLunar ? "农历" : "公历")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                }

                Spacer()

                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .lineLimit(1)

                        Text(dateDisplayString)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 0) {
                        Text("\(abs(event.displayDays))")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .contentTransition(.numericText())

                        Text(event.isCountdown ? (event.daysRemaining >= 0 ? "天后" : "已过") : "天前")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
            }
            .padding(16)
        }
        .frame(height: 160)
        .shadow(color: theme.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
    }

    private var dateDisplayString: String {
        if event.isLunar {
            return LunarCalendar.lunarDateString(from: event.targetDate)
        } else {
            return LunarCalendar.gregorianDateString(from: event.targetDate)
        }
    }

    // Decorative pattern overlay
    @ViewBuilder
    private var decorativePattern: some View {
        GeometryReader { geo in
            ZStack {
                // Soft circles
                ForEach(0..<5, id: \.self) { i in
                    Circle()
                        .fill(.white.opacity(0.05))
                        .frame(width: CGFloat.random(in: 40...100))
                        .position(x: CGFloat.random(in: 0...geo.size.width),
                                  y: CGFloat.random(in: 0...geo.size.height))
                }
                // Diagonal lines
                ForEach(0..<3, id: \.self) { i in
                    Rectangle()
                        .fill(.white.opacity(0.03))
                        .frame(width: 1.5, height: geo.size.height * 1.5)
                        .rotationEffect(.degrees(30))
                        .offset(x: CGFloat(i) * 60 - 30)
                }
            }
        }
    }
}
