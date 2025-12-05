// 主入口页面 - 导航到聊天页面
// ============================================

import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State message: string = '正在加载...';

  aboutToAppear() {
    // 延迟跳转到聊天页面
    setTimeout(() => {
      router.replaceUrl({ url: 'pages/ChatPage' });
    }, 500);
  }

  build() {
    Column() {
      Image($r('app.media.icon'))
        .width(100)
        .height(100)
        .margin({ bottom: 20 })

      Text('Harmony AI')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2937')

      Text(this.message)
        .fontSize(14)
        .fontColor('#6B7280')
        .margin({ top: 10 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F5F7FA')
  }
}
