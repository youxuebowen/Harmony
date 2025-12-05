// HttpClient测试文件
import { HttpClient } from '../network/HttpClient';

// 创建测试函数
export async function testHttpClient() {
  try {
    console.log('开始测试HttpClient...');
    
    const httpClient = new HttpClient();
    httpClient.setBaseUrl('https://api.doubao.com');
    httpClient.setTimeout(60000);
    
    // 简单的测试请求
    const testRequest = {
      model: 'doubao-seed-1-6-251015',
      max_completion_tokens: 100,
      messages: [
        {
          role: 'system',
          content: [
            {
              type: 'text',
              text: '你是一个测试助手'
            }
          ]
        },
        {
          role: 'user',
          content: [
            {
              type: 'text',
              text: '你好，测试一下'
            }
          ]
        }
      ],
      thinking: 'auto',
      stream: false
    };
    
    const headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer fefeb982-8d1a-428a-805f-f0e4318546f6'
    };
    
    console.log('发送测试请求...');
    const response = await httpClient.post(
      '/api/v3/chat/completions',
      testRequest,
      headers
    );
    
    console.log('测试请求成功！');
    console.log('响应结果:', JSON.stringify(response));
    
  } catch (error) {
    console.error('测试请求失败:', error);
  }
}

// 执行测试
testHttpClient();
