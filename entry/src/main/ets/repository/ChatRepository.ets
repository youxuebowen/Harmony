// 数据仓库层 - 封装所有数据操作
// ============================================

import preferences from '@ohos.data.preferences';
import { Message, ChatSession } from '../model/ChatMessage';
import { UserMemory } from '../model/UserMemory';

export class ChatRepository {
  private static instance: ChatRepository;
  private preferencesStore: preferences.Preferences | null = null;

  private constructor() {}

  static getInstance(): ChatRepository {
    if (!ChatRepository.instance) {
      ChatRepository.instance = new ChatRepository();
    }
    return ChatRepository.instance;
  }

  async initialize(context: Context) {
    try {
      this.preferencesStore = await preferences.getPreferences(context, 'chat_data');
    } catch (error) {
      console.error('Failed to initialize preferences:', error);
    }
  }

  // ========== 用户设置 ==========

  async saveSettings(settings: UserSettings): Promise<void> {
    try {
      await this.preferencesStore?.put('settings', JSON.stringify(settings));
      await this.preferencesStore?.flush();
    } catch (error) {
      console.error('Failed to save settings:', error);
    }
  }

  async loadSettings(): Promise<UserSettings> {
    try {
      const data = await this.preferencesStore?.get('settings', '');
      if (data && typeof data === 'string') {
        return JSON.parse(data);
      }
    } catch (error) {
      console.error('Failed to load settings:', error);
    }

    return {
      mode: 'low',
      thinking:'auto',
      maxTokens:4096*10,
      memoryEnabled: false
      // tone: 'professional',
      // language: 'zh-CN'
    };
  }

  // ========== 对话管理 ==========

  async saveCurrentSession(session: ChatSession): Promise<void> {
    try {
      await this.preferencesStore?.put('current_session', JSON.stringify(session));
      await this.preferencesStore?.flush();
    } catch (error) {
      console.error('Failed to save session:', error);
    }
  }

  async loadCurrentSession(): Promise<ChatSession | null> {
    try {
      const data = await this.preferencesStore?.get('current_session', '');
      if (data && typeof data === 'string') {
        return JSON.parse(data);
      }
    } catch (error) {
      console.error('Failed to load session:', error);
    }
    return null;
  }

  async clearCurrentSession(): Promise<void> {
    try {
      await this.preferencesStore?.delete('current_session');
      await this.preferencesStore?.flush();
    } catch (error) {
      console.error('Failed to clear session:', error);
    }
  }

  async saveSessionToHistory(session: ChatSession): Promise<void> {
    try {
      const history = await this.loadSessionHistory();
      history.unshift(session);

      // 只保留最近 20 个会话
      const trimmed = history.slice(0, 20);

      await this.preferencesStore?.put('session_history', JSON.stringify(trimmed));
      await this.preferencesStore?.flush();
    } catch (error) {
      console.error('Failed to save session to history:', error);
    }
  }

  async loadSessionHistory(): Promise<ChatSession[]> {
    try {
      const data = await this.preferencesStore?.get('session_history', '');
      if (data && typeof data === 'string') {
        return JSON.parse(data);
      }
    } catch (error) {
      console.error('Failed to load session history:', error);
    }
    return [];
  }

  // ========== 记忆管理 ==========

  async saveMemory(memory: UserMemory): Promise<void> {
    try {
      const memories = await this.loadMemories();
      memories.push(memory);

      await this.preferencesStore?.put('memories', JSON.stringify(memories));
      await this.preferencesStore?.flush();
    } catch (error) {
      console.error('Failed to save memory:', error);
    }
  }

  async loadMemories(): Promise<UserMemory[]> {
    try {
      const data = await this.preferencesStore?.get('memories', '');
      if (data && typeof data === 'string') {
        return JSON.parse(data);
      }
    } catch (error) {
      console.error('Failed to load memories:', error);
    }
    return [];
  }

  async deleteMemory(id: string): Promise<void> {
    try {
      const memories = await this.loadMemories();
      const filtered = memories.filter(m => m.id !== id);

      await this.preferencesStore?.put('memories', JSON.stringify(filtered));
      await this.preferencesStore?.flush();
    } catch (error) {
      console.error('Failed to delete memory:', error);
    }
  }

  async clearMemories(): Promise<void> {
    try {
      await this.preferencesStore?.delete('memories');
      await this.preferencesStore?.flush();
    } catch (error) {
      console.error('Failed to clear memories:', error);
    }
  }
}

export interface UserSettings {
  // reasoning_effort 限制思考的工作量。减少思考深度可提升速度，思考花费的 token 更少。
  mode?: 'low' |'high' | 'medium' |'minimal';
  // 思考模式
  thinking ?: 'enabled' |'disabled' | 'auto';
  maxTokens : number
  // 记忆功能开关
  memoryEnabled?: boolean;
  // mode: string;
  // tone: 'professional' | 'casual' | 'formal';
  // language: string;
}


