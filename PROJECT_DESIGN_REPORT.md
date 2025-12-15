# Harmony AI 助手 - 项目设计报告

## 报告概述

本报告详细介绍 Harmony AI 助手项目的工程组织设计和技术架构设计，旨在帮助开发团队理解项目结构、技术选型和实现原理，为后续开发、维护和扩展提供指导。

---

## 第一部分：工程组织设计

### 1. 项目结构

项目采用 HarmonyOS 标准项目结构，基于模块化设计理念，将功能划分为不同的模块和层次，确保代码的可维护性和可扩展性。

```
HarmonyAIApp/
├── AppScope/                    # 应用全局配置
│   ├── app.json5               # 应用元数据配置
│   └── resources/              # 全局资源文件
├── entry/                      # 主应用模块
│   ├── src/main/               # 主源码目录
│   │   ├── ets/                # ArkTS 源代码
│   │   │   ├── components/     # 自定义 UI 组件
│   │   │   ├── entryability/   # 应用入口能力
│   │   │   ├── model/          # 数据模型定义
│   │   │   ├── network/        # 网络请求与 API 封装
│   │   │   ├── pages/          # 应用页面
│   │   │   ├── repository/     # 数据存储与管理
│   │   │   ├── utils/          # 工具类
│   │   │   └── viewmodel/      # 视图模型（业务逻辑层）
│   │   ├── module.json5        # 模块配置
│   │   └── resources/          # 模块资源文件
│   ├── build-profile.json5     # 模块构建配置
│   └── hvigorfile.ts           # 模块构建脚本
├── build-profile.json5         # 项目构建配置
├── hvigorfile.ts               # 项目构建脚本
└── oh-package.json5            # 项目依赖配置
```

### 2. 模块职责划分

| 模块名称 | 主要职责 | 文件位置 |
|---------|---------|---------|
| **应用入口** | 应用生命周期管理 | entry/ets/entryability/EntryAbility.ets |
| **UI 组件** | 可复用的界面组件 | entry/ets/components/ |
| **数据模型** | 数据结构定义 | entry/ets/model/ |
| **网络层** | API 调用与 HTTP 封装 | entry/ets/network/ |
| **页面** | 应用界面实现 | entry/ets/pages/ |
| **数据存储** | 数据持久化与管理 | entry/ets/repository/ |
| **工具类** | 通用功能工具 | entry/ets/utils/ |
| **视图模型** | 业务逻辑处理 | entry/ets/viewmodel/ |

### 3. 资源管理

项目采用 HarmonyOS 标准资源管理机制，资源文件按功能和类型分类存放：

- **全局资源**：存放于 `AppScope/resources/`，供整个应用使用
- **模块资源**：存放于 `entry/src/main/resources/`，仅当前模块使用
- **资源类型**：包括布局文件、字符串、颜色、图片、动画等

资源访问通过 `$` 符号进行，例如：
```typescript
// 访问字符串资源
$string:app_name

// 访问图片资源
$media:icon

// 访问颜色资源
$color:background_color
```

### 4. 构建与配置

项目使用 HarmonyOS 构建工具链，通过以下配置文件管理构建过程：

1. **app.json5**：应用元数据配置，包括应用名称、版本号、图标等
2. **module.json5**：模块配置，包括入口能力、设备类型、权限声明等
3. **build-profile.json5**：构建配置，包括编译选项、签名信息等
4. **hvigorfile.ts**：构建脚本，定义构建任务和流程

### 5. 依赖管理

项目通过 `oh-package.json5` 管理依赖，支持 HarmonyOS 生态的第三方库和组件。

---

## 第二部分：技术架构设计

### 1. 整体架构

项目采用 **MVVM (Model-View-ViewModel)** 架构模式，实现了界面与业务逻辑的分离，提高了代码的可测试性和可维护性。

```
┌─────────────────────────────────────┐
│             View Layer              │
│  (ArkTS UI Components & Pages)      │
└──────────────┬──────────────────────┘
               │ 数据绑定
               ▼
┌─────────────────────────────────────┐
│          ViewModel Layer            │
│  (业务逻辑处理与状态管理)           │
└──────────────┬──────────────────────┘
               │ 服务调用
               ▼
┌─────────────────────────────────────┐
│            Model Layer              │
│  (数据模型、网络请求、数据存储)     │
└──────────────┬──────────────────────┘
               │ API 调用
               ▼
┌─────────────────────────────────────┐
│            Doubao API               │
│  (豆包 AI 服务)                     │
└─────────────────────────────────────┘
```

### 2. 核心组件设计

#### 2.1 网络层组件

**HttpClient 类**
- **功能**：HTTP 请求封装，支持 POST 请求和 JSON 序列化
- **关键特性**：
  - 支持自定义请求头
  - 内置超时处理
  - 错误处理与日志记录
  - Promise 异步封装

**DoubaoApiService 类**
- **功能**：豆包 API 服务封装
- **关键特性**：
  - 消息格式适配
  - 系统提示词管理
  - 安全策略实现
  - API 响应解析

#### 2.2 数据模型

**Message 接口**
```typescript
export interface Message {
  role: 'user' | 'assistant' | 'system';
  content: MessageContent | string;
}
```

**RequestBody 接口**
```typescript
export interface RequestBody {
  model: string;
  max_completion_tokens: number;
  messages: Message[];
  thinking?: 'enabled' | 'disabled' | 'auto';
  stream?: boolean;
}
```

#### 2.3 视图模型

**ChatViewModel 类**
- **功能**：聊天功能核心业务逻辑
- **主要方法**：
  - `sendMessage()`：发送消息并处理响应
  - `regenerateLastResponse()`：重新生成上一条响应
  - `loadPreferences()`：加载用户设置

**架构优势**：
- 分离关注点，界面与逻辑解耦
- 便于单元测试和功能扩展
- 状态管理清晰，减少数据流混乱

### 3. 数据流设计

#### 3.1 消息发送流程

```
1. 用户输入内容 → ChatPage
2. 调用 ChatViewModel.sendMessage()
3. 安全检查 → SecurityUtils.checkSafety()
4. 构建消息对象 → Message
5. 调用 DoubaoApiService.chat()
6. HttpClient 发送 POST 请求
7. 接收 API 响应 → DoubaoResponse
8. 解析响应内容 → 提取助手回复
9. 更新聊天记录 → 保存到本地存储
10. 更新 UI → ChatPage 刷新消息列表
```

#### 3.2 数据持久化流程

```
1. 用户发送/接收消息
2. ChatViewModel 调用 Repository 保存
3. Repository 进行数据序列化
4. 使用 Preferences 或 FileSystem 存储
5. 下次启动时自动加载
```

### 4. 技术栈

| 技术/框架 | 版本 | 用途 |
|---------|-----|------|
| **HarmonyOS** | API 11+ | 应用运行平台 |
| **ArkTS** | 4.0+ | 开发语言 |
| **ArkUI** | 4.0+ | UI 框架 |
| **ohos.net.http** | 系统 API | 网络请求 |
| **豆包 API** | 最新版 | AI 对话服务 |

### 5. 安全设计

#### 5.1 客户端安全
- **输入验证**：对用户输入进行格式检查和长度限制
- **敏感词过滤**：内置敏感词库，实时检测和过滤
- **数据加密**：本地存储的敏感数据进行加密处理
- **API Key 保护**：避免硬编码，支持动态配置

#### 5.2 通信安全
- **HTTPS**：所有网络请求使用 HTTPS 协议
- **请求签名**：API 请求添加签名验证
- **超时处理**：网络请求设置合理的超时时间
- **重试机制**：请求失败时的自动重试策略

### 6. 性能优化

#### 6.1 内存管理
- **及时清理**：无用对象及时释放
- **分页加载**：对话历史分页加载
- **图片优化**：图片资源压缩和懒加载

#### 6.2 网络优化
- **请求合并**：批量处理相关请求
- **缓存策略**：合理的缓存机制减少网络请求
- **限流控制**：避免频繁 API 调用

#### 6.3 UI 优化
- **延迟加载**：非关键 UI 组件延迟加载
- **状态管理**：避免不必要的 UI 重绘
- **动画优化**：优化动画效果，减少性能消耗

---

## 总结与展望

本项目采用了现代化的工程组织设计和技术架构设计，基于 HarmonyOS 平台特性和最佳实践，实现了一个功能完整、性能优良的 AI 聊天应用。

### 优势
1. **模块化设计**：代码结构清晰，易于维护和扩展
2. **MVVM 架构**：界面与逻辑分离，提高代码质量
3. **安全机制**：多层安全防护，保障数据和通信安全
4. **性能优化**：全面的性能优化策略，提升用户体验

### 未来扩展方向
1. **多模态支持**：增加图片、语音等多模态交互
2. **插件系统**：支持功能插件扩展
3. **云同步**：实现多设备数据同步
4. **个性化推荐**：基于用户行为的个性化推荐
