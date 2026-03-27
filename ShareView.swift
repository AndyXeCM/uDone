import SwiftUI
import PhotosUI

enum ShareStyle: String, CaseIterable, Identifiable {
    case overlapping = "Overlapping"
    case folded = "Folded"
    case straight = "Straight"
    var id: String { self.rawValue }
}

struct ShareImageItem: Identifiable {
    let id = UUID()
    let image: UIImage
}

extension Date {
    func formattedstr() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}

struct ShareView: View {
    @State private var selectedStyle: ShareStyle = .folded
    @State private var selectedDate: Date = Date()
    @State private var showCalendarSheet: Bool = false
    @State private var currentSubtitle: String = ""
    
    // MARK: - Wordle
    let subtitles = [
        "Share your joy.", "Express to the world.", "Spread the creativity.",
        "Your days, shared.", "Inspire someone today."
    ]
    
    @State private var shareItem: ShareImageItem? = nil
    
    @State private var showSaveAlert: Bool = false
    @State private var saveAlertMessage: String = ""
    @State private var saveAlertTitle: String = ""
    
    let cardHeight: CGFloat = 450
    
    var body: some View {
        let headerA11y = "Share. \(currentSubtitle)"
        
        VStack(alignment: .leading, spacing: 0) {
            
            // --- 统一对齐的 Header ---
            HStack(alignment: .firstTextBaseline) {
                Text("Share")
                    .font(.custom("Baskerville-SemiBoldItalic", size: 80))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(currentSubtitle)
                    .font(.custom("Baskerville", size: 28))
                    .italic()
                    .foregroundColor(.gray)
            }
            .padding(.top, 50)
            .padding(.horizontal, 50)
            .padding(.bottom, 20)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(headerA11y)
            .accessibilityAddTraits(.isHeader)
            .onAppear {
                if currentSubtitle.isEmpty { currentSubtitle = subtitles.randomElement() ?? "" }
            }
            
            // 💡 新增上部的弹性空间，将卡片往下压
            Spacer()
            
            // --- 中间居中的三个卡片 ---
            HStack(alignment: .top, spacing: 30) {
                step1StyleView
                step2DateView
                step3ExportView
            }
            .padding(.horizontal, 50)
            
            // 💡 保留下部的弹性空间，与上面的 Spacer 互相挤压，实现完美居中
            Spacer()
        }
        .sheet(isPresented: $showCalendarSheet) {
            ShareCalendarPickerView(selectedDate: $selectedDate)
        }
        .popover(item: $shareItem) { item in
            ShareSheetView(activityItems: [item.image])
                .frame(width: 400, height: 500)
                .presentationCompactAdaptation(.popover)
        }
        .alert(isPresented: $showSaveAlert) {
            Alert(title: Text(saveAlertTitle), message: Text(saveAlertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    // MARK: - Modules
    
    private var step1StyleView: some View {
        VStack(alignment: .leading, spacing: 20) {
            ShareStepHeader(number: 1, title: "Style")
            VStack(spacing: 15) {
                StyleOptionButton(style: .overlapping, icon: "square.stack.3d.down.right", selected: selectedStyle == .overlapping) { selectedStyle = .overlapping }
                StyleOptionButton(style: .folded, icon: "book.closed", selected: selectedStyle == .folded) { selectedStyle = .folded }
                StyleOptionButton(style: .straight, icon: "tablecells", selected: selectedStyle == .straight) { selectedStyle = .straight }
            }
            Spacer()
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight)
        .background(RoundedRectangle(cornerRadius: 20).stroke(Color.primary.opacity(0.2), lineWidth: 1))
    }
    
    private var step2DateView: some View {
        VStack(alignment: .leading, spacing: 20) {
            ShareStepHeader(number: 2, title: "Date")
            VStack(spacing: 20) {
                DateOptionButton(title: "Today", date: Date(), isSelected: Calendar.current.isDateInToday(selectedDate)) {
                    selectedDate = Date()
                }
                
                DateOptionButton(title: "History", date: selectedDate, isSelected: !Calendar.current.isDateInToday(selectedDate)) {
                    showCalendarSheet = true
                }
                
                Divider().background(Color.gray)
                
                Text("Selected: \(selectedDate.formattedstr())")
                    .font(.custom("ChalkboardSE-Regular", size: 16))
                    .foregroundColor(.gray)
                    .accessibilityLabel("Currently selected date is \(selectedDate.formattedstr())")
            }
            Spacer()
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight)
        .background(RoundedRectangle(cornerRadius: 20).stroke(Color.primary.opacity(0.2), lineWidth: 1))
    }
    
    private var step3ExportView: some View {
        VStack(alignment: .leading, spacing: 20) {
            ShareStepHeader(number: 3, title: "Export")
            Spacer()
            VStack(spacing: 15) {
                ShareActionButton(title: "Share Sheet", icon: "square.and.arrow.up") {
                    generateAndShare()
                }
                ShareActionButton(title: "Save to Photos", icon: "arrow.down.to.line") {
                    generateAndSaveToPhotos()
                }
            }
            
            Text("If the app didn't response, please check Photo Library permissions in Settings.")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 10)
            
            Spacer()
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight)
        .background(RoundedRectangle(cornerRadius: 20).stroke(Color.primary.opacity(0.2), lineWidth: 1))
    }
    
    // MARK: - Logic
    
    @MainActor func generateAndShare() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if let img = self.generateImageFromData() {
                self.shareItem = ShareImageItem(image: img)
            }
        }
    }
    
    @MainActor func generateAndSaveToPhotos() {
        if let img = generateImageFromData() {
            let imageSaver = ImageSaver()
            
            imageSaver.successHandler = {
                self.saveAlertTitle = "Saved!"
                self.saveAlertMessage = "The card has been saved to your Photos."
                self.showSaveAlert = true
            }
            imageSaver.errorHandler = { error in
                self.saveAlertTitle = "Error"
                self.saveAlertMessage = error.localizedDescription
                self.showSaveAlert = true
            }
            imageSaver.writeToPhotoAlbum(image: img)
        }
    }
    
    @MainActor func generateImageFromData() -> UIImage? {
        let data = JournalStore.shared.getDataForShare(date: selectedDate)
        let renderer = ImageRenderer(content: PrintableTemplateView(style: selectedStyle, data: data).frame(width: 1200, height: 900))
        renderer.scale = 3.0
        return renderer.uiImage
    }
}

class ImageSaver: NSObject {
    var successHandler: (() -> Void)?
    var errorHandler: ((Error) -> Void)?
    
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            errorHandler?(error)
        } else {
            successHandler?()
        }
    }
}

struct ShareStepHeader: View {
    let number: Int
    let title: String
    var body: some View {
        HStack {
            Text("\(number)").font(.headline).foregroundColor(Color(.systemBackground))
                .frame(width: 25, height: 25).background(Circle().fill(Color.primary))
                .accessibilityHidden(true)
            Text(title).font(.custom("ChalkboardSE-Bold", size: 22)).foregroundColor(.primary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Step \(number): \(title)")
        .accessibilityAddTraits(.isHeader)
    }
}

struct StyleOptionButton: View {
    let style: ShareStyle; let icon: String; let selected: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon).font(.title2)
                Text(style.rawValue).font(.custom("ChalkboardSE-Regular", size: 18))
                Spacer()
                if selected { Image(systemName: "checkmark.circle.fill") }
            }
            .padding().foregroundColor(selected ? Color(.systemBackground) : .primary)
            .background(RoundedRectangle(cornerRadius: 12).fill(selected ? Color.primary : Color.primary.opacity(0.1)))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Style: \(style.rawValue)")
        .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
    }
}

struct DateOptionButton: View {
    let title: String; let date: Date; let isSelected: Bool; let action: () -> Void
    var body: some View {
        let a11yTitle = title == "Today" ? "Today" : "History Date"
        let a11yVal = date.formatted(.dateTime.month().day())
        
        Button(action: action) {
            VStack(alignment: .leading) {
                Text(title).font(.custom("ChalkboardSE-Bold", size: 18))
                Text(date.formatted(.dateTime.month().day())).font(.caption)
            }
            .padding().frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(isSelected ? Color(.systemBackground) : .primary)
            .background(RoundedRectangle(cornerRadius: 12).fill(isSelected ? Color.primary : Color.primary.opacity(0.1)))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(a11yTitle)
        .accessibilityValue(a11yVal)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

struct ShareActionButton: View {
    let title: String; let icon: String; let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon).font(.system(size: 30))
                Text(title).font(.custom("ChalkboardSE-Bold", size: 18))
            }
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(RoundedRectangle(cornerRadius: 16).stroke(Color.primary, lineWidth: 2))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
    }
}

struct ShareCalendarPickerView: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack {
                Text("Select Date").font(.title).foregroundColor(.primary).padding()
                    .accessibilityAddTraits(.isHeader)
                
                DatePicker("", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                
                Button("Confirm") { dismiss() }
                    .font(.headline).padding()
                    .background(Color.primary).cornerRadius(10).foregroundColor(Color(.systemBackground))
            }
        }
    }
}

struct ShareSheetView: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
