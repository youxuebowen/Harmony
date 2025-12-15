// HttpClientTest.ets - 用于测试getFavor接口
import { HttpClient } from './HttpClient';

// 创建HttpClient实例
const httpClient = new HttpClient();

// 测试getFavor方法
async function testGetFavor() {
  try {
    console.log('开始测试getFavor接口...');
    const result = await httpClient.getFavor();
    console.log('测试成功，响应结果:', JSON.stringify(result, null, 2));
  } catch (error) {
    console.error('测试失败，错误信息:', error);
  }
}

// 执行测试
testGetFavor();