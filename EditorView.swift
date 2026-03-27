import SwiftUI
import PencilKit

struct EditorView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var store = JournalStore.shared
    @Environment(\.colorScheme) var colorScheme // 监听系统模式
    
    let date: Date
    
    // 状态
    @State private var currentCategoryIndex: Int
    @State private var canvasView = PKCanvasView()
    @State private var placedStickers: [StickerItem] = []
    
    // 工具栏管理器
    @State private var toolPicker = PKToolPicker()
    
    let categories = ["Mood", "Things", "Thoughts"]
    
    init(date: Date, initialIndex: Int) {
        self.date = date
        _currentCategoryIndex = State(initialValue: initialIndex)
    }
    
    var currentCategory: String {
        categories[currentCategoryIndex]
    }
    
    // Speed Up the App
    var body: some View {
        HStack(spacing: 0) {
            leftSidebar
            rightCanvasArea
        }
        .ignoresSafeArea()
        .onAppear(perform: setupOnAppear)
        .gesture(swipeGesture)
    }
    
    // MARK: - View Modules
    
    private var leftSidebar: some View {
        VStack(spacing: 0) {
            sidebarHeader
            
            Text("swipe to switch ->")
                .font(.custom("ChalkboardSE-Regular", size: 14))
                .foregroundColor(.primary)
                .padding(.bottom, 10)
                .accessibilityHidden(true) // 隐藏冗余提示
            
            sidebarLibrary
            
            Spacer()
            
            sidebarBottomButtons
        }
        .frame(width: 350)
        .background(Color(.systemBackground))
        .zIndex(10)
    }
    
    private var rightCanvasArea: some View {
        ZStack {
            Color(.systemBackground)
            
            DrawingCanvasView(canvasView: $canvasView)
                .accessibilityLabel("Drawing canvas")
            
            ForEach(placedStickers) { sticker in
                stickerOverlay(for: sticker)
            }
        }
        .clipped()
    }
    
    // 💡 UI统一：返回键与标题改为背景镂空、描边风格
    private var sidebarHeader: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.uturn.backward")
                    .font(.title3)
                    .foregroundColor(.primary) // 统一为 Primary
                    .padding(12)
                    .background(Color(.systemBackground)) // 统一背景
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.primary, lineWidth: 2)) // 增加描边呼应风格
            }
            .accessibilityLabel("Back")
            .accessibilityHint("Go back without saving.")
            
            Spacer()
            Text("#\(currentCategory)")
                .font(.custom("ChalkboardSE-Bold", size: 24))
                .foregroundColor(.primary) // 统一为 Primary
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemBackground)) // 统一背景
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary, lineWidth: 2))
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
        .padding()
    }
    
    private var sidebarLibrary: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                emojiSection
                ratingSection
                tagsSection
            }
            .padding(.horizontal)
        }
    }
    
    private var emojiSection: some View {
        VStack(alignment: .leading) {
            Text("EMOJIS").foregroundColor(.primary).font(.custom("ChalkboardSE-Bold", size: 14))
                .accessibilityAddTraits(.isHeader)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], spacing: 10) {
                ForEach(["😀", "😢", "😡", "😴", "🥳", "🤔", "👻", "⚡️", "🌧️", "☀️"], id: \.self) { emoji in
                    Text(emoji).font(.system(size: 32))
                        .onTapGesture { addSticker(emoji) }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(emoji)
                        .accessibilityAddTraits(.isButton)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary, lineWidth: 2))
    }
    
    // 💡 UI统一：评分星星改为镂空风格
    private var ratingSection: some View {
        VStack(spacing: 8) {
            Text("RATING").foregroundColor(.primary).font(.custom("ChalkboardSE-Bold", size: 14))
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
            
            HStack(spacing: 8) {
                ForEach(1...4, id: \.self) { star in
                    let starLabel = "\(star) star"
                    Text("\(star)★")
                        .font(.custom("ChalkboardSE-Bold", size: 18))
                        .foregroundColor(.primary) // 统一为 Primary
                        .frame(maxWidth: .infinity).frame(height: 44)
                        .background(Color(.systemBackground)) // 统一背景
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.primary, lineWidth: 1.5))
                        .onTapGesture { addSticker("\(star)★", isTemplate: true) }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(starLabel)
                        .accessibilityAddTraits(.isButton)
                }
            }
        }
    }
    
    private var tagsSection: some View {
        VStack(spacing: 12) {
            Text("TAGS").foregroundColor(.primary).font(.custom("ChalkboardSE-Bold", size: 14))
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
            Group {
                TagButton(text: "Productivity")
                TagButton(text: "Burnout")
                TagButton(text: "Joy")
                TagButton(text: "Anxiety")
                TagButton(text: "Peace")
                TagButton(text: "Chaos")
            }
        }
    }
    
    // 💡 UI统一：Save 按钮也统一为镂空描边风格
    private var sidebarBottomButtons: some View {
        VStack(spacing: 12) {
            Button(action: clearCanvas) {
                Text("clear")
                    .font(.custom("ChalkboardSE-Bold", size: 18))
                    .foregroundColor(.primary)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary, lineWidth: 1))
            }
            .accessibilityLabel("Clear canvas")
            
            Button(action: saveCanvasAction) {
                Text("save!")
                    .font(.custom("ChalkboardSE-Bold", size: 24))
                    .foregroundColor(.primary) // 统一为 Primary
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground)) // 统一背景
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary, lineWidth: 2))
            }
            .accessibilityLabel("Save drawing")
        }
        .padding(20)
    }
    
    private func stickerOverlay(for sticker: StickerItem) -> some View {
        Text(sticker.content)
            .font(sticker.isTemplate ? .custom("ChalkboardSE-Regular", size: 24) : .system(size: 60))
            .foregroundColor(.primary)
            .padding(sticker.isTemplate ? 10 : 0)
            .background(sticker.isTemplate ? Color(.systemBackground).opacity(0.8) : Color.clear)
            .overlay(sticker.isTemplate ? RoundedRectangle(cornerRadius: 8).stroke(Color.primary, lineWidth: 2) : nil)
            .position(sticker.location)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if let index = placedStickers.firstIndex(where: { $0.id == sticker.id }) {
                            placedStickers[index].location = value.location
                        }
                    }
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(sticker.content)
            .accessibilityHint("Placed sticker")
    }
    
    // MARK: - Logic Module
    
    private func setupOnAppear() {
        loadTodayData()
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
    }
    
    private var swipeGesture: some Gesture {
        DragGesture()
            .onEnded { value in
                if value.translation.width < -50 {
                    switchCategory(offset: 1)
                } else if value.translation.width > 50 {
                    switchCategory(offset: -1)
                }
            }
    }
    
    func TagButton(text: String) -> some View {
        let labelStr = "\(text) tag"
        return Text(text)
            .font(.custom("ChalkboardSE-Regular", size: 16))
            .foregroundColor(.primary)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.primary, lineWidth: 1))
            .onTapGesture { addSticker(text, isTemplate: true) }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(labelStr)
            .accessibilityAddTraits(.isButton)
    }
    
    func switchCategory(offset: Int) {
        saveCanvas(shouldDismiss: false)
        let newIndex = currentCategoryIndex + offset
        if newIndex >= 0 && newIndex < categories.count {
            currentCategoryIndex = newIndex
            loadTodayData()
        }
    }
    
    func addSticker(_ content: String, isTemplate: Bool = false) {
        let newSticker = StickerItem(content: content, location: CGPoint(x: 400, y: 400), isTemplate: isTemplate)
        placedStickers.append(newSticker)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            canvasView.becomeFirstResponder()
        }
    }
    
    func clearCanvas() {
        canvasView.drawing = PKDrawing()
        placedStickers.removeAll()
    }
    
    func loadTodayData() {
        clearCanvas()
        let entry = store.getEntry(for: date)
        if let pkData = entry.pkData[currentCategoryIndex],
           let drawing = try? PKDrawing(data: pkData) {
            canvasView.drawing = drawing
        }
        if entry.stickers.indices.contains(currentCategoryIndex) {
            placedStickers = entry.stickers[currentCategoryIndex]
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            canvasView.becomeFirstResponder()
        }
    }
    
    @MainActor
    func saveCanvasAction() {
        saveCanvas(shouldDismiss: true)
    }
    
    @MainActor
    func saveCanvas(shouldDismiss: Bool) {
        let drawingData = canvasView.drawing.dataRepresentation()
        
        var lightModeDrawingImage = UIImage()
        let traitCollection = UITraitCollection(userInterfaceStyle: .light)
        traitCollection.performAsCurrent {
            lightModeDrawingImage = canvasView.drawing.image(from: canvasView.bounds, scale: 1.0)
        }
        
        let exportView = ZStack {
            Color.white
            Image(uiImage: lightModeDrawingImage)
            ForEach(placedStickers) { sticker in
                Text(sticker.content)
                    .font(sticker.isTemplate ? .custom("ChalkboardSE-Regular", size: 24) : .system(size: 60))
                    .foregroundColor(.black)
                    .padding(sticker.isTemplate ? 10 : 0)
                    .background(sticker.isTemplate ? Color.white : Color.clear)
                    .overlay(sticker.isTemplate ? RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 2) : nil)
                    .position(sticker.location)
            }
        }
        .frame(width: canvasView.bounds.width, height: canvasView.bounds.height)
        .environment(\.colorScheme, .light)
        
        let renderer = ImageRenderer(content: exportView)
        renderer.proposedSize = ProposedViewSize(canvasView.bounds.size)
        
        if let uiImage = renderer.uiImage, let pngData = uiImage.pngData() {
            store.saveEntry(
                date: date,
                index: currentCategoryIndex,
                imageData: pngData,
                pkData: drawingData,
                stickers: placedStickers
            )
            if shouldDismiss {
                dismiss()
            }
        }
    }
}
