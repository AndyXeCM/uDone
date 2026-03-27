import SwiftUI

struct AboutView: View {
    @State private var appear = false
    @State private var showNotes = false // 仅增加弹窗状态

    var body: some View {
        ZStack {
            
            // 背景: 使用系统背景色 + 渐变
            LinearGradient(
                colors: [Color(.systemBackground), Color(.systemBackground).opacity(0.92)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // 径向渐变 (光晕)
            // 使用 UIScreen 取代 geo 来计算半径，彻底切断和布局引擎的依赖
            RadialGradient(
                colors: [Color.primary.opacity(0.06), Color.clear],
                center: .center,
                startRadius: 0,
                endRadius: max(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * 0.7
            )
            .blendMode(.normal)
            .ignoresSafeArea()

            //content
            GeometryReader { geo in
                ZStack {
                    let centerX = geo.size.width / 2
                    let centerY = geo.size.height / 2
                    
                    // === 四周内容块中心点 ===
                    let tlPos = CGPoint(x: geo.size.width * 0.24, y: geo.size.height * 0.23)
                    let trPos = CGPoint(x: geo.size.width * 0.76, y: geo.size.height * 0.22)
                    let blPos = CGPoint(x: geo.size.width * 0.22, y: geo.size.height * 0.76)
                    let brPos = CGPoint(x: geo.size.width * 0.78, y: geo.size.height * 0.78)
                    let centerPos = CGPoint(x: centerX, y: centerY)

                    let targetDistX: CGFloat = 115
                    let targetDistY_Top: CGFloat = 45
                    let targetDistY_Bottom: CGFloat = 65

                    let centerTargetTL = CGPoint(x: centerX - targetDistX, y: centerY - targetDistY_Top)
                    let centerTargetTR = CGPoint(x: centerX + targetDistX, y: centerY - targetDistY_Top + 5)
                    let centerTargetBL = CGPoint(x: centerX - targetDistX + 10, y: centerY + targetDistY_Bottom)
                    let centerTargetBR = CGPoint(x: centerX + targetDistX - 10, y: centerY + targetDistY_Bottom + 5)

                    // 中间文字层
                    VStack(spacing: -8) {
                        Text("about")
                            .font(.custom("ChalkboardSE-Regular", size: scaled(geo, base: 26)))
                            .foregroundColor(.primary.opacity(0.7))
                            .tracking(0.5)
                            .offset(y: -2)
                        Text("uDone")
                            .font(.custom("ChalkboardSE-Bold", size: scaled(geo, base: 110)))
                            .foregroundColor(.primary)
                            .shadow(color: Color.primary.opacity(0.2), radius: 3, x: 0, y: 2)
                    }
                    // 👇 极简无障碍：纯静态文本，绝对不卡死编译器
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("About uDone. Use Apple Pencil to draw your daily mood, things, and thoughts. You can add your experiences in the home page, review your memories in the archive page, and share your day in the share page.")
                    .accessibilityAddTraits(.isHeader)
                    // 👆
                    .position(centerPos)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 10)
                    .animation(.easeOut(duration: 0.6).delay(0.05), value: appear)
                    .zIndex(10)

                    // 左上内容
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top, spacing: 14) {
                            SketchCardStack()
                                .frame(width: 70, height: 70)
                                .rotationEffect(.degrees(-4))
                                .offset(x: -2, y: 4)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("fill your day")
                                    .font(.custom("ChalkboardSE-Bold", size: scaled(geo, base: 30)))
                                    .foregroundStyle(.primary)
                                Text("via Apple pencil")
                                    .font(.custom("ChalkboardSE-Regular", size: scaled(geo, base: 18)))
                                    .foregroundStyle(.primary.opacity(0.7))
                            }
                        }
                    }
                    .position(tlPos)
                    .opacity(appear ? 1 : 0)
                    .offset(x: appear ? 0 : -10, y: appear ? 0 : -6)
                    .animation(.spring(response: 0.6, dampingFraction: 0.9).delay(0.12), value: appear)

                    // 右上内容
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Watch your Archive")
                            .font(.custom("ChalkboardSE-Bold", size: scaled(geo, base: 28)))
                            .foregroundStyle(.primary)
                        HStack(spacing: 12) {
                            Image(systemName: "list.bullet.rectangle.portrait")
                                .font(.system(size: scaled(geo, base: 36), weight: .regular))
                                .foregroundStyle(.primary)
                                .offset(y: 1)
                            Text("And gain memories")
                                .font(.custom("ChalkboardSE-Regular", size: scaled(geo, base: 18)))
                                .foregroundStyle(.primary.opacity(0.75))
                        }
                    }
                    .position(trPos)
                    .opacity(appear ? 1 : 0)
                    .offset(x: appear ? 0 : 10, y: appear ? 0 : -8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.9).delay(0.18), value: appear)

                    // 左下内容
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.up.right.square")
                                .font(.system(size: scaled(geo, base: 22)))
                            Text("share your day\nto your friends!")
                                .font(.custom("ChalkboardSE-Bold", size: scaled(geo, base: 24)))
                        }
                        .foregroundStyle(.primary)
                        SketchMiniShare()
                            .scaleEffect(0.95)
                            .rotationEffect(.degrees(-2))
                            .shadow(color: Color.primary.opacity(0.3), radius: 3, x: 0, y: 2)
                    }
                    .position(blPos)
                    .opacity(appear ? 1 : 0)
                    .offset(x: appear ? 0 : -10, y: appear ? 0 : 8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.9).delay(0.24), value: appear)

                    // 右下内容
                    VStack(alignment: .trailing, spacing: 6) {
                        Text("An app made")
                            .font(.custom("ChalkboardSE-Regular", size: scaled(geo, base: 22)))
                            .foregroundStyle(.primary.opacity(0.85))
                        HStack(spacing: 6) {
                            Text("with")
                            Image(systemName: "heart.fill").foregroundColor(.red)
                            Text("by Aoody.")
                        }
                        .font(.custom("ChalkboardSE-Bold", size: scaled(geo, base: 30)))
                        .foregroundStyle(.primary)
                    }
                    .position(brPos)
                    .opacity(appear ? 1 : 0)
                    .offset(x: appear ? 0 : 10, y: appear ? 0 : 10)
                    .animation(.spring(response: 0.6, dampingFraction: 0.9).delay(0.3), value: appear)

                    // === 一体化箭头层 ===
                    Group {
                        OnePieceArrow(
                            start: CGPoint(x: tlPos.x + 50, y: tlPos.y + 50),
                            end: centerTargetTL,
                            curveAmount: 25
                        )
                        .stroke(Color.primary.opacity(0.8), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

                        OnePieceArrow(
                            start: CGPoint(x: trPos.x - 50, y: trPos.y + 40),
                            end: centerTargetTR,
                            curveAmount: -25
                        )
                        .stroke(Color.primary.opacity(0.8), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

                        OnePieceArrow(
                            start: CGPoint(x: blPos.x + 40, y: blPos.y - 50),
                            end: centerTargetBL,
                            curveAmount: -30
                        )
                        .stroke(Color.primary.opacity(0.8), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

                        OnePieceArrow(
                            start: CGPoint(x: brPos.x - 40, y: brPos.y - 40),
                            end: centerTargetBR,
                            curveAmount: 30
                        )
                        .stroke(Color.primary.opacity(0.8), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                    }
                    .opacity(appear ? 1 : 0)
                    .animation(.easeOut(duration: 0.8).delay(0.4), value: appear)
                    
                    // ✨ 按照你的要求：在页面最底下加入按钮，完全不影响上面的任何布局
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showNotes = true
                        }
                    }) {
                        Text("view app maker's notes")
                            .font(.custom("ChalkboardSE-Regular", size: 16))
                            .underline()
                            .foregroundColor(.primary.opacity(0.6))
                    }
                    .position(x: centerX, y: geo.size.height - 40)
                    .opacity(appear ? 1 : 0)
                    .animation(.easeOut(duration: 0.8).delay(0.5), value: appear)
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .onAppear { appear = true }
            }
            
            // ✨ 你要求的弹窗层
            if showNotes {
                DeveloperNotesPopup(showNotes: $showNotes)
            }
        }
    }

    private func scaled(_ geo: GeometryProxy, base: CGFloat) -> CGFloat {
        // 你的原版逻辑保留
        let minSide = round(min(geo.size.width, geo.size.height) / 10) * 10
        let scale = min(max(minSide / 1024, 0.7), 1.3)
        return base * scale
    }
}

// MARK: - Notes Module
struct DeveloperNotesPopup: View {
    @Binding var showNotes: Bool
    
    var body: some View {
        ZStack {
            // 点击空白处关闭
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { showNotes = false }
                }
            
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { showNotes = false }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .padding([.top, .trailing], 20)
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("App Maker’s Notes")
                            .font(.custom("ChalkboardSE-Bold", size: 26))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 8)
                        
                        Group {
                            Text("When I entered ninth grade, my homeroom teacher told me something that I remembered for a long time —— “Try to record every single day of your life; not only what you learned, but also your experiences and thoughts. If you can keep doing this for the next year, you’ll gain memories and insights that will stay with you for a lifetime.”")
                            
                            Text("I took that advice by heart. I began documenting my days using a notebook called TodayWellSpent, carefully writing down what I did, what I felt, and what I thought.")
                            
                            Text("However, the notebook was quite expensive and only had a slot of filling up a month. Because of this, I started looking for alternatives. Many digital tools are really convenient and cheap solutions, but most of them were limited to plain text, and cannot leave some place for me to stay creative on recording......")
                            
                            Text("That’s when I began wondering:")
                                .padding(.top, 4)
                            
                            Text("What if we could use Apple Pencil to freely capture our daily experiences, not just in words, but in drawings, sketches, and handwritten thoughts?")
                            
                            Text("Wouldn’t that be more creative, more flexible, and absolutely, more affordable, in the long run?")
                            
                            Text("With this idea in mind, and inspired by the chance that the 2026 Apple Swift Student Challenge had provided, I created uDone — an app that allows you to freely draw your daily experiences on a canvas using Apple Pencil.")
                                .padding(.top, 4)
                            
                            Text("It is built on a simple belief:")
                            
                            Text("Your memories deserve more than just typed text. They deserve space, creativity, and freedom.")
                                .font(.custom("ChalkboardSE-Bold", size: 16))
                            
                            Text("I hope you will like this app, as well as this nice idea.")
                        }
                        .font(.custom("ChalkboardSE-Regular", size: 16))
                        .lineSpacing(4)
                        
                        Group {
                            Text("p.s. Special thanks to my friend Mark Young for deeply testing the app and providing invaluable feedback and suggestions for improvement.")
                            
                            Text("Also, deeply grateful to my family for supporting me while I learned Swift and worked to bring this project to life.")
                            
                            Text("— Aoody\nJanuary 21, 2026")
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.top, 8)
                        }
                        .font(.custom("ChalkboardSE-Regular", size: 14))
                        .foregroundColor(.secondary)
                        .padding(.top, 12)
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 30)
                }
            }
            .frame(maxWidth: 550, maxHeight: 650)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
            )
            .padding(24)
        }
        .zIndex(100)
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
}

// MARK: - Visual

struct OnePieceArrow: Shape {
    var start: CGPoint
    var end: CGPoint
    var curveAmount: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: start)
        let midX = (start.x + end.x) / 2
        let midY = (start.y + end.y) / 2
        let dx = end.x - start.x
        let dy = end.y - start.y
        let perpX = -dy
        let perpY = dx
        let length = sqrt(perpX*perpX + perpY*perpY)
        let safeLength = length > 0 ? length : 1
        let cp = CGPoint(
            x: midX + (perpX / safeLength) * curveAmount,
            y: midY + (perpY / safeLength) * curveAmount
        )
        path.addQuadCurve(to: end, control: cp)
        let tangentX = end.x - cp.x
        let tangentY = end.y - cp.y
        let angle = atan2(tangentY, tangentX)
        let arrowLen: CGFloat = 18
        let arrowWingAngle: CGFloat = .pi / 7
        let wing1 = CGPoint(
            x: end.x - arrowLen * cos(angle - arrowWingAngle),
            y: end.y - arrowLen * sin(angle - arrowWingAngle)
        )
        let wing2 = CGPoint(
            x: end.x - arrowLen * cos(angle + arrowWingAngle),
            y: end.y - arrowLen * sin(angle + arrowWingAngle)
        )
        path.addLine(to: wing1)
        path.move(to: end)
        path.addLine(to: wing2)
        return path
    }
}

struct SketchCardStack: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(0..<3, id: \.self) { i in
                RoundedRectangle(cornerRadius: 7)
                    .stroke(Color.primary, lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 7).fill(Color.primary.opacity(0.04))
                    )
                    .frame(width: 46, height: 62)
                    .rotationEffect(.degrees(Double(i) * -6 + (i == 1 ? -2 : 0)))
                    .offset(x: CGFloat(i) * 10, y: CGFloat(i) * -8)
                    .shadow(color: Color.primary.opacity(0.35), radius: 2, x: 0, y: 1)
            }
        }
        .compositingGroup()
    }
}

struct SketchMiniShare: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.primary, lineWidth: 2)
                .background(
                    RoundedRectangle(cornerRadius: 10).fill(Color.primary.opacity(0.04))
                )
                .frame(width: 150, height: 105)
            VStack(alignment: .leading, spacing: 6) {
                Text("uDone Entry")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.primary.opacity(0.9))
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.primary.opacity(0.22))
                            .frame(width: 42, height: 56)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2)
                                    .stroke(Color.primary.opacity(0.35), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(10)
        }
    }
}
