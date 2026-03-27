import SwiftUI

@main
struct UDoneApp: App {
    var body: some Scene {
        WindowGroup {
            // App Loading Control
            RootCoordinatorView()
        }
    }
}

struct RootCoordinatorView: View {
    @State private var isSplashFinished = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            if isSplashFinished {
                MainContainerView()
                    .transition(.opacity.animation(.easeInOut(duration: 0.8)))
            } else {
                SplashScreen(isFinished: $isSplashFinished)
                    .transition(.opacity.animation(.easeInOut(duration: 0.8)))
            }
        }
        .animation(.default, value: isSplashFinished)
    }
}

struct SplashScreen: View {
    @Binding var isFinished: Bool
    
    // 强制给一点点不透明度，防止渲染引擎直接丢弃图层
    @State private var mainTextOpacity = 0.01
    @State private var mainTextScale = 0.9
    @State private var subTextOpacity = 0.01
    @State private var subTextOffset: CGFloat = 20
    
    // 创建一个脱离视图生命周期的强制节拍器 (0.1秒跳动一次)
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State private var ticks = 0
    
    var body: some View {
        // 提前定义纯静态字符串，杜绝一切编译器超时可能
        let welcomeMessage = "Welcome to uDone. App is loading."
        
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("uDone")
                    .font(.custom("Baskerville-BoldItalic", size: 90))
                    .foregroundColor(.primary)
                    .scaleEffect(mainTextScale)
                    .opacity(mainTextOpacity)
                    .shadow(color: Color.primary.opacity(0.3), radius: 8, x: 0, y: 0)
                
                Text("You've done a lot!")
                    .font(.custom("Baskerville-Italic", size: 26))
                    .foregroundColor(.gray)
                    .opacity(subTextOpacity)
                    .offset(y: subTextOffset)
            }
            // 新增：整体朗读欢迎语，填补启动等待时的声音空白
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(welcomeMessage)
            .accessibilityAddTraits(.isHeader)
        }
        // 无论 Playgrounds 怎么卡死，Timer 只要时间到了就一定会执行
        .onReceive(timer) { _ in
            ticks += 1
            
            // 运行到 0.2 秒：强制淡入主标题
            if ticks == 2 {
                withAnimation(.easeInOut(duration: 1.2)) {
                    mainTextOpacity = 1.0
                    mainTextScale = 1.0
                }
            }
            
            // 运行到 0.7 秒：强制淡入副标题
            if ticks == 7 {
                withAnimation(.easeOut(duration: 1.0)) {
                    subTextOpacity = 1.0
                    subTextOffset = 0
                }
            }
            
            // 运行到 2.6 秒：后台安全加载数据
            if ticks == 26 {
                JournalStore.shared.loadIfNeed()
            }
            
            // 运行到 2.8 秒：强制跳转到主界面
            if ticks == 28 {
                withAnimation(.easeInOut(duration: 0.8)) {
                    isFinished = true
                }
            }
        }
    }
}
