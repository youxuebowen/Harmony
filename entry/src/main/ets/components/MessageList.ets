// 消息列表组件 - 优化版
// ============================================
import { sessionMessage } from '../data/ChatMessage';
// import { Scroller, FontWeight, TextAlign, Edge, FlexAlign, Alignment, TextOverflow } from '@kit.ArkUI';
// import Color from '@ohos.arkui.color';

@Component
export struct MessageList {
  @Prop messages: sessionMessage[] = [];
  private scroller: Scroller = new Scroller();
  private autoScrollToBottom: boolean = false;  // 禁用自动滚动到底部，让消息靠上显示

  // 自动滚动到底部功能已禁用，让消息自然靠上显示
  // onPageShow() {
  //   if (this.autoScrollToBottom && this.messages.length > 0) {
  //     setTimeout(() => {
  //       this.scroller.scrollEdge(Edge.Bottom);
  //     }, 100);
  //   }
  // }

  // 格式化时间显示
  private formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
  }

  build() {
    Scroll(this.scroller) {
      Column() {
        // 空状态处理
        if (this.messages.length === 0) {
          Column() {
            Text('开始对话吧！')
              .fontSize(18)
              .fontColor('#9CA3AF')
              .margin({ bottom: 8 })
            Text('向AI提问任何问题，获取智能回答')
              .fontSize(14)
              .fontColor('#D1D5DB')
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          // .alignItems(Alignment.Center)
        } else {
          ForEach(this.messages, (message: sessionMessage, index: number) => {
            if (message.messages) {
              // 消息时间戳
              Row() {
                Text(this.formatTime(Number(message.id)))
                  .fontSize(12)
                  .fontColor('#9CA3AF')
                  .padding( 12)
                  .backgroundColor('#E5E7EB')
                  .borderRadius(10)
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
              .margin({ bottom: 8 })

              if (message.messages.role === 'user') {
                // 用户消息
                Row() {
                  Blank()
                  Column() {
                    Text(message.messages.content)
                      .fontSize(16)
                      .fontColor('#FFFFFF')
                      .backgroundColor('#3B82F6')
                      .textAlign(TextAlign.Start)
                      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                      .borderRadius(18)
                      // .borderBottomRightRadius(6)
                      .width('auto')
                      // .maxWidth('75%')  // 使用maxWidth代替固定width，实现自适应
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .lineHeight(22)
                  }
                  .margin({ right: 16, bottom: 16 })
                }
                .width('100%')
                // .alignItems(Alignment.Bottom)
              } else if (message.messages.role === 'assistant') {
                // 助手消息
                Row() {
                  // AI头像
                  Column() {
                    Text('AI')
                      .fontSize(14)
                      .fontColor(Color.White)
                      .fontWeight(FontWeight.Bold)
                      .width(40)
                      .height(40)
                      .borderRadius(20)
                      .textAlign(TextAlign.Center)
                      .backgroundColor('#3B82F6')
                      .shadow({
                        radius: 4,
                        color: '#20000000',
                        offsetX: 0,
                        offsetY: 2
                      })
                  }
                  .margin({ left: 16, right: 12 })
                  
                  // 助手消息内容
                  Column() {
                    Text(message.messages.content)
                      .fontSize(16)
                      .fontColor('#374151')
                      .backgroundColor(Color.White)
                      .textAlign(TextAlign.Start)
                      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                      .borderRadius(18)
                      // .borderBottomLeftRadius(6)
                      // .width('auto')
                      .width('80%')  // 使用maxWidth代替固定width，实现自适应
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .lineHeight(22)
                      .shadow({
                        radius: 4,
                        color: '#20000000',
                        offsetX: 0,
                        offsetY: 2
                      })
                  }
                  .margin({ right: 16, bottom: 16 })
                  
                  Blank()
                }
                .width('100%')
                // .alignItems(Alignment.Bottom)
              }
            }
          })
        }
        
        // 底部空白区域
        Blank()
          .height(20)
      }
      .width('100%')
      .padding({ top: 16 })
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor('#F9FAFB')
  }
}