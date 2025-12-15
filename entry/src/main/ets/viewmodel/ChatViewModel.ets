// 聊天视图模型
// ============================================

import {  ChatMessage, ChatSession, sendResult, sessionMessage } from '../data/ChatMessage';
import { ChatRepository, UserSettings } from '../data/ChatRepository';
import { DoubaoApiService } from '../network/DoubaoApiService';
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

  async sendMessage(content: string): Promise<sendResult> {
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
    const messageContent : ChatMessage ={
      role: "user",
      content:content
    }
    // 创建用户消息
    const userMessage: sessionMessage = {
      sessionID: this.currentSession!.id,
      id: Date.now().toString(),
      messages:messageContent
    };
    // 把消息添加到会话里
    this.currentSession.messages.push(userMessage);

    try {
      // 将当前会话的消息转换为ChatMessage类型数组
      const messages: ChatMessage[] = this.currentSession.messages.map((msg): ChatMessage => ({
        role: msg.messages?.role as string,
        content: msg.messages?.content as string
      }));
      // 调用豆包API
      const response = await this.apiService.chatAI(messages);
      
      // 确保响应不为空且有choices
      if (!response || !response.choices || response.choices.length === 0) {
        throw new Error('API响应格式错误: 缺少必要的choices字段');
      }
      
      // 获取第一个选择项中的消息
      const responseChoice = response.choices[0];
      const assistantMessageContent = responseChoice.message;

      // 创建助手消息
      const assistantMessage: sessionMessage = {
        sessionID: this.currentSession.id,
        id: (Date.now() + 1).toString(),
        messages:assistantMessageContent
      };

      this.currentSession.messages.push(assistantMessage);
      this.currentSession.updatedAt = Date.now();
      // 保存会话
      // await this.repository.saveCurrentSession(this.currentSession);
      return { success: true,message: '发送成功'};
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
    const lastUserMessage = this.currentSession.messages[-1];

    const result = await this.sendMessage(lastUserMessage.messages?.content as string);
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

  getMessages(): sessionMessage[] {
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

