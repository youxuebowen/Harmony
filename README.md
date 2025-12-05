# Harmony AI 助手

一个基于 HarmonyOS 开发的智能聊天应用，集成豆包 API，提供安全、可靠的 AI 对话体验。

## 项目概述

本项目是一个运行在 HarmonyOS 平台上的 AI 聊天应用，采用现代化的 ArkTS 开发语言和 MVVM 架构设计。应用集成了豆包 API，提供智能对话功能，并包含完整的安全过滤机制和用户体验优化。

## 功能特性

### 核心功能

- **智能对话**：与豆包 AI 进行自然语言交互
- **上下文管理**：支持多轮对话，保留对话上下文
- **安全过滤**：内置安全检查和内容过滤机制
- **个性化设置**：支持调整 AI 响应参数和应用设置

###  安全特性

- **敏感词过滤**：实时检测和过滤敏感内容
- **Prompt 注入防御**：防止恶意提示词攻击
- **安全审核**：严格遵守内容安全政策

### 用户体验

- **流畅界面**：现代化的 ArkUI 组件设计
- **响应式布局**：适配不同屏幕尺寸
- **对话历史**：自动保存和加载对话记录

## 快速开始

### 环境要求
- **HarmonyOS SDK**：API 版本 11+
- **DevEco Studio**：4.0+
- **Node.js**：18.0+

### 安装与运行

1. **克隆项目**
```bash
git clone https://github.com/your-repo/HarmonyAIApp.git
cd HarmonyAIApp
```

2. **配置 API Key**
在 `entry/src/main/ets/network/DoubaoApiService.ets` 中设置你的豆包 API Key：
```typescript
private apiKey: string = "your-doubao-api-key";
```

3. **构建与运行**
- 打开 DevEco Studio
- 导入项目
- 连接 HarmonyOS 设备或模拟器
- 点击运行按钮构建并安装应用

## 项目结构

```
HarmonyAIApp/
├── AppScope/                    # 应用全局配置
│   ├── app.json5               # 应用配置文件
│   └── resources/              # 全局资源文件
├── entry/                      # 主应用模块
│   ├── src/main/
│   │   ├── ets/                # ArkTS 源代码
│   │   │   ├── components/     # 自定义组件
│   │   │   ├── entryability/   # 应用入口
│   │   │   ├── model/          # 数据模型
│   │   │   ├── network/        # 网络请求
│   │   │   ├── pages/          # 应用页面
│   │   │   ├── repository/     # 数据存储
│   │   │   ├── utils/          # 工具类
│   │   │   └── viewmodel/      # 视图模型
│   │   ├── module.json5        # 模块配置
│   │   └── resources/          # 模块资源
│   └── build-profile.json5     # 构建配置
├── build-profile.json5         # 项目构建配置
├── hvigorfile.ts               # 构建脚本
└── README.md                   # 项目文档
```

## 技术架构

### 架构模式
采用 **MVVM (Model-View-ViewModel)** 架构模式：

```
View (Pages)         # 界面层 - ChatPage, SettingsPage
    │
    ▼
ViewModel            # 业务逻辑层 - ChatViewModel, SettingsViewModel
    │
    ▼
Model (Services)     # 数据服务层 - API Service, Storage Service, Security Service
```

### 核心组件

#### 1. 网络模块
- **HttpClient**：HTTP 请求封装，支持 JSON 序列化和认证
- **DoubaoApiService**：豆包 API 服务，处理 AI 对话请求

#### 2. 数据模型
- **Message**：消息数据结构
- **ChatSession**：对话会话管理
- **UserSettings**：用户设置配置

#### 3. 视图模型
- **ChatViewModel**：聊天功能核心逻辑
- **SettingsViewModel**：应用设置管理

#### 4. 用户界面

- **ChatPage**：聊天主页面
- **ChatBubble**：聊天消息气泡组件
- **InputBar**：消息输入组件

## 使用说明

### 基本操作
1. **发送消息**：在输入框中输入内容，点击发送按钮
2. **清空对话**：使用清空按钮清除当前对话历史
3. **设置调整**：通过设置面板调整 AI 参数和应用设置

### AI 参数说明
- **max_completion_tokens**：AI 响应的最大令牌数
- **thinking**：思考模式开关（enabled/disabled/auto）
- **mode**：AI 响应模式（low/medium/high）

## 开发指南

### 代码规范
- 遵循 HarmonyOS ArkTS 编码规范
- 使用 TypeScript 类型系统确保类型安全
- 采用模块化设计，保持代码可维护性

### 测试与调试
- 使用 DevEco Studio 内置调试工具
- 查看应用日志进行问题排查
- 利用模拟器和真实设备进行测试

### 性能优化
- 限制对话历史数量，优化内存使用
- 合理设置网络超时，提升用户体验
- 使用异步处理避免 UI 阻塞

## 安全注意事项

1. **API Key 保护**：不要将 API Key 提交到版本控制系统
2. **内容安全**：严格遵守内容安全政策，避免违规内容
3. **用户隐私**：保护用户对话数据，避免数据泄露

## 贡献

欢迎提交 Issue 和 Pull Request 来改进项目！
