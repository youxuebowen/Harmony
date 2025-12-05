

# ARCHITECTURE.md

# 架构设计文档

## 系统架构

### 整体架构

```
┌─────────────────────────────────────┐
│      HarmonyOS 应用层               │
│  (ArkTS UI + ViewModel)             │
└──────────────┬──────────────────────┘
               │
               │ HTTP/HTTPS
               ▼
┌─────────────────────────────────────┐
│      后端 API 层                    │
│  (Flask + Safety Filter)            │
└──────────────┬──────────────────────┘
               │
               │ API Call
               ▼
┌─────────────────────────────────────┐
│      Claude API                     │
│  (Anthropic)                        │
└─────────────────────────────────────┘
```

### 数据流

1. **用户输入 → 安全检查**
   - 客户端初步验证
   - 服务端深度检查
   - 敏感词过滤

2. **请求处理 → AI 生成**
   - 上下文管理
   - Token 计算
   - API 调用

3. **响应返回 → 展示**
   - 内容渲染
   - 保存历史
   - 更新 UI

## 模块设计

### 1. 前端架构 (MVVM)

```
View (Pages)
    │
    ├── ChatPage
    ├── SettingsPage
    └── MemoryManagementPage
    
ViewModel
    │
    ├── ChatViewModel
    ├── SettingsViewModel
    └── MemoryViewModel
    
Model (Services)
    │
    ├── ModelClient
    ├── StorageService
    └── SecurityService
```

### 2. 安全模块

```
SecurityModule
    │
    ├── SensitiveWordFilter    # 敏感词检测
    ├── DataSanitizer          # 数据脱敏
    ├── ModerationClient       # 内容审核
    └── PromptInjectionDefense # 注入防御
```

### 3. 存储模块

```
StorageModule
    │
    ├── PreferenceStore        # 用户设置
    ├── ConversationStore      # 对话历史
    ├── MemoryStore            # 长期记忆
    └── CacheManager           # 缓存管理
```

## 关键设计决策

### 1. 为什么使用 MVVM？

- 分离关注点
- 便于测试
- 状态管理清晰
- 符合 HarmonyOS 开发规范

### 2. 为什么需要后端？

- 集中式安全控制
- API Key 保护
- 审计和监控
- 速率限制

### 3. 为什么使用 localStorage？

- 简单轻量
- 离线可用
- 无需服务器
- 用户数据本地化

### 4. 上下文窗口管理

- 保留最近 6 条消息（3 轮对话）
- Token 限制：8192
- 超出时自动裁剪
- 保留关键信息

## 性能优化

### 1. 响应速度

- 流式输出（计划中）
- 本地缓存
- 预加载常用设置
- 懒加载历史记录

### 2. 内存管理

- 及时清理无用对话
- 限制历史记录数量
- 分页加载
- 图片压缩

### 3. 网络优化

- 请求合并
- 失败重试
- 超时控制
- CDN 加速（未来）

## 安全设计

### 1. 客户端安全

- 输入验证
- XSS 防护
- 数据加密
- 安全存储

### 2. 服务端安全

- Token 验证
- 速率限制
- 日志审计
- 异常监控

### 3. 通信安全

- HTTPS only
- 请求签名
- 防重放攻击
- 敏感数据加密

## 可扩展性

### 1. 功能扩展

- 插件系统（计划中）
- 工具调用
- 多模态输入
- 自定义提示词

### 2. 性能扩展

- 负载均衡
- 水平扩展
- 缓存层
- 消息队列

### 3. 部署扩展

- Docker 容器化
- K8s 编排
- CI/CD 自动化
- 多区域部署