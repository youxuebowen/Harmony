// 记忆管理视图模型
// ============================================

import { UserMemory } from '../model/UserMemory';
import { ChatRepository } from '../data/ChatRepository';

export class MemoryViewModel {
  private repository: ChatRepository;

  constructor() {
    this.repository = ChatRepository.getInstance();
  }

  async getAllMemories(): Promise<UserMemory[]> {
    return await this.repository.loadMemories();
  }

  async addMemory(key: string, value: string, category: 'preference' | 'fact' | 'habit') {
    const memory: UserMemory = {
      id: Date.now().toString(),
      key: key,
      value: value,
      category: category,
      createdAt: Date.now(),
      updatedAt: Date.now()
    };

    await this.repository.saveMemory(memory);
  }

  async deleteMemory(id: string) {
    await this.repository.deleteMemory(id);
  }

  async clearAll() {
    await this.repository.clearMemories();
  }
}