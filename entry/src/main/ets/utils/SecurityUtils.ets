// 安全工具类
// ============================================

import { SafetyCheckResult } from '../model/LLMRequest';

export class SecurityUtils {
  private static forbiddenKeywords: string[] = [
    '制造武器', '自杀方法', '自残', '儿童色情', '恐怖主义',
    '制造炸弹', '黑客攻击', '信用卡盗刷', '毒品制作'
  ];

  // private static sensitivePatterns: Array<{ pattern: RegExp; name: string }> = [
  //   { pattern: new RegExp('\\d{17}[\\dXx]'), name: '身份证号' },
  //   { pattern: new RegExp('\\d{16,19}'), name: '银行卡号' },
  //   { pattern: new RegExp('^1[3-9]\\d{9}$'), name: '手机号' },
  //   { pattern: new RegExp('[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}'), name: '邮箱' },
  // ];
  static checkSafety(text: string): SafetyCheckResult {
    const lowerText = text.toLowerCase();

    // 检查禁止关键词
    for (const keyword of SecurityUtils.forbiddenKeywords) {
      if (lowerText.includes(keyword.toLowerCase())) {
        return {
          safe: false,
          message: '抱歉，我无法协助这个请求。但我可以提供相关的安全信息、替代方案或一般性知识。',
          category: 'forbidden_content',
          matched: keyword
        };
      }
    }

    // 检查敏感信息
    // for (const { pattern, name } of this.sensitivePatterns) {
    //   if (pattern.test(text)) {
    //     return {
    //       safe: false,
    //       message: '检测到您的消息可能包含敏感个人信息。为保护您的隐私安全，建议不要发送此类信息。',
    //       category: 'sensitive_data',
    //       matched: name
    //     };
    //   }
    // }

    return { safe: true };
  }

  static sanitize(text: string): string {
    let sanitized = text;

    // 脱敏身份证号
    sanitized = sanitized.replace(/(\d{6})\d{8}([\dxX]{4})/g, '$1********$2');

    // 脱敏银行卡号
    sanitized = sanitized.replace(/(\d{4})\d{8,12}(\d{4})/g, '$1********$2');

    // 脱敏手机号
    sanitized = sanitized.replace(/(1[3-9]\d)\d{4}(\d{4})/g, '$1****$2');

    return sanitized;
  }
}