// 消息数据模型
// ============================================
// 定义项目的获取接口
export interface ProjectsContent{
  name: string;
  url: string;
  content: string;
}
// 定义收藏接口响应类型
export interface FavorResponse {
  success: boolean;
  data: Array<ProjectsContent>;
}

// 定义豆包API消息接口
export interface ChatMessage {
  role: string; // "system", "user", "assistant"
  content: string;
}

// 定义豆包API请求接口
export interface ChatRequest {
  model: string;
  messages: ChatMessage[];
}

// 定义豆包API响应中的choices接口
export interface ChatChoice {
  finish_reason: string;
  index: number;
  logprobs: null;
  message: ChatMessage;
}

// 定义豆包API响应中的usage接口
interface cached_tokens {
  cached_tokens: number;
}

interface reasoning_tokens {
  reasoning_tokens: number;
}

export interface ChatUsage {
  completion_tokens: number;
  prompt_tokens: number;
  total_tokens: number;
  prompt_tokens_details: cached_tokens;
  completion_tokens_details: reasoning_tokens
  ;
}

// 定义豆包API响应接口
export interface ChatResponse {
  choices: ChatChoice[];
  created: number;
  id: string;
  model: string;
  service_tier: string;
  object: string;
  usage: ChatUsage;
}


export interface ChatSession {
  id: string;
  title: string;
  messages: sessionMessage[];
  createdAt: number;
  updatedAt: number;
}
export interface sessionMessage {
  sessionID: string;
  id: string;
  messages: ChatMessage | null;
}

// 定义发送消息返回结果类型
export interface sendResult {
  success: boolean;
  message?: string; // 可选的错误消息
}