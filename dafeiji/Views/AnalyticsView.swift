import SwiftUI
import Charts

struct AnalyticsView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var selectedDateRange: DateRange = .month
    @State private var selectedChart: ChartType = .frequency
    
    enum DateRange: String, CaseIterable, Identifiable {
        case week = "本周"
        case month = "本月"
        case year = "今年"
        case all = "全部"
        
        var id: String { self.rawValue }
    }
    
    enum ChartType: String, CaseIterable, Identifiable {
        case frequency = "频率"
        case duration = "时长"
        case rating = "满意度"
        case tags = "标签"
        
        var id: String { self.rawValue }
    }
    
    var filteredRecords: [Record] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedDateRange {
        case .week:
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            return dataStore.records.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .weekOfYear) }
        case .month:
            return dataStore.recordsThisMonth
        case .year:
            let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
            return dataStore.records.filter { calendar.isDate($0.date, equalTo: startOfYear, toGranularity: .year) }
        case .all:
            return dataStore.records
        }
    }
    
    var sexRecords: [Record] {
        return filteredRecords.filter { $0.type == .sex }
    }
    
    var masturbationRecords: [Record] {
        return filteredRecords.filter { $0.type == .masturbation }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 日期范围选择器
                    dateRangeSelector
                    
                    // 数据概览卡片
                    overviewCards
                    
                    // 图表类型选择器
                    chartTypeSelector
                    
                    // 当前选择的图表
                    selectedChartView
                    
                    // 数据分析摘要
                    dataSummary
                }
                .padding()
            }
            .navigationTitle("数据分析")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
    
    // 日期范围选择器
    private var dateRangeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(DateRange.allCases) { range in
                    Button(action: {
                        selectedDateRange = range
                    }) {
                        Text(range.rawValue)
                            .font(.headline)
                            .foregroundColor(selectedDateRange == range ? .white : .primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedDateRange == range ? Color.blue : Color.gray.opacity(0.1))
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    // 数据概览卡片
    private var overviewCards: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // 总次数卡片
                StatsCard(
                    title: "总次数",
                    value: "\(filteredRecords.count)",
                    subtitle: nil,
                    iconName: "number.circle.fill",
                    iconBackgroundColor: Color.indigo.opacity(0.1),
                    iconColor: .indigo
                )
                .frame(maxWidth: .infinity)
                
                // 平均持续时间卡片
                StatsCard(
                    title: "平均时长",
                    value: averageDurationString,
                    subtitle: nil,
                    iconName: "clock.fill",
                    iconBackgroundColor: Color.green.opacity(0.1),
                    iconColor: .green
                )
                .frame(maxWidth: .infinity)
            }
            
            HStack(spacing: 16) {
                // 性爱次数卡片
                StatsCard(
                    title: "性爱次数",
                    value: "\(sexRecords.count)",
                    subtitle: "\(Int((Double(sexRecords.count) / Double(max(1, filteredRecords.count))) * 100))%",
                    iconName: "heart.fill",
                    iconBackgroundColor: Color.blue.opacity(0.1),
                    iconColor: .blue
                )
                .frame(maxWidth: .infinity)
                
                // 自慰次数卡片
                StatsCard(
                    title: "自慰次数",
                    value: "\(masturbationRecords.count)",
                    subtitle: "\(Int((Double(masturbationRecords.count) / Double(max(1, filteredRecords.count))) * 100))%",
                    iconName: "hand.raised.fill",
                    iconBackgroundColor: Color.purple.opacity(0.1),
                    iconColor: .purple
                )
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    // 图表类型选择器
    private var chartTypeSelector: some View {
        HStack(spacing: 0) {
            ForEach(ChartType.allCases) { type in
                Button(action: {
                    selectedChart = type
                }) {
                    Text(type.rawValue)
                        .font(.subheadline)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(selectedChart == type ? .blue : .secondary)
                        .overlay(
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(selectedChart == type ? .blue : .clear),
                            alignment: .bottom
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.top, 8)
    }
    
    // 当前选择的图表视图
    private var selectedChartView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(chartTitle)
                .font(.headline)
            
            switch selectedChart {
            case .frequency:
                frequencyChartView
            case .duration:
                durationChartView
            case .rating:
                ratingChartView
            case .tags:
                tagChartView
            }
        }
        .padding()
        .background(Color.systemBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // 图表标题
    private var chartTitle: String {
        switch selectedChart {
        case .frequency:
            return "活动频率"
        case .duration:
            return "持续时间分析"
        case .rating:
            return "满意度统计"
        case .tags:
            return "常用标签分布"
        }
    }
    
    // 频率图表
    private var frequencyChartView: some View {
        VStack {
            if filteredRecords.isEmpty {
                ChartPlaceholder(message: "没有足够的数据生成图表")
            } else {
                Chart {
                    ForEach(frequencyData.sexData.indices, id: \.self) { index in
                        BarMark(
                            x: .value("日期", frequencyData.labels[index]),
                            y: .value("次数", frequencyData.sexData[index])
                        )
                        .foregroundStyle(Color.blue)
                        .annotation(position: .top) {
                            if frequencyData.sexData[index] > 0 {
                                Text("\(frequencyData.sexData[index])")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    ForEach(frequencyData.masturbationData.indices, id: \.self) { index in
                        BarMark(
                            x: .value("日期", frequencyData.labels[index]),
                            y: .value("次数", frequencyData.masturbationData[index])
                        )
                        .foregroundStyle(Color.purple)
                        .annotation(position: .top) {
                            if frequencyData.masturbationData[index] > 0 {
                                Text("\(frequencyData.masturbationData[index])")
                                    .font(.caption2)
                                    .foregroundColor(.purple)
                            }
                        }
                    }
                }
                .chartForegroundStyleScale([
                    "性爱": Color.blue,
                    "自慰": Color.purple
                ])
                .frame(height: 250)
                
                // 图例
                HStack(spacing: 20) {
                    HStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.blue)
                            .frame(width: 16, height: 16)
                        Text("性爱")
                            .font(.caption)
                    }
                    
                    HStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.purple)
                            .frame(width: 16, height: 16)
                        Text("自慰")
                            .font(.caption)
                    }
                }
                .padding(.top, 4)
            }
        }
    }
    
    // 时长图表
    private var durationChartView: some View {
        VStack {
            if filteredRecords.isEmpty {
                ChartPlaceholder(message: "没有足够的数据生成图表")
            } else {
                Chart {
                    ForEach(durationBuckets.indices, id: \.self) { index in
                        BarMark(
                            x: .value("时长范围", durationLabels[index]),
                            y: .value("次数", durationBuckets[index])
                        )
                        .foregroundStyle(
                            .linearGradient(
                                colors: [.blue.opacity(0.6), .purple.opacity(0.6)],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .annotation(position: .top) {
                            if durationBuckets[index] > 0 {
                                Text("\(durationBuckets[index])")
                                    .font(.caption2)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                .frame(height: 250)
                
                // 平均时长和最长时长
                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("平均时长")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(averageDurationString)
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("最长时长")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(longestDurationString)
                            .font(.headline)
                    }
                }
                .padding(.top, 8)
            }
        }
    }
    
    // 满意度图表
    private var ratingChartView: some View {
        VStack {
            if filteredRecords.isEmpty {
                ChartPlaceholder(message: "没有足够的数据生成图表")
            } else {
                Chart {
                    ForEach(1...5, id: \.self) { rating in
                        let count = ratingCounts[rating - 1]
                        BarMark(
                            x: .value("评分", "\(rating)星"),
                            y: .value("次数", count)
                        )
                        .foregroundStyle(
                            .linearGradient(
                                colors: [.yellow.opacity(0.4), .yellow],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .annotation(position: .top) {
                            if count > 0 {
                                Text("\(count)")
                                    .font(.caption2)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                .frame(height: 250)
                
                // 平均满意度和心情
                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("平均满意度")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= Int(averageRating) ? "star.fill" : 
                                      (star == Int(averageRating) + 1 && averageRating.truncatingRemainder(dividingBy: 1) >= 0.5 ? "star.leadinghalf.filled" : "star"))
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                            }
                            Text(String(format: "%.1f", averageRating))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("平均心情")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(moodEmoji)
                            .font(.title3)
                    }
                }
                .padding(.top, 8)
            }
        }
    }
    
    // 标签图表
    private var tagChartView: some View {
        VStack {
            if filteredRecords.isEmpty || tagCounts.isEmpty {
                ChartPlaceholder(message: "没有足够的标签数据生成图表")
            } else {
                Chart {
                    ForEach(Array(tagCounts.keys.prefix(5)), id: \.self) { tagName in
                        if let count = tagCounts[tagName] {
                            SectorMark(
                                angle: .value("次数", count),
                                innerRadius: .ratio(0.618),
                                angularInset: 1.0
                            )
                            .foregroundStyle(by: .value("标签", tagName))
                            .annotation(position: .overlay) {
                                if count > max(1, (filteredRecords.count / 10)) {
                                    VStack {
                                        Text(tagName)
                                            .font(.caption2)
                                            .foregroundColor(.white)
                                            .fontWeight(.bold)
                                        
                                        Text("\(count)次")
                                            .font(.caption2)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 0)
                                }
                            }
                        }
                    }
                }
                .frame(height: 250)
                
                // 标签列表
                VStack(alignment: .leading, spacing: 8) {
                    Text("常用标签")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    FlowLayout(alignment: .leading, spacing: 8) {
                        ForEach(Array(tagCounts.keys.prefix(8)), id: \.self) { tagName in
                            if let count = tagCounts[tagName] {
                                HStack(spacing: 4) {
                                    Text(tagName)
                                    Text("(\(count))")
                                        .foregroundColor(.secondary)
                                }
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
    }
    
    // 数据分析摘要
    private var dataSummary: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("数据洞察")
                .font(.headline)
            
            if filteredRecords.isEmpty {
                Text("暂无足够数据提供洞察")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(dataInsights, id: \.self) { insight in
                        HStack(alignment: .top, spacing: 12) {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 8, height: 8)
                                .padding(.top, 6)
                            
                            Text(insight)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.systemBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // 图表占位符
    private struct ChartPlaceholder: View {
        let message: String
        
        var body: some View {
            VStack(spacing: 16) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 50))
                    .foregroundColor(.gray.opacity(0.5))
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 250)
        }
    }
    
    // 计算平均持续时间字符串
    private var averageDurationString: String {
        if filteredRecords.isEmpty {
            return "0分钟"
        }
        
        let totalSeconds = filteredRecords.reduce(0) { $0 + $1.duration }
        let avgMinutes = Double(totalSeconds) / Double(filteredRecords.count) / 60.0
        
        return String(format: "%.1f分钟", avgMinutes)
    }
    
    // 最长持续时间字符串
    private var longestDurationString: String {
        if let longestRecord = filteredRecords.max(by: { $0.duration < $1.duration }) {
            let minutes = longestRecord.duration / 60
            let seconds = longestRecord.duration % 60
            return "\(minutes)分\(seconds > 0 ? "\(seconds)秒" : "")"
        }
        
        return "0分钟"
    }
    
    // 心情表情
    private var moodEmoji: String {
        if filteredRecords.isEmpty {
            return "😐"
        }
        
        let avgMood = Double(filteredRecords.reduce(0) { $0 + $1.mood }) / Double(filteredRecords.count)
        let roundedMood = Int(avgMood.rounded())
        
        switch roundedMood {
        case 1: return "😞"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😊"
        default: return "😐"
        }
    }
    
    // 计算平均评分
    private var averageRating: Double {
        if filteredRecords.isEmpty {
            return 0
        }
        
        return Double(filteredRecords.reduce(0) { $0 + $1.rating }) / Double(filteredRecords.count)
    }
    
    // 计算各评分数量
    private var ratingCounts: [Int] {
        var counts = Array(repeating: 0, count: 5)
        for record in filteredRecords {
            if record.rating >= 1 && record.rating <= 5 {
                counts[record.rating - 1] += 1
            }
        }
        return counts
    }
    
    // 计算标签出现次数
    private var tagCounts: [String: Int] {
        var counts: [String: Int] = [:]
        
        for record in filteredRecords {
            for tag in record.tags {
                counts[tag.name, default: 0] += 1
            }
        }
        
        // 按出现次数排序
        return counts.sorted { $0.value > $1.value }.reduce(into: [:]) { $0[$1.key] = $1.value }
    }
    
    // 持续时间分布
    private var durationBuckets: [Int] {
        var buckets = Array(repeating: 0, count: 5)
        
        for record in filteredRecords {
            let minutes = record.duration / 60
            
            if minutes < 5 {
                buckets[0] += 1
            } else if minutes < 15 {
                buckets[1] += 1
            } else if minutes < 30 {
                buckets[2] += 1
            } else if minutes < 60 {
                buckets[3] += 1
            } else {
                buckets[4] += 1
            }
        }
        
        return buckets
    }
    
    // 持续时间标签
    private var durationLabels: [String] {
        ["<5分钟", "5-15分钟", "15-30分钟", "30-60分钟", ">60分钟"]
    }
    
    // 频率数据结构
    private var frequencyData: (labels: [String], sexData: [Int], masturbationData: [Int]) {
        // 根据选择的日期范围生成不同类型的标签和数据
        switch selectedDateRange {
        case .week:
            // 每日统计
            return weeklyFrequencyData
        case .month:
            // 每周统计
            return monthlyFrequencyData
        case .year:
            // 每月统计
            return yearlyFrequencyData
        case .all:
            // 每年统计或每月统计（取决于数据范围）
            return allTimeFrequencyData
        }
    }
    
    // 周频率数据
    private var weeklyFrequencyData: (labels: [String], sexData: [Int], masturbationData: [Int]) {
        let calendar = Calendar.current
        let now = Date()
        let weekdaySymbols = calendar.shortWeekdaySymbols
        var labels: [String] = []
        var sexData: [Int] = Array(repeating: 0, count: 7)
        var masturbationData: [Int] = Array(repeating: 0, count: 7)
        
        // 获取本周第一天
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        
        // 创建标签
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                let weekday = calendar.component(.weekday, from: date) - 1
                labels.append(weekdaySymbols[weekday == 0 ? 6 : weekday - 1])
            }
        }
        
        // 统计数据
        for record in filteredRecords {
            if let days = calendar.dateComponents([.day], from: startOfWeek, to: record.date).day, days >= 0 && days < 7 {
                if record.type == .sex {
                    sexData[days] += 1
                } else {
                    masturbationData[days] += 1
                }
            }
        }
        
        return (labels, sexData, masturbationData)
    }
    
    // 月频率数据
    private var monthlyFrequencyData: (labels: [String], sexData: [Int], masturbationData: [Int]) {
        // 分为4周
        var labels = ["第1周", "第2周", "第3周", "第4周", "第5周"]
        var sexData = Array(repeating: 0, count: 5)
        var masturbationData = Array(repeating: 0, count: 5)
        
        let calendar = Calendar.current
        
        for record in filteredRecords {
            let week = (calendar.component(.day, from: record.date) - 1) / 7
            if week >= 0 && week < 5 {
                if record.type == .sex {
                    sexData[week] += 1
                } else {
                    masturbationData[week] += 1
                }
            }
        }
        
        return (labels, sexData, masturbationData)
    }
    
    // 年频率数据
    private var yearlyFrequencyData: (labels: [String], sexData: [Int], masturbationData: [Int]) {
        let monthSymbols = Calendar.current.shortMonthSymbols
        var labels = Array(monthSymbols)
        var sexData = Array(repeating: 0, count: 12)
        var masturbationData = Array(repeating: 0, count: 12)
        
        let calendar = Calendar.current
        
        for record in filteredRecords {
            let month = calendar.component(.month, from: record.date) - 1
            if month >= 0 && month < 12 {
                if record.type == .sex {
                    sexData[month] += 1
                } else {
                    masturbationData[month] += 1
                }
            }
        }
        
        return (labels, sexData, masturbationData)
    }
    
    // 全部时间频率数据
    private var allTimeFrequencyData: (labels: [String], sexData: [Int], masturbationData: [Int]) {
        // 如果记录跨越多年，则按年统计，否则按月统计
        let calendar = Calendar.current
        
        if let earliest = filteredRecords.min(by: { $0.date < $1.date })?.date,
           let latest = filteredRecords.max(by: { $0.date < $1.date })?.date {
            
            let yearDiff = calendar.dateComponents([.year], from: earliest, to: latest).year ?? 0
            
            if yearDiff > 1 {
                // 多年数据，按年统计
                let startYear = calendar.component(.year, from: earliest)
                let endYear = calendar.component(.year, from: latest)
                
                var labels: [String] = []
                var sexData: [Int] = []
                var masturbationData: [Int] = []
                
                for year in startYear...endYear {
                    labels.append("\(year)")
                    
                    let yearSexCount = filteredRecords.filter {
                        calendar.component(.year, from: $0.date) == year && $0.type == .sex
                    }.count
                    
                    let yearMasturbationCount = filteredRecords.filter {
                        calendar.component(.year, from: $0.date) == year && $0.type == .masturbation
                    }.count
                    
                    sexData.append(yearSexCount)
                    masturbationData.append(yearMasturbationCount)
                }
                
                return (labels, sexData, masturbationData)
            }
        }
        
        // 默认按月统计
        return yearlyFrequencyData
    }
    
    // 数据洞察
    private var dataInsights: [String] {
        var insights: [String] = []
        
        if filteredRecords.isEmpty {
            return insights
        }
        
        // 活动类型比例分析
        let sexPercentage = Double(sexRecords.count) / Double(filteredRecords.count) * 100
        if sexPercentage > 70 {
            insights.append("在该时间段内，性爱活动占比较高，达到\(Int(sexPercentage))%。")
        } else if sexPercentage < 30 {
            insights.append("在该时间段内，自慰活动占比较高，达到\(Int(100 - sexPercentage))%。")
        } else {
            insights.append("在该时间段内，性爱与自慰活动比例较为平衡。")
        }
        
        // 活动频率分析
        if filteredRecords.count >= 10 {
            if selectedDateRange == .month && filteredRecords.count >= 15 {
                insights.append("本月活动频率较高，平均每两天就有一次记录。")
            } else if selectedDateRange == .week && filteredRecords.count >= 5 {
                insights.append("本周活动频率较高，几乎每天都有记录。")
            }
        }
        
        // 满意度分析
        if averageRating >= 4 {
            insights.append("总体满意度很高，平均评分达到\(String(format: "%.1f", averageRating))分。")
        } else if averageRating <= 2 {
            insights.append("总体满意度较低，可能需要探索更多方式提高体验质量。")
        }
        
        // 持续时间分析
        let avgMinutes = Double(filteredRecords.reduce(0) { $0 + $1.duration }) / Double(filteredRecords.count) / 60.0
        if avgMinutes >= 30 {
            insights.append("平均持续时间较长，达到\(String(format: "%.1f", avgMinutes))分钟。")
        } else if avgMinutes < 10 {
            insights.append("平均持续时间较短，仅有\(String(format: "%.1f", avgMinutes))分钟。")
        }
        
        // 标签分析
        if let mostCommonTag = tagCounts.keys.first, let count = tagCounts[mostCommonTag] {
            let percentage = Double(count) / Double(filteredRecords.count) * 100
            if percentage > 50 {
                insights.append("\"\(mostCommonTag)\"是最常用的标签，出现在\(Int(percentage))%的记录中。")
            }
        }
        
        return insights
    }
}

struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsView()
            .environmentObject(DataStore())
    }
} 