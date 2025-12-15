import router from '@ohos.router';
import { FavorResponse, ProjectsContent } from '../data/ChatMessage';
import { ChatViewModel } from '../viewmodel/ChatViewModel';

@Entry
@Component
struct FavoritePage {
  @State favorData: Array<ProjectsContent> = [];
  @State isLoading: boolean = true;
  @State selectedItems: Set<string> = new Set();
  private viewModel: ChatViewModel = new ChatViewModel();

  aboutToAppear() {
    this.loadFavoriteData();
  }

  // 加载收藏数据
  async loadFavoriteData() {
    try {
      this.isLoading = true;
      const response: FavorResponse = await this.viewModel.getFavor() as FavorResponse;
      if (response.success && response.data) {
        this.favorData = response.data;
      }
    } catch (error) {
      console.error('加载收藏数据失败:', error);
      // 可以添加错误提示
    } finally {
      this.isLoading = false;
    }
  }

  // 切换项目选择状态
  toggleItemSelection(item: ProjectsContent) {
    if (this.selectedItems.has(item.url)) {
      this.selectedItems.delete(item.url);
    } else {
      this.selectedItems.add(item.url);
    }
  }

  // 跳转到项目URL
  navigateToUrl(url: string) {
    // 这里可以实现打开URL的逻辑
    console.log('打开URL:', url);
  }
  handleClearChat() {
    AlertDialog.show({
      title: '确认发送',
      message: '确定要发送选中的项目？',
      autoCancel: true,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '确定',
        fontColor: '#E74C3C',
        action: () => {
          // this.viewModel.clearMessages();

        }
      }
    });
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        // 返回按钮
        Button({ type: ButtonType.Normal })
          .width(40)
          .height(40)
          .borderRadius(20)
          .backgroundColor('#3B82F6')
          .backgroundImage($r('app.media.ic_back'))
          .backgroundImageSize({ width: 20, height: 20 })
          .backgroundImagePosition({ x: 10, y: 10 })
        .onClick(() => {
          router.back();
        })

        // 标题
        Text('收藏项目')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 12 })
        // 项目数量提示
        Text(`${this.favorData.length}个项目`)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .margin({ top: 12, bottom: 12 })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#3B82F6')
      .alignItems(VerticalAlign.Center)



      // 收藏项目列表
      if (this.isLoading) {
        // 加载中提示
        Progress({
          value : 30,
          type: ProgressType.Linear })
          .width(40)
          .height(40)
          .margin({ top: 50 })
      } else if (this.favorData.length === 0) {
        // 空数据提示
        Text('暂无收藏项目')
          .fontSize(16)
          .fontColor('#999999')
          .margin({ top: 50 })
      } else {
        // 项目列表
        List({
          // space: 1,
          scroller: new Scroller()
        })

        {

          ForEach(this.favorData, (item: ProjectsContent) => {
            ListItem() {
              // 显示框容器
              Row()
              {
                // 左侧项目内容显示框
                Column() {
                  // 项目名称
                  Text(item.name)
                    .fontSize(16)
                    .textAlign(TextAlign.Start)  // 靠左对齐
                    .fontWeight(FontWeight.Lighter)
                    .margin({ bottom: 4 })
                    .width('100%')

                  // 项目内容预览
                  Text(item.url)
                    .fontSize(14)
                    .fontColor('#666666')
                    .textAlign(TextAlign.Start)
                    .maxLines(3)
                    .width('100%')

                }
                .padding(2)
                .backgroundColor('#FFFFFF')
                .borderRadius(12)
                .width('95%')
                // .flexGrow(1)  // 让内容框占据主要空间
                // 右侧复选框
                Checkbox()
                  .width(24)
                  .height(24)
                  .select(this.selectedItems.has(item.url))
                  .onChange((isSelected: boolean) => {
                    // 选中时显示确认框
                    if (isSelected) {
                      this.handleClearChat();
                    } else {
                      this.toggleItemSelection(item);
                    }
                  })
                  // .flexGrow(1)
                  .margin({ left: 0, right: 12 })  // 与内容框保持间距，避免紧跟在文字后面




              }
              .padding(12)
              .borderRadius(12)
              .backgroundColor('#0a0808ff')
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              // .alignItems(VerticalAlign.Center)  // 垂直居中对齐
            }
          }, (item: ProjectsContent) => item.url)
        }
        .padding({ top: 0, bottom: 16 })
      }
    }
    .backgroundColor('#F5F5F5')
    // .height('100%')
    .width('100%')
    .alignItems(HorizontalAlign.Center)   // ❤️ 正确
    // .alignItems(VerticalAlign.Center)
    // .alignItems(VerticalAlign.Center)
  }
}
