// 用户记忆模型
// ============================================

export interface UserMemory {
  id: string;
  key: string;
  value: string;
  category: 'preference' | 'fact' | 'habit';
  createdAt: number;
  updatedAt: number;
}
