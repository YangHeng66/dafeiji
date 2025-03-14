import SwiftUI

struct RecordView: View {
    @EnvironmentObject var dataStore: DataStore
    @Binding var isPresented: Bool
    @State private var selectedType: RecordType = .sex
    @State private var duration: Int = 0
    @State private var date: Date = Date()
    @State private var rating: Int = 3
    @State private var mood: Int = 3
    @State private var selectedTags: Set<Tag> = []
    @State private var notes: String = ""
    
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    
    // 计时器相关
    @State private var isTimerRunning = false
    @State private var timerCount = 0
    @State private var timer: Timer? = nil
    
    @State private var showingTagSheet = false
    @State private var newTagName = ""
    
    // 是否从TabView直接打开
    init(isPresented: Binding<Bool>? = nil) {
        if let isPresented = isPresented {
            self._isPresented = isPresented
        } else {
            self._isPresented = .constant(false)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 类型选择
                    recordTypeSection
                    
                    // 时长记录
                    durationSection
                    
                    // 日期和时间
                    dateSection
                    
                    // 标签和满意度
                    tagsAndRatingSection
                    
                    // 备注
                    notesSection
                }
                .padding()
            }
            .navigationTitle("添加记录")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    if isPresented != nil {
                        Button("取消") {
                            isPresented = false
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveRecord()
                    }
                }
                #else
                ToolbarItem(placement: .automatic) {
                    if isPresented != nil {
                        Button("取消") {
                            isPresented = false
                        }
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                    Button("保存") {
                        saveRecord()
                    }
                }
                #endif
            }
            .sheet(isPresented: $showingTagSheet) {
                TagSelectionView(selectedTags: $selectedTags, allTags: Tag.defaultTags, onAddNewTag: { tagName in
                    let newTag = Tag(name: tagName)
                    selectedTags.insert(newTag)
                })
            }
        }
    }
    
    // 类型选择部分
    private var recordTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择类型")
                .font(.headline)
            
            HStack(spacing: 20) {
                ForEach(RecordType.allCases) { type in
                    Button(action: {
                        withAnimation {
                            selectedType = type
                        }
                    }) {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(selectedType == type ?
                                        (type == .sex ? Color.blue.opacity(0.1) : Color.purple.opacity(0.1)) :
                                        Color.gray.opacity(0.1))
                                    .frame(width: 64, height: 64)
                                
                                Image(systemName: type.iconName)
                                    .font(.system(size: 24))
                                    .foregroundColor(selectedType == type ?
                                        (type == .sex ? Color.blue : Color.purple) :
                                        Color.gray)
                            }
                            
                            Text(type.rawValue)
                                .font(.subheadline)
                                .foregroundColor(selectedType == type ? .primary : .secondary)
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .padding()
        .background(Color.systemBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // 时长记录部分
    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("时长")
                .font(.headline)
            
            VStack(spacing: 16) {
                // 计时器显示
                Text(formatDuration(timerCount))
                    .font(.system(size: 40, weight: .bold))
                    .monospacedDigit()
                
                // 计时器控制按钮
                HStack(spacing: 20) {
                    Button(action: {
                        if isTimerRunning {
                            stopTimer()
                        } else {
                            startTimer()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(isTimerRunning ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: isTimerRunning ? "stop.fill" : "play.fill")
                                .font(.system(size: 24))
                                .foregroundColor(isTimerRunning ? .red : .green)
                        }
                    }
                    
                    Button(action: resetTimer) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Divider()
                    .padding(.vertical, 8)
                
                // 手动输入时长
                Text("或手动输入时长")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    VStack {
                        Text("小时")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("小时", selection: $hours) {
                            ForEach(0..<6) { hour in
                                Text("\(hour)").tag(hour)
                            }
                        }
                        #if os(iOS)
                        .pickerStyle(WheelPickerStyle())
                        #else
                        .pickerStyle(DefaultPickerStyle())
                        #endif
                        .frame(height: 100)
                        .clipped()
                    }
                    
                    VStack {
                        Text("分钟")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("分钟", selection: $minutes) {
                            ForEach(0..<60) { minute in
                                Text("\(minute)").tag(minute)
                            }
                        }
                        #if os(iOS)
                        .pickerStyle(WheelPickerStyle())
                        #else
                        .pickerStyle(DefaultPickerStyle())
                        #endif
                        .frame(height: 100)
                        .clipped()
                    }
                    
                    VStack {
                        Text("秒")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("秒", selection: $seconds) {
                            ForEach(0..<60) { second in
                                Text("\(second)").tag(second)
                            }
                        }
                        #if os(iOS)
                        .pickerStyle(WheelPickerStyle())
                        #else
                        .pickerStyle(DefaultPickerStyle())
                        #endif
                        .frame(height: 100)
                        .clipped()
                    }
                }
                .onChange(of: hours) { _ in updateDuration() }
                .onChange(of: minutes) { _ in updateDuration() }
                .onChange(of: seconds) { _ in updateDuration() }
            }
        }
        .padding()
        .background(Color.systemBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // 日期选择部分
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("日期与时间")
                .font(.headline)
            
            DatePicker("", selection: $date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .labelsHidden()
        }
        .padding()
        .background(Color.systemBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // 标签和满意度部分
    private var tagsAndRatingSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 标签
            VStack(alignment: .leading, spacing: 12) {
                Text("标签")
                    .font(.headline)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(selectedTags)) { tag in
                            HStack {
                                Text(tag.name)
                                    .font(.subheadline)
                                
                                Button(action: {
                                    selectedTags.remove(tag)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(20)
                        }
                        
                        Button(action: {
                            showingTagSheet = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("添加标签")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.1))
                            .foregroundColor(.primary)
                            .cornerRadius(20)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            
            // 满意度
            VStack(alignment: .leading, spacing: 12) {
                Text("满意度")
                    .font(.headline)
                
                HStack(spacing: 16) {
                    ForEach(1...5, id: \.self) { star in
                        Button(action: {
                            rating = star
                        }) {
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .font(.title2)
                                .foregroundColor(star <= rating ? .yellow : .gray)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            // 心情
            VStack(alignment: .leading, spacing: 12) {
                Text("心情")
                    .font(.headline)
                
                HStack {
                    Text("😞")
                        .font(.title)
                    
                    Slider(value: Binding(
                        get: { Double(mood) },
                        set: { mood = Int($0) }
                    ), in: 1...5, step: 1)
                    .accentColor(moodColor)
                    
                    Text("😊")
                        .font(.title)
                }
                .padding(.vertical, 8)
            }
        }
        .padding()
        .background(Color.systemBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // 备注部分
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("备注")
                .font(.headline)
            
            TextEditor(text: $notes)
                .frame(minHeight: 100)
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .overlay(
                    Group {
                        if notes.isEmpty {
                            Text("添加关于这次体验的任何想法或感受...")
                                .foregroundColor(.gray.opacity(0.7))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 12)
                                .allowsHitTesting(false)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }
                    }
                )
        }
        .padding()
        .background(Color.systemBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // 心情颜色
    private var moodColor: Color {
        switch mood {
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return .green
        case 5: return .blue
        default: return .yellow
        }
    }
    
    // 开始计时器
    private func startTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timerCount += 1
            updateTimeComponents()
        }
    }
    
    // 停止计时器
    private func stopTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    // 重置计时器
    private func resetTimer() {
        stopTimer()
        timerCount = 0
        hours = 0
        minutes = 0
        seconds = 0
        duration = 0
    }
    
    // 更新时间组件
    private func updateTimeComponents() {
        hours = timerCount / 3600
        minutes = (timerCount % 3600) / 60
        seconds = timerCount % 60
        duration = timerCount
    }
    
    // 从时间组件更新总秒数
    private func updateDuration() {
        duration = hours * 3600 + minutes * 60 + seconds
        timerCount = duration
    }
    
    // 格式化持续时间
    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = seconds % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    // 保存记录
    private func saveRecord() {
        let record = Record(
            type: selectedType,
            duration: duration,
            date: date,
            rating: rating,
            mood: mood,
            tags: Array(selectedTags),
            notes: notes.isEmpty ? nil : notes
        )
        
        dataStore.addRecord(record)
        
        // 关闭视图或重置表单
        if isPresented != nil {
            isPresented = false
        } else {
            // 重置表单
            selectedType = .sex
            resetTimer()
            date = Date()
            rating = 3
            mood = 3
            selectedTags = []
            notes = ""
        }
    }
}

struct TagSelectionView: View {
    @Binding var selectedTags: Set<Tag>
    let allTags: [Tag]
    let onAddNewTag: (String) -> Void
    
    @State private var newTagName = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("已选标签")) {
                    if selectedTags.isEmpty {
                        Text("尚未选择标签")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(Array(selectedTags)) { tag in
                            HStack {
                                Text(tag.name)
                                Spacer()
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedTags.remove(tag)
                            }
                        }
                    }
                }
                
                Section(header: Text("可用标签")) {
                    ForEach(allTags.filter { !selectedTags.contains($0) }) { tag in
                        HStack {
                            Text(tag.name)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedTags.insert(tag)
                        }
                    }
                }
                
                Section(header: Text("添加新标签")) {
                    HStack {
                        TextField("标签名称", text: $newTagName)
                        
                        Button(action: {
                            if !newTagName.isEmpty {
                                onAddNewTag(newTagName)
                                newTagName = ""
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .disabled(newTagName.isEmpty)
                    }
                }
            }
            #if os(iOS)
            .listStyle(InsetGroupedListStyle())
            #else
            .listStyle(DefaultListStyle())
            #endif
            .navigationTitle("选择标签")
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

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView(isPresented: .constant(true))
            .environmentObject(DataStore())
    }
} 