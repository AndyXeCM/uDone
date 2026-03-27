import SwiftUI
import PencilKit

// MARK: - Stickers
// 1. 加上 Codable 协议，这样 DataModel 才能保存它
// 2. 放在这里作为唯一的一份定义
struct StickerItem: Identifiable, Codable, Sendable {
    var id = UUID()
    let content: String
    var location: CGPoint
    let isTemplate: Bool
}

// MARK: - ViewMaker
struct DrawingCanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // 不需要每次更新都重置
    }
}

