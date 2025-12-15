// ============================================
// entry/src/main/ets/network/HttpClient.ets
// HTTP 客户端封装 - 适配豆包API
// ============================================

import http from '@ohos.net.http';
import { JSON } from '@kit.ArkTS';
import { FavorResponse, ChatMessage, ChatRequest, ChatResponse } from '../data/ChatMessage';
import promptAction from '@ohos.promptAction';

export class HttpClient {
  /**
   * 获取收藏数据
   * @returns 收藏数据响应
   * async 关键字表示这是一个异步方法
   * 返回类型为 Promise<FavorResponse> ，表示该方法会异步返回 FavorResponse 类型的数据
   */

  async getFavor(): Promise<FavorResponse> {
    const url = 'http://8.130.154.167:18080/api/v2/get_favor';

    let httpClient = http.createHttp();


    try {
      let result = await httpClient.request(url, {
        method: http.RequestMethod.GET,
      });
      return JSON.parse(result.result as string) as FavorResponse;
    } catch (error) {
      console.error('获取收藏数据失败:', error);
      // 显示toast提示获取失败
      promptAction.showToast({
        message: '获取收藏数据失败',
        duration: 2000
      });
      // 返回默认的失败响应
      return { success: false, data: [] };
    }


  }

  /**
   * 调用豆包API进行聊天对话
   * @param messages 聊天消息数组
   * @param model 使用的模型名称
   * @param apiKey API密钥
   * @returns 豆包API的响应
   */
  async chatCompletion(messages: ChatMessage[], model: string = "doubao-seed-1-6-251015", apiKey: string): Promise<ChatResponse | null> {
    // 使用豆包官方API URL
    const url = 'https://ark.cn-beijing.volces.com/api/v3/chat/completions';

    
    let httpClient = http.createHttp();
    
    try {
      const requestBody: ChatRequest = {
        model: model,
        messages: messages
      };
      
      let result = await httpClient.request(url, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${apiKey}`
        },
        extraData: JSON.stringify(requestBody)
      });
      
      if (result.responseCode === 200) {
        return JSON.parse(result.result as string) as ChatResponse;
      } else {
        throw new Error(`HTTP error! Status: ${result.responseCode}`);
      }
    } catch (error) {
      console.error('豆包API调用失败:', error);
      // 显示toast提示调用失败
      promptAction.showToast({
        message: '豆包API调用失败',
        duration: 2000
      });
      return null;
    } finally {
      // 关闭HTTP客户端
      httpClient.destroy();
    }
  }
}