// 聊天气泡组件
// ============================================

import { Message } from '../model/ChatMessage';

@Component
export struct ChatBubble {
  @Prop message: Message;
  onReport?: () => void;

  build() {
    Row() {
      if (this.message.role === 'assistant') {
        Row() {
          Text('AI')
            .fontSize(14)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }
        .width(32)
        .height(32)
        .borderRadius(16)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#3B82F6')
        .margin({ right: 8 })
      }

      Column({ space: 8 }) {
        Column() {
          Text(this.message.content)
            .fontSize(15)
            .lineHeight(22)
            .fontColor(this.message.role === 'user' ? Color.White : '#1F2937')
        }
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .borderRadius(16)
        .backgroundColor(this.message.role === 'user' ? '#10B981' : Color.White)
        .shadow(this.message.role === 'assistant' ? {
          radius: 4,
          color: '#10000000'
        } : undefined)

        Row({ space: 12 }) {
          Text(this.formatTime(this.message.timestamp))
            .fontSize(12)
            .fontColor('#9CA3AF')

          if (this.message.role === 'assistant') {
            Text('举报')
              .fontSize(12)
              .fontColor('#9CA3AF')
              .onClick(() => {
                if (this.onReport) {
                  this.onReport();
                }
              })

            Text('朗读')
              .fontSize(12)
              .fontColor('#9CA3AF')
              .onClick(() => {
                // TTS 功能
              })
          }
        }
      }
      .alignItems(this.message.role === 'user' ? HorizontalAlign.End : HorizontalAlign.Start)
      .layoutWeight(1)

      if (this.message.role === 'user') {
        Row() {
          Text('You')
            .fontSize(14)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }
        .width(32)
        .height(32)
        .borderRadius(16)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#10B981')
        .margin({ left: 8 })
      }
    }
    .width('100%')
    .justifyContent(this.message.role === 'user' ? FlexAlign.End : FlexAlign.Start)
  }

  formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
  }
}

