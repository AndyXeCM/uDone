import SwiftUI
import PencilKit

// MARK: - Helper Module
struct DayShareData {
    let dateStr: String
    let moodImage: UIImage?
    let thingsImage: UIImage?
    let thoughtsImage: UIImage?
}

// MARK: - Data Module
struct DailyEntry: Identifiable, Codable, Sendable {
    var id = UUID()
    let date: Date
    
    var drawings: [Data?] = [nil, nil, nil]
    var pkData: [Data?] = [nil, nil, nil]
    
    var stickers: [[StickerItem]] = [[], [], []]
    
    func hasContent(at index: Int) -> Bool { drawings[index] != nil }
    var isFullyCompleted: Bool { drawings.allSatisfy { $0 != nil } }
    var isEmpty: Bool { drawings.allSatisfy { $0 == nil } }
}

// MARK: - Store Module
@MainActor
class JournalStore: ObservableObject {
    static let shared = JournalStore()
    
    @Published var entries: [String: DailyEntry] = [:]
    
    // 增加防抖标记
    private var hasLoaded = false
    
    private var fileURL: URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDirectory.appendingPathComponent("journal_data.json")
    }
    
    private init() {
        // let app starts faster
    }
    
    // raise reading speed
    func loadIfNeed() {
        guard !hasLoaded else { return }
        hasLoaded = true
        loadFromDisk()
    }
    
    func getEntry(for date: Date) -> DailyEntry {
        let key = dateKey(for: date)
        return entries[key] ?? DailyEntry(date: date)
    }
    
    func saveEntry(date: Date, index: Int, imageData: Data, pkData: Data, stickers: [StickerItem]) {
        let key = dateKey(for: date)
        if entries[key] == nil { entries[key] = DailyEntry(date: date) }
        
        entries[key]?.drawings[index] = imageData
        entries[key]?.pkData[index] = pkData
        entries[key]?.stickers[index] = stickers
        
        objectWillChange.send()
        saveToDisk()
    }
    
    private func saveToDisk() {
        let entriesCopy = self.entries
        let targetURL = self.fileURL
        
        Task.detached(priority: .background) {
            do {
                let data = try JSONEncoder().encode(entriesCopy)
                try data.write(to: targetURL)
            } catch {
                print("Save error: \(error)")
            }
        }
    }
    
    private func loadFromDisk() {
        do {
            let data = try Data(contentsOf: fileURL)
            let decodedEntries = try JSONDecoder().decode([String: DailyEntry].self, from: data)
            self.entries = decodedEntries
        } catch {
            print("For Console: New user or previous data not found.")
        }
    }
    
    func hasData(for date: Date) -> Bool {
        let key = dateKey(for: date)
        guard let entry = entries[key] else { return false }
        return !entry.isEmpty
    }
    
    func isDayComplete(for date: Date) -> Bool {
        let key = dateKey(for: date)
        guard let entry = entries[key] else { return false }
        return entry.isFullyCompleted
    }
    
    // MARK: - Streak Module
    func currentStreak() -> Int {
        var streak = 0
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        
        // 1. 如果今天有数据，就从今天开始往前算
        if hasData(for: startOfToday) {
            streak += 1
            var checkDate = calendar.date(byAdding: .day, value: -1, to: startOfToday)!
            while hasData(for: checkDate) {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            }
        } else {
            // 2. 如果今天没数据，判断昨天有没有（给用户一天的缓冲时间补卡）
            var checkDate = calendar.date(byAdding: .day, value: -1, to: startOfToday)!
            if hasData(for: checkDate) {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
                while hasData(for: checkDate) {
                    streak += 1
                    checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
                }
            }
        }
        return streak
    }
    // MARK: - Info Module
    private func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func getDataForShare(date: Date) -> DayShareData {
        let entry = getEntry(for: date)
        func dataToImage(_ data: Data?) -> UIImage? {
            guard let d = data else { return nil }
            return UIImage(data: d)
        }
        return DayShareData(
            dateStr: date.formatted(.dateTime.year().month().day()),
            moodImage: dataToImage(entry.drawings[0]),
            thingsImage: dataToImage(entry.drawings[1]),
            thoughtsImage: dataToImage(entry.drawings[2])
        )
    }
}

// MARK: - Special Day Module
struct HolidayHelper {
    static func getHolidays(year: Int) -> [(name: String, date: Date)] {
        var holidays: [(String, Date)] = []
        let calendar = Calendar.current
        func addDate(month: Int, day: Int, name: String) {
            if let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) {
                holidays.append((name, date))
            }
        }
        addDate(month: 1, day: 1, name: "New Year's Day")
        addDate(month: 2, day: 14, name: "Valentine's Day")
        addDate(month: 4, day: 1, name: "April Fool's Day")
        addDate(month: 5, day: 1, name: "Labor Day")
        addDate(month: 10, day: 31, name: "Halloween")
        addDate(month: 12, day: 25, name: "Christmas")
        if year == 2026 { addDate(month: 2, day: 17, name: "Lunar New Year") }
        return holidays.sorted { $0.1 < $1.1 }
    }
}
