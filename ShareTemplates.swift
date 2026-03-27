import SwiftUI

struct PrintableTemplateView: View {
    let style: ShareStyle
    let data: DayShareData
    
    var body: some View {
        ZStack {
            Color.white
            
            VStack {
                // 顶部 Header
                HStack {
                    Text("uDone Entry").font(.custom("Baskerville-Bold", size: 32))
                    Spacer()
                    Text(data.dateStr).font(.custom("Baskerville", size: 24))
                }
                .foregroundColor(.black).padding(40)
                
                Spacer()
                
                // 中间卡片区域
                switch style {
                case .overlapping: TemplateOverlapping(data: data)
                case .folded: TemplateFolded(data: data)
                case .straight: TemplateStraight(data: data)
                }
                
                Spacer()
            }
        }
        .environment(\.colorScheme, .light)
    }
}

// MARK: - 样式 1: Overlapping (重叠)
struct TemplateOverlapping: View {
    let data: DayShareData
    var body: some View {
        ZStack {
            // 因为卡片变大了，稍微拉大一点偏移距离，让图片露出来更多
            TemplateCard(title: "Thoughts", image: data.thoughtsImage)
                .rotationEffect(.degrees(6))
                .offset(x: 240, y: 80) // 调整了坐标
            
            TemplateCard(title: "Things", image: data.thingsImage)
                .offset(x: 0, y: -20)  // 居中稍微上提
            
            TemplateCard(title: "Mood", image: data.moodImage)
                .rotationEffect(.degrees(-6))
                .offset(x: -240, y: 80) // 调整了坐标
        }
        .padding(20)
    }
}

// MARK: - 样式 2: Folded (折叠)
struct TemplateFolded: View {
    let data: DayShareData
    var body: some View {
        HStack(spacing: 0) {
            TemplateCard(title: "Mood", image: data.moodImage, isFolded: true)
                .rotation3DEffect(.degrees(15), axis: (x: 0, y: 1, z: 0), anchor: .trailing)
                .zIndex(1)
            
            TemplateCard(title: "Things", image: data.thingsImage, isFolded: true)
                .zIndex(0)
            
            TemplateCard(title: "Thoughts", image: data.thoughtsImage, isFolded: true)
                .rotation3DEffect(.degrees(-15), axis: (x: 0, y: 1, z: 0), anchor: .leading)
                .zIndex(1)
        }
        .padding(20)
    }
}

// MARK: - 样式 3: Straight (平铺)
struct TemplateStraight: View {
    let data: DayShareData
    var body: some View {
        // 减少间距，因为卡片变宽了
        HStack(spacing: 25) {
            TemplateCard(title: "Mood", image: data.moodImage)
            TemplateCard(title: "Things", image: data.thingsImage)
            TemplateCard(title: "Thoughts", image: data.thoughtsImage)
        }
        .padding(20)
    }
}

// MARK: - 核心卡片组件 (正方形 + 标题在外部)
struct TemplateCard: View {
    let title: String
    let image: UIImage?
    var isFolded: Bool = false
    
    // 定义卡片尺寸：正方形，大一点
    let cardSize: CGFloat = 340
    
    var body: some View {
        VStack(spacing: 15) { // 卡片和标题之间的间距
            
            // 1. 图片区域 (正方形盒子)
            ZStack {
                // 边框背景
                if isFolded {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black, lineWidth: 3)
                        .background(Color.white)
                } else {
                    RoundedRectangle(cornerRadius: 24) // 圆角稍微大一点，更好看
                        .stroke(Color.black, lineWidth: 4)
                        .background(Color.white)
                }
                
                // 图片内容
                if let uiImage = image {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit) // 保持比例，完全展示
                        .padding(12) // 给边框留一点白边
                } else {
                    // 没有图片时的占位符
                    VStack(spacing: 10) {
                        Image(systemName: "photo")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.3))
                        Text("No Content")
                            .font(.custom("ChalkboardSE-Regular", size: 18))
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(width: cardSize, height: cardSize) // 强制正方形
            
            // 2. 标题区域 (在卡片外部)
            Text(title)
                .font(.custom("ChalkboardSE-Bold", size: 28)) // 字体加大
                .foregroundColor(.black)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                // 可选：给标题加个淡淡的胶囊背景，看起来更像标签
                // .background(Capsule().fill(Color.gray.opacity(0.1)))
        }
        // 这里的 frame 是限制整个组件(含标题)的大小，防止布局乱跑
        .frame(width: cardSize)
    }
}
