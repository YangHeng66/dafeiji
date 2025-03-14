# 私密时刻 (Intimate Moments)

<p align="center">
  <img src="screenshots/app_icon.png" alt="应用图标" width="120"/>
</p>

## 项目概述

"私密时刻"是一款隐私导向的个人健康追踪应用，专为记录和分析用户性生活而设计。该应用提供了直观的界面来记录性活动和自慰行为，并通过数据可视化和分析功能帮助用户了解自己的亲密生活模式。应用采用 SwiftUI 开发，同时支持 iOS 和 macOS 平台。

## 主要功能

- **安全登录系统**：使用密码和生物识别保护隐私数据
- **活动记录**：记录不同类型的性活动，包括：
  - 持续时间（手动输入或使用计时器）
  - 满意度评分（五星制）
  - 情绪状态
  - 活动类型（性行为/自慰）
- **标签系统**：为记录添加自定义标签（如地点、伴侣等）
- **计时器功能**：内置计时器用于准确记录活动持续时间
- **历史记录**：按月份组织的历史记录，支持搜索和过滤
- **数据分析**：提供活动频率、持续时间、满意度等方面的统计和趋势分析
- **设置选项**：自定义应用锁定、数据导出和其他偏好设置
- **跨平台支持**：同时支持 iOS 和 macOS 平台

## 技术栈

- **开发语言**：Swift 5.5+
- **UI 框架**：SwiftUI
- **数据持久化**：UserDefaults (当前版本)
- **图表库**：Swift Charts
- **认证**：LocalAuthentication 框架（生物识别）
- **设计模式**：MVVM 架构

## 安装与运行

### 系统要求

- iOS 15.0+ / macOS 12.0+
- Xcode 14.0+
- Swift 5.5+

### 构建步骤

1. 克隆仓库：

   ```bash
   git clone https://github.com/yourusername/dafeiji.git
   cd dafeiji
   ```

2. 使用 Xcode 打开项目：

   ```bash
   open dafeiji.xcodeproj
   ```

3. 选择目标设备（iOS 设备或 Mac）

4. 点击运行按钮或按下`Cmd+R`开始构建

### 登录凭据

- 用户名：`admin`
- 密码：`password`

## 项目结构

```
dafeiji/
├── Models/              # 数据模型
│   └── RecordModel.swift  # 记录数据模型和数据存储
├── Views/               # 应用视图
│   ├── LoginView.swift    # 登录界面
│   ├── HomeView.swift     # 主页/统计视图
│   ├── RecordView.swift   # 记录添加界面
│   ├── HistoryView.swift  # 历史记录界面
│   ├── AnalyticsView.swift # 数据分析界面
│   └── SettingsView.swift # 设置界面
├── Components/          # 可复用UI组件
│   └── StatsCard.swift    # 统计卡片等组件
├── Utilities/           # 工具类
│   └── ColorExtensions.swift # 颜色扩展
└── ContentView.swift    # 主容器视图
```

## 使用指南

### 添加新记录

1. 点击主页底部的"+"按钮或导航到"记录"选项卡
2. 选择活动类型（性行为/自慰）
3. 使用计时器记录持续时间或手动输入
4. 设置日期和时间
5. 添加相关标签
6. 评价满意度和情绪
7. 添加备注（可选）
8. 点击"保存"

### 查看历史记录

1. 导航到"历史"选项卡
2. 浏览按月份组织的记录
3. 使用搜索栏或过滤器查找特定记录
4. 点击记录查看详情

### 分析数据

1. 导航到"分析"选项卡
2. 查看不同时间范围的统计数据
3. 浏览各种图表和趋势分析
4. 查看智能洞察和建议

## 未来开发计划

### 短期目标（1-3 个月）

- [ ] 实现数据持久化迁移到 CoreData
- [ ] 添加数据备份和恢复功能
- [ ] 优化 UI/UX 设计，提升用户体验
- [ ] 增强数据分析功能，提供更多洞察

### 中期目标（3-6 个月）

- [ ] 添加伴侣管理功能
- [ ] 实现云同步功能（iCloud/自定义服务器）
- [ ] 开发健康提醒和目标设置功能
- [ ] 集成健康数据（如心率、卡路里消耗）

### 长期目标（6 个月以上）

- [ ] 开发配套的 Apple Watch 应用
- [ ] 添加社区功能（匿名分享统计和建议）
- [ ] 实现 AI 驱动的个性化建议
- [ ] 支持更多平台（如 Android、Web）

## 贡献指南

欢迎对项目进行贡献！请遵循以下步骤：

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建 Pull Request

## 代码规范

- 遵循 Swift API 设计指南
- 使用 SwiftLint 保持代码质量
- 为所有公共 API 提供文档注释
- 编写单元测试和 UI 测试

## 隐私声明

"私密时刻"应用高度重视用户隐私：

- 所有数据默认存储在设备本地
- 不收集或传输任何个人数据
- 提供应用锁定功能保护数据安全
- 支持完全删除所有数据的选项

## 许可证

本项目采用 MIT 许可证 - 详情请参阅[LICENSE](LICENSE)文件

## 联系方式

如有问题或建议，请通过以下方式联系：

- 电子邮件：your.email@example.com
- GitHub Issues：[创建新 Issue](https://github.com/yourusername/dafeiji/issues)

---

<p align="center">
  开发者：[您的名字] | 版本：1.0.0 | 最后更新：2023年3月
</p>
