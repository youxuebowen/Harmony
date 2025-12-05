// 消息数据模型
// ============================================
//定义消息接口
export interface Message {
  id: string;
  sessionID:string;
  role: 'user' | 'assistant' | 'system';
  content: string;
  timestamp: number;
  // metadata?: MessageMetadata;

}
//
export interface messageContent {
  role: 'user' | 'assistant' | 'system';
  content: string;
}

// 发送消息后的返回
export interface sendMessage {
  success: boolean,
  message: string
}

// export interface MessageMetadata {
//   tokens?: number;
//   temperature?: number;
//   modelVersion?: string;
//   flagged?: boolean;
//   regenerated?: boolean;
// }

export interface ChatSession {
  id: string;
  title: string;
  messages: Message[];
  createdAt: number;
  updatedAt: number;
}