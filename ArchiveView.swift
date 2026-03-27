import SwiftUI
import UIKit

struct ArchiveView: View {
    @ObservedObject var store = JournalStore.shared
    
    @State private var selectedDateForDetail: Date?
    @State private var activeSheet: ActiveSheet?
    @State private var showDrawingEditor = false
    @State private var selectedIndexForDrawing = 0
    @State private var currentSubtitle: String = ""
    // MARK: - Wordle
    let subtitles = [
        "Memories at a glance.", "Time flies, memories stay.", "A journey through your days.",
        "Every day counts.", "Reflect on your past."
    ]
    
    enum ActiveSheet: Identifiable {
        case todayThatYear, specialDates, yearSummary(Int)
        var id: String {
            switch self {
            case .todayThatYear: return "todayThatYear"
            case .specialDates: return "specialDates"
            case .yearSummary(let y): return "year-\(y)"
            }
        }
    }

    var body: some View {
        let headerA11y = "Archive. \(currentSubtitle)"
        
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(alignment: .firstTextBaseline) {
                Text("Archive").font(.custom("Baskerville-SemiBoldItalic", size: 80)).foregroundColor(.primary)
                Spacer()
                Text(currentSubtitle).font(.custom("Baskerville", size: 28)).italic().foregroundColor(.gray)
            }
            .padding(.top, 50).padding(.horizontal, 50).padding(.bottom, 20)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(headerA11y)
            .accessibilityAddTraits(.isHeader)
            .onAppear { if currentSubtitle.isEmpty { currentSubtitle = subtitles.randomElement() ?? "" } }
            
            // 内容区
            HStack(spacing: 0) {
                ArchiveLeftScrollView(store: store, selectedIndexForDrawing: $selectedIndexForDrawing, showDrawingEditor: $showDrawingEditor, selectedDateForDetail: $selectedDateForDetail)
                ArchiveRightPanelView(activeSheet: $activeSheet)
            }
        }
        .sheet(item: $activeSheet) { item in
            ZStack {
                Color(.systemBackground).edgesIgnoringSafeArea(.all)
                switch item {
                case .todayThatYear: TodayThatYearView(store: store)
                case .specialDates: SpecialDatesView(store: store) { date in dismissSheetAndOpen(date) }
                case .yearSummary(let year): YearSummaryView(year: year, store: store) { date in dismissSheetAndOpen(date) }
                }
            }
        }
        .fullScreenCover(isPresented: $showDrawingEditor) {
            EditorView(date: Date(), initialIndex: selectedIndexForDrawing)
        }
        .fullScreenCover(item: $selectedDateForDetail) { date in
            DayDetailView(date: date, store: store)
        }
    }
    
    private func dismissSheetAndOpen(_ date: Date) {
        activeSheet = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { selectedDateForDetail = date }
    }
}

// MARK: - Left Side
struct ArchiveLeftScrollView: View {
    @ObservedObject var store: JournalStore
    @Binding var selectedIndexForDrawing: Int
    @Binding var showDrawingEditor: Bool
    @Binding var selectedDateForDetail: Date?
    
    var availableMonths: [Date] {
        var months: [Date] = []
        let calendar = Calendar.current
        guard let startDate = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)) else { return [] }
        var currentDate = startDate
        let now = Date()
        while currentDate <= now {
            months.append(currentDate)
            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentDate) else { break }
            currentDate = nextMonth
        }
        return months.reversed()
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 40) {
                // Today 模块
                VStack(alignment: .leading, spacing: 10) {
                    Text("Today").font(.custom("ChalkboardSE-Bold", size: 36)).foregroundColor(.primary).accessibilityAddTraits(.isHeader)
                    HStack(alignment: .center, spacing: 20) {
                        let today = Date()
                        let entry = store.getEntry(for: today)
                        let todayTitles = ["Mood", "Things", "Thoughts"]
                        ForEach(0..<3, id: \.self) { index in
                            TodayArchiveCard(title: todayTitles[index], data: entry.drawings[index]) {
                                selectedIndexForDrawing = index
                                showDrawingEditor = true
                            }
                        }
                    }
                }
                
                // 月份列表
                ForEach(availableMonths, id: \.self) { monthDate in
                    let year = Calendar.current.component(.year, from: monthDate)
                    let month = Calendar.current.component(.month, from: monthDate)
                    let monthName = monthDate.formatted(.dateTime.month(.wide))
                    CalendarMonthView(year: year, month: month, monthName: monthName, store: store) { date in
                        selectedDateForDetail = date
                    }
                }
                Spacer(minLength: 100)
            }
            .padding(.leading, 50).padding(.trailing, 30)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - RIght Side
struct ArchiveRightPanelView: View {
    @Binding var activeSheet: ArchiveView.ActiveSheet?
    var body: some View {
        VStack(spacing: 25) {
            Spacer().frame(height: 40)
            RightPanelButton(title: "Today That Year") { activeSheet = .todayThatYear }
            RightPanelButton(title: "Special Dates") { activeSheet = .specialDates }
            RightPanelButton(title: "Year: 2026") { activeSheet = .yearSummary(2026) }
            Spacer()
        }
        .frame(width: 300)
        .padding(.trailing, 40)
    }
}

// MARK: - Elements
struct TodayArchiveCard: View {
    let title: String
    let data: Data?
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 12).stroke(Color.primary, lineWidth: 3).frame(width: 80, height: 100)
                if let data = data, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage).resizable().scaledToFill().frame(width: 76, height: 96).clipped().cornerRadius(10)
                } else {
                    Image(systemName: "plus").font(.system(size: 30, weight: .thin)).foregroundColor(.gray)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Today's \(title) entry")
        .accessibilityValue(data != nil ? "Contains drawing" : "Empty")
        .accessibilityHint("Double tap to open the drawing editor.")
    }
}

struct CalendarMonthView: View {
    let year: Int
    let month: Int
    let monthName: String
    @ObservedObject var store: JournalStore
    let onTapDate: (Date) -> Void
    
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(monthName).font(.custom("ChalkboardSE-Bold", size: 28)).foregroundColor(.primary)
                Spacer()
                Text(String(format: "%d", year)).font(.custom("ChalkboardSE-Bold", size: 24)).foregroundColor(.gray)
            }
            .padding(.bottom, 5)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(monthName) \(year)")
            .accessibilityAddTraits(.isHeader)
            
            ZStack {
                RoundedRectangle(cornerRadius: 16).stroke(Color.primary, lineWidth: 3).background(Color.primary.opacity(0.05))
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(0..<startingSpaces, id: \.self) { _ in Text("").accessibilityHidden(true) }
                    ForEach(1...daysInMonth, id: \.self) { day in
                        let date = getDate(day: day)
                        let hasData = store.hasData(for: date)
                        Button(action: { if hasData { onTapDate(date) } }) {
                            ZStack {
                                if hasData {
                                    RoundedRectangle(cornerRadius: 6).fill(Color.primary).frame(height: 36)
                                    Text("\(day)").font(.custom("ChalkboardSE-Bold", size: 18)).foregroundColor(Color(.systemBackground))
                                } else {
                                    Text("\(day)").font(.custom("ChalkboardSE-Light", size: 18)).foregroundColor(.gray.opacity(0.5))
                                }
                            }
                        }
                        .disabled(!hasData)
                        .accessibilityLabel("\(monthName) \(day)")
                        .accessibilityValue(hasData ? "Entries available" : "No entries")
                        .accessibilityHint(hasData ? "Double tap to view details." : "")
                    }
                }
                .padding(20)
            }
        }
    }
    var daysInMonth: Int { Calendar.current.range(of: .day, in: .month, for: getDate(day: 1))!.count }
    var startingSpaces: Int { Calendar.current.component(.weekday, from: getDate(day: 1)) - 1 }
    func getDate(day: Int) -> Date { Calendar.current.date(from: DateComponents(year: year, month: month, day: day))! }
}

struct RightPanelButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 12).stroke(Color.primary, lineWidth: 3).rotationEffect(.degrees(Double.random(in: -0.5...0.5)))
                Text(title).font(.custom("ChalkboardSE-Bold", size: 24)).foregroundColor(.primary)
            }
            .frame(height: 75).shadow(color: Color.primary.opacity(0.05), radius: 5, x: 0, y: 0)
        }
        .accessibilityLabel(title)
        .accessibilityHint("Opens \(title) view.")
    }
}

struct ImageWrapper: Identifiable { let id = UUID(); let image: UIImage }

struct DayDetailView: View {
    let date: Date
    @ObservedObject var store: JournalStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedImageWrapper: ImageWrapper?
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack {
                HStack {
                    Button(action: { dismiss() }) { Image(systemName: "xmark.circle.fill").font(.largeTitle).foregroundColor(.primary) }.accessibilityLabel("Close")
                    Spacer()
                    Text(date.formatted(date: .long, time: .omitted)).font(.custom("Baskerville", size: 32)).foregroundColor(.primary).accessibilityAddTraits(.isHeader)
                    Spacer()
                    Spacer().frame(width: 40)
                }
                .padding(40)
                let entry = store.getEntry(for: date)
                HStack(spacing: 30) {
                    DetailCard(title: "Mood", data: entry.drawings[0]).onTapGesture { if let d = entry.drawings[0], let img = UIImage(data: d) { selectedImageWrapper = ImageWrapper(image: img) } }
                    DetailCard(title: "Thoughts", data: entry.drawings[1]).onTapGesture { if let d = entry.drawings[1], let img = UIImage(data: d) { selectedImageWrapper = ImageWrapper(image: img) } }
                    DetailCard(title: "Things", data: entry.drawings[2]).onTapGesture { if let d = entry.drawings[2], let img = UIImage(data: d) { selectedImageWrapper = ImageWrapper(image: img) } }
                }
                Spacer()
                Text("Tap any card to view full screen").font(.custom("ChalkboardSE-Light", size: 16)).foregroundColor(.gray).padding(.bottom, 20).accessibilityHidden(true)
            }
        }
        .fullScreenCover(item: $selectedImageWrapper) { wrapper in FullScreenImageView(image: wrapper.image) }
    }
}

struct DetailCard: View {
    let title: String
    let data: Data?
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20).stroke(Color.primary, lineWidth: 2)
            VStack {
                Text(title).font(.custom("Baskerville-Bold", size: 28)).foregroundColor(.primary).padding(20)
                if let data = data, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage).resizable().scaledToFit().frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.white).cornerRadius(10).padding()
                } else {
                    Spacer(); Text("No Drawing").italic().foregroundColor(.gray); Spacer()
                }
            }
        }
        .frame(width: 250, height: 400).contentShape(Rectangle())
        .accessibilityElement(children: .ignore).accessibilityLabel("\(title) drawing")
        .accessibilityValue(data != nil ? "Contains drawing" : "Empty")
        .accessibilityHint(data != nil ? "Double tap to view full screen" : "")
        .accessibilityAddTraits(data != nil ? .isButton : .isStaticText)
    }
}

struct FullScreenImageView: View {
    let image: UIImage
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ZoomableScrollView { Image(uiImage: image).resizable().scaledToFit().accessibilityLabel("Zoomable full screen drawing image").accessibilityAddTraits(.isImage) }.edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) { Image(systemName: "xmark.circle.fill").symbolRenderingMode(.hierarchical).foregroundColor(.white).font(.system(size: 30)).padding() }.accessibilityLabel("Close full screen view")
                }
                Spacer()
            }
        }
    }
}

// MARK: - UIKit Bridging
struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    private var content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator; scrollView.maximumZoomScale = 5.0; scrollView.minimumZoomScale = 1.0; scrollView.bouncesZoom = true; scrollView.backgroundColor = .black; scrollView.showsHorizontalScrollIndicator = false; scrollView.showsVerticalScrollIndicator = false
        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = true; hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]; hostedView.backgroundColor = .clear
        scrollView.addSubview(hostedView)
        return scrollView
    }
    func updateUIView(_ uiView: UIScrollView, context: Context) { context.coordinator.hostingController.rootView = self.content }
    func makeCoordinator() -> Coordinator { Coordinator(hostingController: UIHostingController(rootView: self.content)) }
    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>
        init(hostingController: UIHostingController<Content>) { self.hostingController = hostingController }
        func viewForZooming(in scrollView: UIScrollView) -> UIView? { hostingController.view }
    }
}

struct TodayThatYearView: View {
    @ObservedObject var store: JournalStore
    @Environment(\.dismiss) var dismiss
    var pastYearsDates: [Date] {
        let today = Date(); var dates: [Date] = []
        for i in 1...5 { if let d = Calendar.current.date(byAdding: .year, value: -i, to: today) { dates.append(d) } }
        return dates
    }
    var body: some View {
        VStack {
            SheetHeader(title: "On This Day", dismiss: dismiss)
            ScrollView {
                VStack(spacing: 30) {
                    ForEach(pastYearsDates, id: \.self) { date in
                        let yearStr = String(Calendar.current.component(.year, from: date))
                        let hasData = store.hasData(for: date)
                        VStack(alignment: .leading) {
                            Text(yearStr).font(.title2).bold().foregroundColor(.primary).accessibilityAddTraits(.isHeader)
                            if hasData {
                                let entry = store.getEntry(for: date)
                                HStack(spacing: 10) {
                                    ForEach(0..<3) { i in
                                        if let data = entry.drawings[i], let uiImage = UIImage(data: data) {
                                            Image(uiImage: uiImage).resizable().scaledToFit().frame(width: 80, height: 100).background(Color.white).cornerRadius(8)
                                        }
                                    }
                                }
                                .accessibilityElement(children: .ignore).accessibilityLabel("Entries for this date")
                            } else { Text("No sketches recorded.").italic().foregroundColor(.gray) }
                        }
                        .padding().background(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.3)))
                    }
                }
                .padding()
            }
        }
        .background(Color(.systemBackground))
    }
}

struct SpecialDatesView: View {
    @ObservedObject var store: JournalStore
    let onSelect: (Date) -> Void
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            SheetHeader(title: "Special Dates (2026)", dismiss: dismiss)
            List {
                ForEach(HolidayHelper.getHolidays(year: 2026), id: \.1) { item in
                    let hasData = store.hasData(for: item.1)
                    Button(action: { if hasData { onSelect(item.1) } }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.0).font(.headline).foregroundColor(.yellow.opacity(0.8))
                                Text(item.1.formatted(date: .abbreviated, time: .omitted)).font(.caption).foregroundColor(.gray)
                            }
                            Spacer()
                            if hasData { Image(systemName: "photo").foregroundColor(.primary); Image(systemName: "chevron.right").foregroundColor(.gray) } else { Text("No Data").italic().foregroundColor(.gray.opacity(0.5)) }
                        }
                    }
                    .disabled(!hasData).listRowBackground(Color(.systemBackground)).accessibilityElement(children: .combine).accessibilityHint(hasData ? "Double tap to view details." : "")
                }
            }
            .listStyle(.plain)
        }
        .background(Color(.systemBackground))
    }
}

struct YearSummaryView: View {
    let year: Int
    @ObservedObject var store: JournalStore
    let onSelect: (Date) -> Void
    @Environment(\.dismiss) var dismiss
    
    // optimize app loading speed
    let monthSymbols = Calendar.current.monthSymbols
    
    var body: some View {
        VStack {
            SheetHeader(title: "Year \(String(format: "%d", year)) Summary", dismiss: dismiss)
            ScrollView {
                VStack(spacing: 30) {
                    ForEach(1...12, id: \.self) { month in
                        CalendarMonthView(year: year, month: month, monthName: monthSymbols[month - 1], store: store, onTapDate: onSelect)
                    }
                }
                .padding()
            }
        }
        .background(Color(.systemBackground))
    }
}

struct SheetHeader: View {
    let title: String
    let dismiss: DismissAction
    var body: some View {
        HStack {
            Text(title).font(.custom("Baskerville-Bold", size: 28)).foregroundColor(.primary).accessibilityAddTraits(.isHeader)
            Spacer()
            Button("Done") { dismiss() }.font(.headline).foregroundColor(.yellow)
        }
        .padding(30).background(Color.primary.opacity(0.05))
    }
}

extension Date: @retroactive Identifiable {
    public var id: TimeInterval { return self.timeIntervalSince1970 }
}
