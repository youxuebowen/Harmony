// ============================================
// entry/src/main/ets/network/HttpClient.ets
// HTTP 客户端封装 - 适配豆包API
// ============================================

import http from '@ohos.net.http';
import { JSON } from '@kit.ArkTS';
import { messageContent } from '../model/ChatMessage';
import { BusinessError } from '@kit.BasicServicesKit';


// 定义更通用的Headers接口以支持Authorization等自定义头部
export interface RequestHeaders {
  'Content-Type': string;
  'Authorization': string;
  key?: string;
}
interface url{
  url:string
}
// 定义多模态内容项接口
export interface MessageContentItem {
  type: 'text' | 'image_url';
  text?: string;
  image_url?:url;
}
export interface MessageContent{
  content : string
}
// 定义消息接口
export interface Message {
  role: 'user' | 'assistant' | 'system';
  content: MessageContent | string;
}

// 定义请求体接口
export interface RequestBody {
  model: string;
  max_completion_tokens: number;
  messages: Message[];
  // reasoning_effort ?: 'low' | 'medium' | 'high';
  thinking  ?: 'enabled' |'disabled' | 'auto';
  stream?: boolean;
}

export interface DoubaoRequest extends RequestBody {}

// 定义豆包API响应相关接口

// 响应消息接口
export interface ResponseMessage {
  role: string;
  content: string;
}

// 响应选择项接口
export interface ResponseChoice {
  message: ResponseMessage;
  finish_reason: string;
  index: number;
}

// 响应使用统计接口
export interface ResponseUsage {
  prompt_tokens: number;
  completion_tokens: number;
  total_tokens: number;
}
interface error{
  message: string;
  type?: string;
  code?: string;
}
// 完整的豆包API响应接口
export interface DoubaoResponse {
  id: string;
  object: string;
  created: number;
  model: string;
  choices: ResponseChoice[];
  usage?: ResponseUsage;
  error?: error;
}

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

export interface ChatOptions {
  mode?: 'low' |'high' | 'medium' |'minimal';
  maxTokens?: number;
  thinking?: 'enabled' |'disabled' | 'auto';
}


export class HttpClient {
  private baseUrl: string = '';
  private timeout: number = 30000;

  /**
   * 设置基础URL
   */
  setBaseUrl(url: string) {
    this.baseUrl = url;
  }

  /**
   * 设置请求超时时间
   */
  setTimeout(timeout: number) {
    this.timeout = timeout;
  }

  /**
   * 发送POST请求到豆包API
   * @param url API端点路径
   * @param data 请求体数据，可以是DoubaoRequest或其他格式
   * @param headers 自定义请求头部，包括Authorization等
   * @returns 响应数据
   */
  async post<T, D>(url: string, data: DoubaoRequest, headers?: RequestHeaders): Promise<T> {
    const httpRequest = http.createHttp();

    try {
      // 添加日志打印，查看运行时变量值
      console.log('HTTP请求URL:', url);
      console.log('HTTP请求头:', JSON.stringify(headers));
      console.log('HTTP请求数据:', JSON.stringify(data));
      console.log('超时设置:', this.timeout);

      // 组合基础URL和端点路径
      const fullUrl = this.baseUrl ? `${this.baseUrl}${url}` : url;
      console.log('组合后的完整URL:', fullUrl);
      
      // // 构建请求参数
      // const requestOptions = {
      //   method: http.RequestMethod.POST,
      //   header: headers,
      //   extraData: JSON.stringify(data),
      //   expectDataType: http.HttpDataType.STRING,
      //   connectTimeout: this.timeout,
      //   readTimeout: this.timeout
      // };
      //
      // console.log('请求选项:', JSON.stringify(requestOptions));
      console.log('开始发送HTTP请求...');
      
      // 使用Promise包装httpRequest.request，确保异步处理正确
      const response = await new Promise<http.HttpResponse>((resolve, reject) => {
        httpRequest.request(
          fullUrl,
          // "http://8.130.154.167:18080/api/v2/get_favor",
          {
            method: http.RequestMethod.POST,
            header: {
              'Content-Type': 'application/json',
              "Authorization":"Bearer fefeb982-8d1a-428a-805f-f0e4318546f6"

            },
            extraData: JSON.stringify(data),
            // expectDataType: http.HttpDataType.STRING,
            connectTimeout: this.timeout,
            readTimeout: this.timeout
          },


          (err: BusinessError, data: http.HttpResponse) => {
            if (!err) {
              // data.result为HTTP响应内容，可根据业务需要进行解析。
              console.info('Result:' + JSON.stringify(data.result));
              console.info('code:' + JSON.stringify(data.responseCode));
              // data.header为HTTP响应头，可根据业务需要进行解析。
              console.info('header:' + JSON.stringify(data.header));
              console.info('cookies:' + JSON.stringify(data.cookies)); // 8+
              // 当该请求使用完毕时，调用destroy方法主动销毁。
              httpRequest.destroy();
            } else {
              console.error('error:' + JSON.stringify(err));
              // 取消订阅HTTP响应头事件。
              httpRequest.off('headersReceive');
              // 当该请求使用完毕时，调用destroy方法主动销毁。
              httpRequest.destroy();
            }
          }



        );
      });
      
      // 打印响应信息（如果请求成功到达这里）
      console.log('HTTP请求成功，收到响应');
      console.log('HTTP响应状态码:', response.responseCode);
      console.log('HTTP响应结果:', response.result);

      // 检查响应状态
      if (response.responseCode >= 200 && response.responseCode < 300) {
        const result = response.result as string;
        try {
          return JSON.parse(result) as T;
        } catch (parseError) {
          console.error('响应解析失败:', parseError);
          throw new Error(`响应格式错误: ${result}`);
        }
      } else {
        throw new Error(`API请求失败: ${response.responseCode} - ${response.result}`);
      }
    } catch (error) {
      // 捕获所有可能的错误，包括请求失败、超时等
      console.error('HTTP请求过程中发生错误:', error);
      console.error('错误类型:', typeof error);
      console.error('错误详情:', JSON.stringify(error, null, 2));
      
      // 详细分析错误原因
      if (error instanceof Error) {
        console.error('错误消息:', error.message);
        console.error('错误堆栈:', error.stack);
        throw new Error(`HTTP请求失败: ${error.message}`);
      } else if (typeof error === 'object' && error !== null) {
        // // 处理可能的网络错误对象
        // if ('code' in error) {
        //   console.error('错误代码:', error.code);
        // }
        // if ('message' in error) {
        //   console.error('错误描述:', error.message);
        // }
        throw new Error(`HTTP请求失败: ${JSON.stringify(error)}`);
      } else {
        throw new Error(`HTTP请求失败: 未知错误类型`);
      }
    } finally {
      console.log('HTTP请求结束，释放资源');
      httpRequest.destroy();
    }
  }

  /**
   * 发送豆包API特定的聊天请求
   * @param endpoint API端点路径
   * @param requestData 豆包API请求数据
   * @param apiKey API密钥
   * @returns 豆包API响应
   */
  async sendChatRequest(endpoint: string, requestData: DoubaoRequest, apiKey: string): Promise<DoubaoResponse> {
    const headers = this.createAuthHeaders(apiKey);
    return this.post<DoubaoResponse, DoubaoRequest>(endpoint, requestData, headers);
  }

  /**
   * 从豆包API响应中提取助手的回复内容
   * @param response 豆包API响应
   * @returns 助手的回复内容，如果没有找到则返回空字符串
   */
  extractAssistantResponse(response: DoubaoResponse): string {
    if (response && response.choices && response.choices.length > 0) {
      const firstChoice = response.choices[0];
      if (firstChoice.message && firstChoice.message.content) {
        return firstChoice.message.content;
      }
    }
    return '';
  }

  /**
   * 从豆包API响应中提取完成原因
   * @param response 豆包API响应
   * @returns 完成原因
   */
  extractFinishReason(response: DoubaoResponse): string {
    if (response && response.choices && response.choices.length > 0) {
      return response.choices[0].finish_reason || 'unknown';
    }
    return 'unknown';
  }

  /**
   * 从豆包API响应中提取令牌使用统计
   * @param response 豆包API响应
   * @returns 使用统计对象
   */
  extractUsageStats(response: DoubaoResponse): ResponseUsage | null {
    return response.usage || null;
  }

  /**
   * 检查响应是否包含错误
   * @param response 可能的错误响应
   * @returns 是否包含错误
   */
  // isErrorResponse(response: any): response is DoubaoResponse {
  //   return response && response.error && typeof response.error === 'object';
  // }

  /**
   * 从错误响应中提取错误消息
   * @param errorResponse 错误响应
   * @returns 错误消息
   */
  extractErrorMessage(errorResponse: DoubaoResponse): string {
    if (errorResponse.error && errorResponse.error.message) {
      return errorResponse.error.message;
    }
    return '';
  }

  /**
   * 创建带Bearer认证的头部
   * @param apiKey API密钥
   * @returns 包含Authorization的请求头部
   */
  createAuthHeaders(apiKey: string): RequestHeaders {
    return {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${apiKey}`
    };
  }

  /**
   * 创建文本内容项
   * @param text 文本内容
   * @returns 文本类型的内容项
   */
  createTextContentItem(text: string): MessageContent {
    return {
      content: text
    };
  }

  /**
   * 创建图片内容项
   * @param imageUrl 图片URL
   * @returns 图片类型的内容项
   */
  createImageContentItem(imageUrl: string): MessageContentItem {
    return {
      type: 'image_url',
      image_url: {
        url: imageUrl
      }
    };
  }

  /**
   * 创建多模态消息（包含文本和图片）
   * @param role 消息角色
   * @param contentItems 内容项数组
   * @returns 多模态消息对象
   */
  createMultimodalMessage(
    role: 'user' | 'assistant' | 'system',
    content: MessageContent
  ): Message {
    return {
      role,
      content: content.content as string
    };
  }

  /**
   * 将ResponseMessage转换为Message
   * @param responseMessage 响应消息
   * @returns 消息对象
   */
  convertResponseMessageToMessage(responseMessage: ResponseMessage): Message {
    return {
      role: responseMessage.role as 'user' | 'assistant' | 'system',
      content: responseMessage.content
    };
  }

  /**
   * 将ResponseMessage数组转换为Message数组
   * @param responseMessages 响应消息数组
   * @returns 消息对象数组
   */
  // convertResponseMessagesToMessages(responseMessages: ResponseMessage[]): Message[] {
  //   return responseMessages.map(responseMessage => this.convertResponseMessageToMessage(responseMessage));
  // }

  /**
   * 创建豆包API请求体
   * @param model 模型名称
   * @param messages 消息数组
   * @param maxTokens 最大完成令牌数
   * @param reasoningEffort 推理强度
   * @returns 豆包API请求体
   */
  // createDoubaoRequest(
  //   model: string,
  //   messages: Message[],
  //   maxTokens: number,
  //   reasoningEffort: string
  // ): DoubaoRequest {
  //   return {
  //     model,
  //     messages,
  //     max_completion_tokens: maxTokens,
  //     reasoning_effort: reasoningEffort
  //   };
  // }

  /**
   * 获取收藏数据
   * @returns 收藏数据响应
   * async 关键字表示这是一个异步方法
   * 返回类型为 Promise<FavorResponse> ，表示该方法会异步返回 FavorResponse 类型的数据
   */

  async getFavor(): Promise<FavorResponse> {
    const url = 'http://8.130.154.167:18080/api/v2/get_favor';

    let httpClient = http.createHttp();

    let result = await httpClient.request(url, {
      method: http.RequestMethod.GET,
    });

    return JSON.parse(result.result as string) as FavorResponse;
  }

}