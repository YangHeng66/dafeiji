import Foundation

// 记录类型枚举
enum RecordType: String, Codable, CaseIterable, Identifiable {
    case sex = "性爱"
    case masturbation = "自慰"
    
    var id: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .sex:
            return "heart.fill"
        case .masturbation:
            return "hand.raised.fill"
        }
    }
    
    var color: String {
        switch self {
        case .sex:
            return "blue"
        case .masturbation:
            return "purple"
        }
    }
}

// 地点标签
struct Tag: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    
    static var defaultTags: [Tag] = [
        Tag(name: "卧室"),
        Tag(name: "浴室"),
        Tag(name: "厨房"),
        Tag(name: "沙发"),
        Tag(name: "户外"),
        Tag(name: "酒店")
    ]
}

// 记录模型
struct Record: Identifiable, Codable {
    var id = UUID()
    var type: RecordType
    var duration: Int // 以秒为单位
    var date: Date
    var rating: Int // 1-5星评分
    var mood: Int // 1-5心情评分
    var tags: [Tag]
    var notes: String?
    
    // 格式化的持续时间
    var formattedDuration: String {
        let minutes = duration / 60
        let seconds = duration % 60
        return "\(minutes)分\(seconds > 0 ? "\(seconds)秒" : "")"
    }
    
    // 格式化的日期
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}

// 用户设置模型
struct UserSettings: Codable {
    var appLock: Bool = true
    var biometricAuth: Bool = true
    var dataEncryption: Bool = true
    var pushNotifications: Bool = false
    var quietHours: Bool = true
    var quietHoursStart: Date = Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date()) ?? Date()
    var quietHoursEnd: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    var darkMode: String = "system" // system, light, dark
}

// 数据存储管理
class DataStore: ObservableObject {
    @Published var records: [Record] = []
    @Published var settings: UserSettings = UserSettings()
    
    private let recordsKey = "records"
    private let settingsKey = "userSettings"
    
    init() {
        loadRecords()
        loadSettings()
    }
    
    // 加载记录
    private func loadRecords() {
        if let data = UserDefaults.standard.data(forKey: recordsKey) {
            if let decoded = try? JSONDecoder().decode([Record].self, from: data) {
                self.records = decoded
                return
            }
        }
        
        // 默认记录
        self.records = []
    }
    
    // 加载设置
    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: settingsKey) {
            if let decoded = try? JSONDecoder().decode(UserSettings.self, from: data) {
                self.settings = decoded
                return
            }
        }
        
        // 默认设置
        self.settings = UserSettings()
    }
    
    // 保存记录
    func saveRecords() {
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: recordsKey)
        }
    }
    
    // 保存设置
    func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
    }
    
    // 添加新记录
    func addRecord(_ record: Record) {
        records.append(record)
        saveRecords()
    }
    
    // 更新记录
    func updateRecord(_ record: Record) {
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records[index] = record
            saveRecords()
        }
    }
    
    // 删除记录
    func deleteRecord(_ record: Record) {
        records.removeAll { $0.id == record.id }
        saveRecords()
    }
    
    // 按月份分组的记录
    func recordsByMonth() -> [String: [Record]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        formatter.locale = Locale(identifier: "zh_CN")
        
        return Dictionary(grouping: records.sorted(by: { $0.date > $1.date })) { record in
            formatter.string(from: record.date)
        }
    }
    
    // 本月记录
    var recordsThisMonth: [Record] {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        
        return records.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
    }
    
    // 本月平均时长（分钟）
    var averageDurationThisMonth: Double {
        let thisMonthRecords = recordsThisMonth
        guard !thisMonthRecords.isEmpty else { return 0 }
        
        let totalSeconds = thisMonthRecords.reduce(0) { $0 + $1.duration }
        return Double(totalSeconds) / 60.0 / Double(thisMonthRecords.count)
    }
    
    // 本月性爱次数
    var sexCountThisMonth: Int {
        return recordsThisMonth.filter { $0.type == .sex }.count
    }
    
    // 本月自慰次数
    var masturbationCountThisMonth: Int {
        return recordsThisMonth.filter { $0.type == .masturbation }.count
    }
} 
