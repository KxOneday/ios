# 倒数日 (CountDown)

一款精美的 iOS 倒数日/纪念日应用，支持公历农历，动漫插画风格 UI。

## ✨ 功能特点

- 📅 倒数日（未来）+ 纪念日（过去）
- 🌙 公历 + 农历双轨支持，一键切换，自动转换
- 🎨 10 种动漫插画风格主题（花间、星海、夏日、冬雪、月夜等）
- 🔔 提前提醒通知
- 📱 桌面小组件（小/中/大 + 锁屏）
- 🔒 密码/面容锁定
- 💾 iCloud 同步
- 🏷️ 事件分类与筛选
- 📤 分享精美倒数日图片

## 📦 安装

### 通过 GitHub Actions 打包

1. Push 代码到 `main` 分支
2. GitHub Actions 自动构建
3. 在 Actions 页面下载未签名 IPA
4. 使用 AltStore/Sideloadly 签名安装到设备

### 手动构建

```bash
xcodebuild \
  -project CountDown.xcodeproj \
  -scheme CountDown \
  -configuration Release \
  -sdk iphoneos \
  -derivedDataPath build \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  build
```

## 🛠️ 技术栈

- Swift 5
- SwiftUI
- SwiftData
- WidgetKit
- iOS 16+

## 📁 项目结构

```
├── CountDown/
│   ├── CountDownApp.swift        # App 入口
│   ├── Views/
│   │   ├── ContentView.swift     # 主列表
│   │   ├── AddEventView.swift    # 添加事件
│   │   └── EventDetailView.swift # 事件详情
│   ├── Models/
│   │   ├── CountdownEvent.swift  # 数据模型
│   │   ├── LunarCalendar.swift   # 农历工具
│   │   ├── ThemeManager.swift    # 主题管理
│   │   └── NotificationManager.swift
│   ├── Assets.xcassets/
│   └── Info.plist
├── CountDownWidget/
│   ├── CountDownWidget.swift     # 小组件
│   ├── Assets.xcassets/
│   └── Info.plist
├── .github/workflows/
│   └── build-ios-unsigned.yml    # CI 打包
└── CountDown.xcodeproj/
```

## 📝 说明

生成的 IPA 文件为**未签名**版本，安装到真机前需要使用签名工具处理。
