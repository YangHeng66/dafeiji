import SwiftUI
import Charts

struct HomeView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var showAddRecord = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 用户欢迎信息
                    HStack {
                        VStack(alignment: .leading) {
                            Text("你好，小白")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            // 格式化当前日期
                            Text(formattedDate())
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // 用户头像
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                    
                    // 统计卡片
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            // 本月次数卡片
                            StatsCard(
                                title: "本月",
                                value: "\(dataStore.recordsThisMonth.count)",
                                subtitle: compareToPreviousMonth(),
                                iconName: "calendar.badge.clock",
                                iconBackgroundColor: Color.blue.opacity(0.1),
                                iconColor: .blue
                            )
                            .frame(maxWidth: .infinity)
                            
                            // 平均时长卡片
                            StatsCard(
                                title: "平均",
                                value: String(format: "%.1f", dataStore.averageDurationThisMonth),
                                subtitle: "分钟",
                                iconName: "clock",
                                iconBackgroundColor: Color.purple.opacity(0.1),
                                iconColor: .purple
                            )
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal)
                    
                    // 趋势图表
                    VStack(alignment: .leading, spacing: 16) {
                        Text("月度趋势")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        MonthlyTrendsChart(records: dataStore.records)
                            .frame(height: 200)
                            .padding(.horizontal)
                    }
                    
                    // 最近记录
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("最近记录")
                                .font(.headline)
                            
                            Spacer()
                            
                            NavigationLink(destination: HistoryView().environmentObject(dataStore)) {
                                Text("查看全部")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        
                        if dataStore.records.isEmpty {
                            EmptyStateView(
                                title: "没有记录",
                                message: "开始添加您的第一条记录吧",
                                buttonTitle: "添加记录",
                                action: { showAddRecord = true }
                            )
                            .padding()
                        } else {
                            // 最近记录列表
                            ForEach(dataStore.records.sorted(by: { $0.date > $1.date }).prefix(3)) { record in
                                RecordCard(record: record, onTap: {})
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            #if os(iOS)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
            #endif
            .overlay(
                // 添加记录浮动按钮
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showAddRecord = true }) {
                            ZStack {
                                Circle()
                                    .fill(Color.pink)
                                    .frame(width: 56, height: 56)
                                    .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 3)
                                
                                Image(systemName: "plus")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 70) // 给 TabBar 留出空间
                    }
                }
            )
            .sheet(isPresented: $showAddRecord) {
                RecordView(isPresented: $showAddRecord)
                    .environmentObject(dataStore)
            }
        }
    }
    
    // 格式化当前日期
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: Date())
    }
    
    // 和上个月比较
    private func compareToPreviousMonth() -> String {
        // 这里应该实际计算与上个月的比较
        // 为演示简化，我们返回一个固定值
        return "比上月增加 3 次"
    }
}

struct MonthlyTrendsChart: View {
    let records: [Record]
    
    var body: some View {
        Chart {
            ForEach(monthlyDataSex.indices, id: \.self) { index in
                LineMark(
                    x: .value("月份", index),
                    y: .value("次数", monthlyDataSex[index])
                )
                .foregroundStyle(Color.blue)
                .interpolationMethod(.catmullRom)
            }
            .symbol(.circle)
            .symbolSize(30)
            
            ForEach(monthlyDataMasturbation.indices, id: \.self) { index in
                LineMark(
                    x: .value("月份", index),
                    y: .value("次数", monthlyDataMasturbation[index])
                )
                .foregroundStyle(Color.purple)
                .interpolationMethod(.catmullRom)
            }
            .symbol(.circle)
            .symbolSize(30)
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel(format: .dateTime.month(.narrow))
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic)
        }
        .chartLegend(position: .top) {
            HStack {
                Circle().fill(Color.blue).frame(width: 10, height: 10)
                Text("性爱")
                    .font(.caption)
                    .foregroundColor(.primary)
                
                Circle().fill(Color.purple).frame(width: 10, height: 10)
                Text("自慰")
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
        .chartForegroundStyleScale([
            "性爱": Color.blue,
            "自慰": Color.purple
        ])
    }
    
    // 测试数据
    private var monthlyDataSex: [Int] {
        [8, 12, 5, 9, 12]
    }
    
    private var monthlyDataMasturbation: [Int] {
        [15, 11, 20, 14, 8]
    }
    
    // 实际应用中应从记录中计算出月度数据
    private func calculateMonthlyData() -> ([String], [Int], [Int]) {
        // 此处应该是实际计算每月数据的逻辑
        // 为了演示，我们返回固定值
        let months = ["1月", "2月", "3月", "4月", "5月"]
        let sexCounts = monthlyDataSex
        let masturbationCounts = monthlyDataMasturbation
        
        return (months, sexCounts, masturbationCounts)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(DataStore())
    }
} 