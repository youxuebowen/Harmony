// 聊天视图模型
// ============================================

import { Message, ChatSession, sendMessage, messageContent } from '../model/ChatMessage';
import { ChatRepository, UserSettings } from '../repository/ChatRepository';
import { DoubaoApiService } from '../network/DoubaoApiService';
import { SecurityUtils } from '../utils/SecurityUtils';
import common from '@ohos.app.ability.common';


export class ChatViewModel {
  private repository: ChatRepository;
  private apiService: DoubaoApiService;
  private currentSession: ChatSession | null = null;
  private settings: UserSettings;

  constructor() {
    this.repository = ChatRepository.getInstance();
    this.apiService = new DoubaoApiService();

    // 初始化默认设置
    this.settings = {
      mode:'low',
      // 思考模式
      thinking : 'auto',
      maxTokens : 4096*10
      // memoryEnabled: false,
      // language: 'zh-CN'
    };

    this.initialize();
  }

  private async initialize() {

    const context = globalThis.abilityContext as common.UIAbilityContext | undefined;
    if (context) {
      await this.repository.initialize(context);
      this.settings = await this.repository.loadSettings();
      this.currentSession = await this.repository.loadCurrentSession();
    }
  }

  async sendMessage(content: string): Promise<sendMessage> {
    // 安全检查
    const safetyCheck = SecurityUtils.checkSafety(content);
    if (!safetyCheck.safe) {
      return {
        success: false,
        message: safetyCheck.message as string
      };
    }
    // 初始化或更新会话,如果会话未null
    if (!this.currentSession) {
      this.currentSession = {
        id: Date.now().toString(),
        title: content.substring(0, 30),
        messages: [],
        createdAt: Date.now(),
        updatedAt: Date.now()
      };
    }

    // 创建用户消息
    const userMessage: Message = {
      id: Date.now().toString(),
      role: 'user',
      content: content,
      timestamp: Date.now(),
      sessionID: this.currentSession!.id
    };
    // 把消息添加到会话里

    this.currentSession.messages.push(userMessage);

    try {

      // 使用时指定类型
      const apiMessages: messageContent[] = this.currentSession.messages.map((msg): messageContent => ({
        role: msg.role,
        content: msg.content
      }));

      // 调用豆包API，使用新的参数格式
      const response = await this.apiService.chat(apiMessages, {
        mode: this.settings.mode,
        // 豆包API使用reasoning_effort而不是temperature
        thinking: this.settings.thinking,
        maxTokens: this.settings.maxTokens // 使用豆包API支持的较大值
      });

      // 创建助手消息
      const assistantMessage: Message = {
        id: (Date.now() + 1).toString(),
        role: 'assistant',
        content: response.content,
        timestamp: Date.now(),
        // metadata: {
        //   tokens: response.tokens,
        //   modelVersion: response.modelVersion
        // },
        sessionID: this.currentSession.id
      };

      this.currentSession.messages.push(assistantMessage);
      this.currentSession.updatedAt = Date.now();

      // 保存会话
      await this.repository.saveCurrentSession(this.currentSession);

      return { success: true, message: safetyCheck.message as string };
    } catch (error) {
      console.error('Send message error:', error);
      return {
        success: false,
        message: '发送失败，请重试'
      };
    }
  }

  async regenerateLastResponse(): Promise<boolean> {
    if (!this.currentSession || this.currentSession.messages.length < 2) {
      return false;
    }

    // 移除最后一条助手消息
    this.currentSession.messages = this.currentSession.messages.slice(0, -1);

    // 获取最后一条用户消息
    const lastUserMessage = this.currentSession.messages[this.currentSession.messages.length - 1];

    const result = await this.sendMessage(lastUserMessage.content);
    return result.success;
  }

  async loadPreferences(): Promise<UserSettings> {
    this.settings = await this.repository.loadSettings();
    return this.settings;
  }

  async updateMode(mode:'low' |'high' | 'medium' |'minimal') {
    this.settings.mode = mode;
    await this.repository.saveSettings(this.settings);
  }

  async updateMemorySetting(enabled: boolean) {
    // this.settings.memoryEnabled = enabled;
    await this.repository.saveSettings(this.settings);
  }

  getMessages(): Message[] {
    return this.currentSession?.messages || [];
  }

  clearMessages() {
    this.currentSession = null;
    this.repository.clearCurrentSession();
  }

  async exportConversation() {
    if (this.currentSession) {
      await this.repository.saveSessionToHistory(this.currentSession);
    }
  }

  /**
   * 获取收藏数据
   * @returns 收藏数据响应
   */
  async getFavor() {
    try {
      const response = await this.apiService.getFavor();
      return response;
    } catch (error) {
      console.error('获取收藏数据失败:', error);
      return null;
    }
  }
}

