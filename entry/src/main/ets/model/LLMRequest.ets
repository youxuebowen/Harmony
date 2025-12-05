// API 请求/响应模型 - 豆包 API 适配
// ============================================

// 基础消息接口
export interface BaseMessage {
  role: string;
  content: string | MessageContent[];
}
interface url{
  url: string;
}
// 消息内容项接口（用于多模态）
export interface MessageContent {
  type: 'text' | 'image_url';
  text?: string;
  image_url?: url;
}

// 豆包API请求接口
export interface LLMRequest {
  model: string;
  messages: BaseMessage[];
  max_completion_tokens?: number;
  reasoning_effort?: 'low' | 'medium' | 'high';
}

// 豆包API响应中的消息接口
interface ResponseMessage {
  role: string;
  content: string;
  reasoning_content?: string | null;
}

// 豆包API响应中的选择项接口
interface ResponseChoice {
  index:number;
  finish_reason: string;
  delta : ResponseMessage;
}

// 豆包API响应中的使用情况接口
interface ResponseUsage {
  // 本次请求消耗的总 token 数量（输入 + 输出）。
  total_tokens?: number;
  // 输入给模型处理的内容 token 数量。
  prompt_tokens?: number;
  // 模型输出内容花费的 token
  completion_tokens?: number;
  // 输入给模型处理的内容 token 数量。
}

// 豆包API完整响应接口
interface DoubaoResponse {
  id?: string;
  model?: string;
  created?: number;
  object?: string;
  choices: ResponseChoice[];
  usage?: ResponseUsage;
}

// 应用使用的响应接口
export interface LLMResponse {
  content: string;
  tokens: number;
  modelVersion: string;
  finishReason: 'stop' | 'length' | 'content_filter' | string;
}

export interface SafetyCheckResult {
  safe: boolean;
  message?: string;
  category?: string;
  matched?: string;
}
