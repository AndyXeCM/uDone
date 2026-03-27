import SwiftUI

struct HomeView: View {
    @State private var cardsExpanded: Bool = false
    @State private var currentDate = Date()
    @State private var showDrawingEditor = false
    @State private var selectedIndexForDrawing: Int = 0
    @State private var currentSubtitle: String = ""
    
    // MARK: - Wordle
    let subtitles = [
        "You've done a lot!", "Keep up the good work.", "Small steps, big progress.",
        "Reflect is productive too.", "Stay creative today."
    ]
    
    @ObservedObject var store = JournalStore.shared
    static let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        let isComplete = store.isDayComplete(for: currentDate)
        let streakCount = store.currentStreak()
        let statusA11y = isComplete ? "You have completed today's recordings." : "You have not completed today's recordings yet."
        let toggleA11y = cardsExpanded ? "Collapse cards" : "Expand cards"
        let headerA11y = "uDone app. \(currentSubtitle)"
        
        VStack(alignment: .leading, spacing: 0) {
            
            // --- 统一对齐的 Header ---
            HStack(alignment: .firstTextBaseline) {
                Text("uDone")
                    .font(.custom("Palatino", size: 80))
                    .bold()
                    .italic()
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(currentSubtitle)
                    .font(.custom("Palatino", size: 28))
                    .italic()
                    .foregroundColor(.gray)
            }
            .padding(.top, 50)
            .padding(.leading, 50)
            .padding(.trailing, 50)
            .padding(.bottom, 20)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(headerA11y)
            .accessibilityAddTraits(.isHeader)
            .onAppear {
                if currentSubtitle.isEmpty { currentSubtitle = subtitles.randomElement() ?? "" }
            }
            
            GeometryReader { geo in
                HStack(alignment: .center, spacing: 0) {
                    
                    // MARK: Info Module
                    VStack(alignment: .leading, spacing: 18) {
                        Spacer()
                        
                        HStack(spacing: 12) {
                            Image(systemName: "sun.max.fill")
                                .font(.largeTitle).foregroundColor(.yellow.opacity(0.8))
                                .accessibilityHidden(true)
                            Text("Today is...")
                                .font(.custom("Palatino", size: 30))
                                .foregroundColor(.primary)
                        }
                        .accessibilityAddTraits(.isHeader)
                        
                        // Palatino
                        VStack(alignment: .leading, spacing: 2) {
                            Text(currentDate.formatted(.dateTime.weekday(.wide)))
                                .font(.custom("Palatino", size: 36))
                                .bold()
                                .foregroundColor(.gray)
                                .padding(.bottom, 2)
                            
                            Text(currentDate.formatted(.dateTime.month().day()))
                                .font(.custom("Palatino", size: 70))
                                .bold()
                                .foregroundColor(.primary)
                            
                            Text("It is \(currentDate.formatted(date: .omitted, time: .shortened))")
                                .font(.custom("Palatino", size: 28))
                                .bold()
                                .foregroundColor(.primary)
                                .padding(.top, 8)
                        }
                        .accessibilityElement(children: .combine)
                        
                        // MARK: - Status Module
                        Group {
                            if isComplete {
                                Text("and you have done\ntoday's recordings! 🎉")
                                    .foregroundColor(.yellow.opacity(0.9))
                            } else {
                                Text("and you haven't done\ntoday's recordings.")
                                    .foregroundColor(.gray.opacity(0.8))
                            }
                        }
                        .font(.custom("Palatino", size: 24))
                        .padding(.top, 10)
                        .lineSpacing(6)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(statusA11y)
                        
                        // Streak Module
                        HStack(spacing: 8) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(streakCount > 0 ? .orange : .gray.opacity(0.4))
                                .font(.system(size: 20))
                            
                            Text("Current streak: \(streakCount) \(streakCount <= 1 ? "day" : "days")")
                                .font(.custom("ChalkboardSE-Bold", size: 20))
                                .foregroundColor(streakCount > 0 ? .primary : .gray.opacity(0.6))
                        }
                        .padding(.top, 12)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Current streak is \(streakCount) \(streakCount <= 1 ? "day" : "days")")
                        
                        Spacer()
                        Spacer()
                    }
                    .frame(width: geo.size.width * 0.35, alignment: .leading)
                    .padding(.leading, 50)
                    
                    // MARK: -Card Module
                    ZStack {
                        Color.white.opacity(0.001)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    cardsExpanded.toggle()
                                }
                            }
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel(toggleA11y)
                            .accessibilityHint("Double tap to toggle the cards view.")
                            .accessibilityAddTraits(.isButton)
                        
                        let entry = store.getEntry(for: currentDate)
                        
                        ZStack {
                            ForEach(0..<3) { index in
                                let cardTitle = ["Mood", "Things", "Thoughts"][index]
                                let rotation = [-12.0, 0.0, 12.0][index]
                                let zIndex = [1.0, 3.0, 2.0][index]
                                
                                HomeSingleCardView(
                                    title: cardTitle,
                                    data: entry.drawings[index],
                                    isExpanded: cardsExpanded
                                )
                                .position(
                                    x: (cardsExpanded ? getExpandedX(index: index, width: geo.size.width * 0.65) : (geo.size.width * 0.65) / 2) - 30,
                                    y: (geo.size.height / 2) - 40
                                )
                                .rotationEffect(.degrees(cardsExpanded ? 0 : rotation), anchor: .bottom)
                                .zIndex(zIndex)
                                .onTapGesture {
                                    if cardsExpanded {
                                        selectedIndexForDrawing = index
                                        // 修复：将展示弹窗的操作放到主线程异步队列中
                                        // 确保 SwiftUI 已经接收到了全新的 selectedIndexForDrawing
                                        DispatchQueue.main.async {
                                            showDrawingEditor = true
                                        }
                                    } else {
                                        withAnimation(.spring()) { cardsExpanded = true }
                                    }
                                }
                            }
                        }
                    }
                    .frame(width: geo.size.width * 0.65)
                }
            }
        }
        .onReceive(Self.timer) { input in currentDate = input }
        .fullScreenCover(isPresented: $showDrawingEditor) {
            EditorView(date: currentDate, initialIndex: selectedIndexForDrawing)
                // 修复：强制绑定 ID
                // 这意味着只要 selectedIndex 改变，SwiftUI 就会强制重新初始化 EditorView 里的 @State
                .id(selectedIndexForDrawing)
        }
    }
    
    func getExpandedX(index: Int, width: CGFloat) -> CGFloat {
        let center = width / 2
        let spacing = min(width * 0.28, 220)
        
        if index == 0 { return center - spacing }
        if index == 1 { return center }
        if index == 2 { return center + spacing }
        
        return center
    }
}

struct HomeSingleCardView: View {
    let title: String
    let data: Data?
    let isExpanded: Bool
    
    var body: some View {
        let a11yVal = data != nil ? "Contains drawing" : "Empty"
        let a11yHint = isExpanded ? "Double tap to edit drawing" : "Double tap to expand cards"
        let labelStr = "\(title) record"
        
        ZStack {
            RoundedRectangle(cornerRadius: 24).fill(Color(.systemBackground))
            RoundedRectangle(cornerRadius: 24).stroke(Color.primary, lineWidth: 2)
            
            VStack {
                Text(title)
                    .font(.custom("Palatino", size: 32))
                    .bold()
                    .foregroundColor(.primary)
                    .padding(.top, 20)
                ZStack {
                    if let data = data, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable().scaledToFit().frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white).cornerRadius(10).padding()
                    } else if isExpanded {
                        Image(systemName: "plus")
                            .font(.system(size: 40, weight: .thin))
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxHeight: .infinity)
                Spacer()
            }
        }
        .frame(width: 220, height: 360)
        .shadow(color: Color.primary.opacity(0.3), radius: 15, x: 0, y: 10)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(labelStr)
        .accessibilityValue(a11yVal)
        .accessibilityHint(a11yHint)
        .accessibilityAddTraits(.isButton)
    }
}
