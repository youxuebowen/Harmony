// ============================================
// entry/src/main/ets/network/DoubaoApiService.ets
// AI API 服务封装 - 豆包 API
// ============================================

import { FavorResponse, ChatMessage, ChatResponse } from '../data/ChatMessage';
import {HttpClient} from './HttpClient'

export class DoubaoApiService {
  private apiKey: string = "fefeb982-8d1a-428a-805f-f0e4318546f6";
  private systemPrompt: string = `你是 "Harmony AI 助手"，是一名礼貌、可靠、尊重用户隐私的中文智能对话助理。
  你的任务是：提供清晰、有帮助、经过审慎思考的回答，并始终确保安全、合法、可信。
  【核心行为原则】
  1. 回答风格：默认使用"简洁 + 结构化"的回答方式。每条回答开头给出简洁结果或最直接的答案（1–2 行）。
  2. 表达方式：始终使用清晰可信的语气。如果事实不确定，明确说"我不确定"或"资料有限，我推测……"。
  3. 澄清原则：如果用户的问题可能含糊或有歧义，提出 1 个简短澄清问题。
  4. 语言：默认用简体中文回答。"`;
  async chatAI(messages:ChatMessage[]):Promise<ChatResponse>{
    // 创建包含系统提示的完整消息数组
    const fullMessages: ChatMessage[] = [
      {
        role: "system",
        content: this.systemPrompt
      },
      ...messages // 添加用户传入的消息
    ];
    try{
      const httpClient = new HttpClient();
      const response = await httpClient.chatCompletion(fullMessages, "doubao-seed-1-6-251015", this.apiKey);
      
      // 检查响应是否为null
      if (!response) {
        throw new Error('API返回了空响应');
      }
      
      return response;
    }catch (error){
      console.error('对话失败:', error);
      throw new Error(String(error)); // ArkTS 100% 不报错
    }

  }
  /**
   * 获取收藏数据
   * @returns 收藏数据响应
   */
  async getFavor(): Promise<FavorResponse> {
    try {
      const httpClient = new HttpClient();
      
      // 调用HttpClient的getFavor方法获取收藏数据
      const response = await httpClient.getFavor();
      
      return response;
    } catch (error) {
      console.error('获取收藏数据失败:', error);
      throw new Error('获取收藏数据失败，请稍后重试');
    }
  }
}
