import SwiftUI
import LocalAuthentication

struct SettingsView: View {
    @EnvironmentObject var dataStore: DataStore
    @Binding var isAuthenticated: Bool
    @State private var showingDeleteConfirmation = false
    @State private var selectedTheme = "system"
    @State private var showingAbout = false
    @State private var showExportOptions = false
    @Environment(\.openURL) private var openURL
    
    private let quietHoursFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            List {
                // 安全与隐私设置
                Section(header: Text("安全与隐私")) {
                    Toggle("应用锁定", isOn: Binding(
                        get: { dataStore.settings.appLock },
                        set: {
                            dataStore.settings.appLock = $0
                            dataStore.saveSettings()
                        }
                    ))
                    
                    if dataStore.settings.appLock {
                        Toggle("生物识别", isOn: Binding(
                            get: { dataStore.settings.biometricAuth },
                            set: {
                                dataStore.settings.biometricAuth = $0
                                dataStore.saveSettings()
                            }
                        ))
                        .disabled(!canUseBiometrics())
                    }
                    
                    Toggle("数据加密", isOn: Binding(
                        get: { dataStore.settings.dataEncryption },
                        set: {
                            dataStore.settings.dataEncryption = $0
                            dataStore.saveSettings()
                        }
                    ))
                    
                    Button(action: {
                        // 修改密码
                    }) {
                        Text("修改访问密码")
                    }
                }
                
                // 通知设置
                Section(header: Text("通知")) {
                    Toggle("推送通知", isOn: Binding(
                        get: { dataStore.settings.pushNotifications },
                        set: {
                            dataStore.settings.pushNotifications = $0
                            dataStore.saveSettings()
                        }
                    ))
                    
                    Toggle("免打扰时间", isOn: Binding(
                        get: { dataStore.settings.quietHours },
                        set: {
                            dataStore.settings.quietHours = $0
                            dataStore.saveSettings()
                        }
                    ))
                    
                    if dataStore.settings.quietHours {
                        HStack {
                            Text("开始时间")
                            Spacer()
                            DatePicker(
                                "",
                                selection: Binding(
                                    get: { dataStore.settings.quietHoursStart },
                                    set: {
                                        dataStore.settings.quietHoursStart = $0
                                        dataStore.saveSettings()
                                    }
                                ),
                                displayedComponents: .hourAndMinute
                            )
                            .labelsHidden()
                        }
                        
                        HStack {
                            Text("结束时间")
                            Spacer()
                            DatePicker(
                                "",
                                selection: Binding(
                                    get: { dataStore.settings.quietHoursEnd },
                                    set: {
                                        dataStore.settings.quietHoursEnd = $0
                                        dataStore.saveSettings()
                                    }
                                ),
                                displayedComponents: .hourAndMinute
                            )
                            .labelsHidden()
                        }
                    }
                }
                
                // 外观设置
                Section(header: Text("外观")) {
                    Picker("主题", selection: Binding(
                        get: { dataStore.settings.darkMode },
                        set: {
                            dataStore.settings.darkMode = $0
                            dataStore.saveSettings()
                        }
                    )) {
                        Text("系统").tag("system")
                        Text("浅色").tag("light")
                        Text("深色").tag("dark")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // 数据管理
                Section(header: Text("数据管理")) {
                    Button(action: {
                        showExportOptions = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                            Text("导出数据")
                        }
                    }
                    
                    Button(action: {
                        // 导入数据
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                                .foregroundColor(.blue)
                            Text("导入数据")
                        }
                    }
                    
                    Button(action: {
                        showingDeleteConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("清除所有数据")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                // 关于
                Section(header: Text("关于")) {
                    Button(action: {
                        showingAbout = true
                    }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            Text("关于应用")
                        }
                    }
                    
                    #if os(iOS)
                    Button(action: {
                        // 给应用评分
                        if let url = URL(string: "itms-apps://itunes.apple.com/app/idXXXXXXXXXX?action=write-review") {
                            openURL(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "star")
                                .foregroundColor(.blue)
                            Text("给应用评分")
                        }
                    }
                    
                    Button(action: {
                        // 分享应用 - 这里需要引入 UIKit，或者使用 SwiftUI 的方式
                        shareApp()
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                            Text("分享应用")
                        }
                    }
                    #endif
                }
                
                // 退出登录
                Section {
                    Button(action: {
                        isAuthenticated = false
                    }) {
                        HStack {
                            Spacer()
                            Text("退出登录")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
                .listRowBackground(Color.clear)
            }
            #if os(iOS)
            .listStyle(GroupedListStyle())
            #else
            .listStyle(DefaultListStyle())
            #endif
            .navigationTitle("设置")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .alert(isPresented: $showingDeleteConfirmation) {
                Alert(
                    title: Text("清除所有数据"),
                    message: Text("确定要删除所有记录吗？此操作无法撤销。"),
                    primaryButton: .destructive(Text("删除")) {
                        dataStore.records = []
                        dataStore.saveRecords()
                    },
                    secondaryButton: .cancel(Text("取消"))
                )
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            #if os(iOS)
            .actionSheet(isPresented: $showExportOptions) {
                ActionSheet(
                    title: Text("导出数据"),
                    message: Text("选择导出格式"),
                    buttons: [
                        .default(Text("CSV")) {
                            exportData(format: "csv")
                        },
                        .default(Text("JSON")) {
                            exportData(format: "json")
                        },
                        .cancel()
                    ]
                )
            }
            #else
            // macOS替代方案 - 可以使用弹出式菜单或其他方式
            .onChange(of: showExportOptions) { show in
                if show {
                    // 在macOS上，可以使用弹出式菜单或其他方式来选择导出格式
                    // 这里简单处理，直接导出JSON格式
                    exportData(format: "json")
                    showExportOptions = false
                }
            }
            #endif
        }
    }
    
    private func canUseBiometrics() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    private func exportData(format: String) {
        // 在真实应用中，应实现数据导出功能
    }
    
    private func shareApp() {
        // 在实际应用中，应使用SwiftUI的ShareLink或对接UIActivityViewController
        // 这里简化处理
    }
}

struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // 应用图标
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white)
                            .frame(width: 96, height: 96)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.pink)
                    }
                    
                    // 应用名称和版本
                    VStack(spacing: 4) {
                        Text("私密时刻")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("版本 1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // 应用描述
                    Text("私密时刻是一款帮助您记录和分析私密生活的应用，提供安全、直观的界面，让您轻松追踪重要时刻。")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundColor(.secondary)
                    
                    // 开发信息
                    VStack(spacing: 16) {
                        Text("开发者")
                            .font(.headline)
                        
                        Text("本应用由iOS开发团队开发")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("© 2023 All Rights Reserved")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // 联系方式
                    VStack(spacing: 16) {
                        Text("联系我们")
                            .font(.headline)
                        
                        Button(action: {
                            if let url = URL(string: "mailto:support@example.com") {
                                openURL(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "envelope")
                                Text("support@example.com")
                            }
                            .foregroundColor(.blue)
                        }
                        
                        Button(action: {
                            if let url = URL(string: "https://www.example.com") {
                                openURL(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "globe")
                                Text("www.example.com")
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                }
                .padding(.vertical, 40)
            }
            .navigationTitle("关于")
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isAuthenticated: .constant(true))
            .environmentObject(DataStore())
    }
} 