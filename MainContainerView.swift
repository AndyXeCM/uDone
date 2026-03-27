import SwiftUI

// 💡 新增：定义页面的枚举，让路由逻辑更安全
enum AppTab: String {
    case today
    case archive
    case share
    case about
}

struct MainContainerView: View {
    @State private var selectedTab: AppTab = .today // 默认选中主页
    
    var body: some View {
        HStack(spacing: 0) {
            // 1. 全局侧边栏
            GlobalSidebarView(selectedTab: $selectedTab)
                .frame(width: 90)
                .background(Color(.systemBackground)) // 自适应背景
                .zIndex(20)
            
            // 2. 右侧内容区域
            ZStack {
                Group {
                    // 优化：使用 switch 配合 Enum，逻辑更加清晰
                    switch selectedTab {
                    case .today: HomeView()
                    case .archive: ArchiveView()
                    case .share: ShareView()
                    case .about: AboutView()
                    }
                }
                .id(selectedTab) // 解决 SwiftUI 切换页面时偶发动画失效的问题
                .transition(.opacity.animation(.easeInOut))
            }
            .background(Color(.systemBackground)) // 自适应背景
            .clipped()
        }
        .ignoresSafeArea()
    }
}

struct GlobalSidebarView: View {
    @Binding var selectedTab: AppTab // Use Enum
    var body: some View {
        VStack(spacing: 50) {
            Spacer()
            SidebarButton(id: .today, icon: "doc.text.image", label: "Today")
            SidebarButton(id: .archive, icon: "archivebox", label: "Archive")
            SidebarButton(id: .share, icon: "square.and.arrow.up", label: "Share")
            SidebarButton(id: .about, icon: "info.circle", label: "About")
            Spacer()
        }
        .frame(maxWidth: .infinity)
        // 侧边栏分割线颜色自适应
        .background(HStack { Spacer(); Rectangle().fill(Color.primary.opacity(0.15)).frame(width: 1) })
    }
    
    // 增加 label 参数用于 Accessibility
    func SidebarButton(id: AppTab, icon: String, label: String) -> some View {
        let isSelected = selectedTab == id
        return Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) { selectedTab = id }
        }) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: isSelected ? .medium : .light))
                .foregroundColor(isSelected ? .primary : .gray) // 选中时用 Primary
                .frame(width: 50, height: 50)
                .background(isSelected ? Color.primary.opacity(0.1) : Color.clear) // 背景色微调
                .clipShape(Circle())
        }
        // 无障碍支持
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(label))
        .accessibilityHint(Text("Switch to \(label) tab"))
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}
