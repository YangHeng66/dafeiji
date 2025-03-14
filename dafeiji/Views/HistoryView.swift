import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var selectedFilter: RecordType? = nil
    @State private var searchText = ""
    @State private var showingFilters = false
    
    private var filteredRecords: [String: [Record]] {
        let records = dataStore.recordsByMonth()
        
        if searchText.isEmpty && selectedFilter == nil {
            return records
        }
        
        var filteredRecords: [String: [Record]] = [:]
        
        for (month, monthRecords) in records {
            let filtered = monthRecords.filter { record in
                let matchesSearch = searchText.isEmpty || 
                                   record.notes?.localizedCaseInsensitiveContains(searchText) ?? false ||
                                   record.tags.contains { $0.name.localizedCaseInsensitiveContains(searchText) }
                
                let matchesFilter = selectedFilter == nil || record.type == selectedFilter
                
                return matchesSearch && matchesFilter
            }
            
            if !filtered.isEmpty {
                filteredRecords[month] = filtered
            }
        }
        
        return filteredRecords
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    // 过滤选项
                    filterBar
                    
                    if filteredRecords.isEmpty {
                        // 没有记录时显示空状态
                        EmptyStateView(
                            title: "没有找到记录",
                            message: searchText.isEmpty && selectedFilter == nil ? 
                                    "开始添加您的第一条记录吧" : 
                                    "尝试更改过滤条件或清除搜索",
                            buttonTitle: searchText.isEmpty && selectedFilter == nil ? "添加记录" : nil,
                            action: searchText.isEmpty && selectedFilter == nil ? {
                                // 添加记录操作
                            } : nil
                        )
                        .padding(.top, 60)
                    } else {
                        // 显示分组记录
                        ForEach(filteredRecords.keys.sorted(by: >), id: \.self) { month in
                            if let records = filteredRecords[month] {
                                MonthSection(month: month, records: records)
                            }
                        }
                    }
                }
            }
            .navigationTitle("历史记录")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            // 搜索
                            showingFilters = true
                        }) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.primary)
                        }
                        
                        Button(action: {
                            // 过滤器
                            showingFilters = true
                        }) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .foregroundColor(.primary)
                        }
                    }
                }
                #endif
                
                #if !os(iOS)
                ToolbarItem(placement: .automatic) {
                    HStack {
                        Button(action: {
                            // 搜索
                            showingFilters = true
                        }) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.system(size: 18))
                        }
                    }
                }
                #endif
            }
            .sheet(isPresented: $showingFilters) {
                FilterView(
                    searchText: $searchText,
                    selectedFilter: $selectedFilter
                )
            }
        }
    }
    
    // 过滤条件栏
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // 全部按钮
                Button(action: {
                    selectedFilter = nil
                }) {
                    Text("全部")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedFilter == nil ? Color.blue : Color.gray.opacity(0.1))
                        .foregroundColor(selectedFilter == nil ? .white : .primary)
                        .cornerRadius(16)
                }
                
                // 记录类型筛选
                ForEach(RecordType.allCases) { type in
                    Button(action: {
                        if selectedFilter == type {
                            selectedFilter = nil
                        } else {
                            selectedFilter = type
                        }
                    }) {
                        Text(type.rawValue)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedFilter == type ? Color.blue : Color.gray.opacity(0.1))
                            .foregroundColor(selectedFilter == type ? .white : .primary)
                            .cornerRadius(16)
                    }
                }
                
                // 时间筛选按钮
                Button(action: {
                    // 本周按钮
                }) {
                    Text("本周")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.1))
                        .foregroundColor(.primary)
                        .cornerRadius(16)
                }
                
                Button(action: {
                    // 本月按钮
                }) {
                    Text("本月")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.1))
                        .foregroundColor(.primary)
                        .cornerRadius(16)
                }
                
                // 排序按钮
                Button(action: {
                    // 排序功能
                    showingFilters = true
                }) {
                    HStack(spacing: 4) {
                        Text("排序")
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.1))
                    .foregroundColor(.primary)
                    .cornerRadius(16)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color.systemBackground)
    }
}

// 月份分组视图
struct MonthSection: View {
    let month: String
    let records: [Record]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 月份标题
            Text(month)
                .font(.headline)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.systemBackground)
                .cornerRadius(8)
            
            // 记录列表
            LazyVStack(spacing: 12) {
                ForEach(records) { record in
                    NavigationLink(destination: RecordDetailView(record: record)) {
                        RecordCard(record: record, onTap: {})
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }
}

// 过滤视图
struct FilterView: View {
    @Binding var searchText: String
    @Binding var selectedFilter: RecordType?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                // 搜索框
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("搜索记录", text: $searchText)
                        .disableAutocorrection(true)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color.systemGray6)
                .cornerRadius(10)
                .padding(.horizontal)
                
                // 类型过滤
                VStack(alignment: .leading, spacing: 16) {
                    Text("按类型过滤")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        // 全部按钮
                        Button(action: {
                            selectedFilter = nil
                        }) {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(selectedFilter == nil ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                                        .frame(width: 60, height: 60)
                                    
                                    Image(systemName: "square.grid.2x2")
                                        .font(.system(size: 24))
                                        .foregroundColor(selectedFilter == nil ? .blue : .gray)
                                }
                                
                                Text("全部")
                                    .font(.subheadline)
                                    .foregroundColor(selectedFilter == nil ? .primary : .secondary)
                            }
                        }
                        
                        // 类型按钮
                        ForEach(RecordType.allCases) { type in
                            Button(action: {
                                selectedFilter = type
                            }) {
                                VStack(spacing: 8) {
                                    ZStack {
                                        Circle()
                                            .fill(selectedFilter == type ? 
                                                (type == .sex ? Color.blue.opacity(0.1) : Color.purple.opacity(0.1)) :
                                                Color.gray.opacity(0.1))
                                            .frame(width: 60, height: 60)
                                        
                                        Image(systemName: type.iconName)
                                            .font(.system(size: 24))
                                            .foregroundColor(selectedFilter == type ? 
                                                (type == .sex ? .blue : .purple) :
                                                .gray)
                                    }
                                    
                                    Text(type.rawValue)
                                        .font(.subheadline)
                                        .foregroundColor(selectedFilter == type ? .primary : .secondary)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
                .padding()
                
                // 重置按钮
                Button(action: {
                    searchText = ""
                    selectedFilter = nil
                }) {
                    Text("重置所有过滤器")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical)
            .navigationTitle("过滤和搜索")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                #endif
            }
        }
    }
}

// 记录详情视图
struct RecordDetailView: View {
    let record: Record
    @State private var showingDeleteConfirmation = false
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 头部信息
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(record.type.rawValue)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(record.formattedDate)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(record.type == .sex ? Color.blue.opacity(0.1) : Color.purple.opacity(0.1))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: record.type.iconName)
                            .font(.system(size: 24))
                            .foregroundColor(record.type == .sex ? .blue : .purple)
                    }
                }
                
                // 时长
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("时长")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(record.formattedDuration)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color.systemBackground)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // 评分和心情
                HStack(spacing: 16) {
                    // 评分
                    VStack(alignment: .leading, spacing: 4) {
                        Text("满意度")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= record.rating ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.systemBackground)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // 心情
                    VStack(alignment: .leading, spacing: 4) {
                        Text("心情")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(moodEmoji)
                            .font(.system(size: 24))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.systemBackground)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                
                // 标签
                if !record.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("标签")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        FlowLayout(alignment: .leading, spacing: 8) {
                            ForEach(record.tags) { tag in
                                Text(tag.name)
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.gray.opacity(0.1))
                                    .foregroundColor(.primary)
                                    .cornerRadius(16)
                            }
                        }
                    }
                    .padding()
                    .background(Color.systemBackground)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                
                // 备注
                if let notes = record.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("备注")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(notes)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(Color.systemBackground)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                
                // 删除按钮
                Button(action: {
                    showingDeleteConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("删除记录")
                    }
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(16)
                }
                .padding(.top, 16)
            }
            .padding()
        }
        .navigationTitle("记录详情")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .alert(isPresented: $showingDeleteConfirmation) {
            Alert(
                title: Text("删除记录"),
                message: Text("确定要删除这条记录吗？此操作无法撤销。"),
                primaryButton: .destructive(Text("删除")) {
                    deleteRecord()
                },
                secondaryButton: .cancel(Text("取消"))
            )
        }
    }
    
    // 心情表情
    private var moodEmoji: String {
        switch record.mood {
        case 1: return "😞"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😊"
        default: return "😐"
        }
    }
    
    // 删除记录
    private func deleteRecord() {
        dataStore.deleteRecord(record)
        presentationMode.wrappedValue.dismiss()
    }
}

// 流式布局视图
struct FlowLayout<Content: View>: View {
    let alignment: HorizontalAlignment
    let spacing: CGFloat
    let content: () -> Content
    
    init(alignment: HorizontalAlignment = .center, spacing: CGFloat = 8, @ViewBuilder content: @escaping () -> Content) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            FlowLayoutHelper(
                width: geometry.size.width,
                alignment: alignment,
                spacing: spacing,
                content: content
            )
        }
    }
}

struct FlowLayoutHelper<Content: View>: View {
    let width: CGFloat
    let alignment: HorizontalAlignment
    let spacing: CGFloat
    let content: () -> Content
    
    @State private var contentSize: [CGSize] = []
    
    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            HStack(spacing: spacing) {
                content()
                    .fixedSize()
                    .readSize { sizes in
                        contentSize = sizes
                    }
            }
            .hidden()
            
            FlowLayoutContent(
                width: width,
                sizes: contentSize,
                alignment: alignment,
                spacing: spacing,
                content: content
            )
        }
    }
}

struct FlowLayoutContent<Content: View>: View {
    let width: CGFloat
    let sizes: [CGSize]
    let alignment: HorizontalAlignment
    let spacing: CGFloat
    let content: () -> Content
    
    var body: some View {
        var rows: [[Int]] = [[]]
        var rowWidth: CGFloat = 0
        
        for (index, size) in sizes.enumerated() {
            if rowWidth + size.width + (rowWidth == 0 ? 0 : spacing) <= width {
                rowWidth += size.width + (rowWidth == 0 ? 0 : spacing)
                rows[rows.count - 1].append(index)
            } else {
                rowWidth = size.width
                rows.append([index])
            }
        }
        
        return VStack(alignment: alignment, spacing: spacing) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(spacing: spacing) {
                    ForEach(rows[rowIndex], id: \.self) { index in
                        content()
                            .fixedSize()
                            .hidden()
                            .overlay(
                                GeometryReader { _ in
                                    content()
                                        .fixedSize()
                                }
                            )
                    }
                }
            }
        }
    }
}

// 用于读取视图大小的修饰器
extension View {
    func readSize(onChange: @escaping ([CGSize]) -> Void) -> some View {
        background(
            GeometryReader { geometry in
                Color.clear.preference(
                    key: SizePreferenceKey.self,
                    value: [geometry.size]
                )
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: [CGSize] = []
    
    static func reduce(value: inout [CGSize], nextValue: () -> [CGSize]) {
        value.append(contentsOf: nextValue())
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .environmentObject(DataStore())
    }
} 