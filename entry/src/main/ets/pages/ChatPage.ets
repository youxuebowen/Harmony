// 聊天主页面 - 完整 ArkUI 实现
// ============================================

import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
// import { AlertDialog, DialogAlignment } from '@ohos.ui.dialog';
// import { Edge } from '@ohos.display';
// import { Color } from '@ohos.util.color';
// import { FontWeight } from '@ohos.text';
import { ChatViewModel } from '../viewmodel/ChatViewModel';
import { Message } from '../model/ChatMessage';
import { ChatBubble } from '../components/ChatBubble';
import { InputBar } from '../components/InputBar';

@Entry
@Component
struct ChatPage {
  @State messages: Message[] = [];
  @State isLoading: boolean = false;
  @State showSettings: boolean = false;
  @State currentMode: string = 'low';
  @State memoryEnabled: boolean = false;

  private viewModel: ChatViewModel = new ChatViewModel();
  private scroller: Scroller = new Scroller();

  aboutToAppear() {
    this.loadSettings();
  }

  async loadSettings() {
    const settings = await this.viewModel.loadPreferences();
    // 当状态未确定时，可以让其强制认为是某种类型
    this.currentMode = settings.mode as string;
    this.memoryEnabled = settings.memoryEnabled as boolean;
  }
  // 发送消息，异步操作
  async handleSendMessage(content: string): Promise<void> {
    if (!content.trim() || this.isLoading) {
      return;
    }

    this.isLoading = true;

    try {
      const result = await this.viewModel.sendMessage(content);

      if (result.success) {
        // 获取最新的的聊天列表
        this.messages = this.viewModel.getMessages();
        // 强制聊天框滚动到最底部
        this.scrollToBottom();
      } else {
        this.messages = this.viewModel.getMessages();
        // 强制聊天框滚动到最底部
        this.scrollToBottom();
        promptAction.showToast({
          message: result.message || '发送失败',
          duration: 2000
        });
      }
    } catch (error) {
      promptAction.showToast({
        message: '发生错误，请重试',
        duration: 2000
      });
    } finally {
      this.isLoading = false;
    }
  }

  async handleRegenerate(): Promise<void> {
    if (this.isLoading || this.messages.length < 2) {
      return;
    }

    this.isLoading = true;

    try {
      const result = await this.viewModel.regenerateLastResponse();
      if (result) {
        this.messages = this.viewModel.getMessages();
      }
    } finally {
      this.isLoading = false;
    }
  }

  // 删除聊天按钮
  handleClearChat() {
    AlertDialog.show({
      title: '确认清空',
      message: '确定要清空当前对话吗？',
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
          this.viewModel.clearMessages();
          this.messages = [];
        }
      }
    });
  }

  handleExport() {
    this.viewModel.exportConversation();
    promptAction.showToast({
      message: '对话已导出',
      duration: 2000
    });
  }

  scrollToBottom() {
    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom);
    }, 100);
  }

  build() {
    Column() {
      // 顶部导航栏
      this.buildHeader()

      // 设置面板
      if (this.showSettings) {
        this.buildSettingsPanel()
      }

      // 消息列表区域
      if (this.messages.length === 0) {
        this.buildWelcomeScreen()
      } else {
        this.buildMessageList()
      }

      // 底部输入栏
      InputBar({
        isLoading: this.isLoading,
        showRegenerate: this.messages.length > 0,
        onSend: (text: string) => this.handleSendMessage(text),
        onRegenerate: () => this.handleRegenerate(),
        currentMode: this.currentMode,
        memoryEnabled: this.memoryEnabled
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  @Builder
  buildHeader() {
    Row() {
      Row() {
        Image($r('app.media.icon'))
          .width(40)
          .height(40)
          .borderRadius(8)

        Column({ space: 2 }) {
          Text('Harmony AI 助理')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2937')

          Text('安全 · 可靠 · 智能')
            .fontSize(12)
            .fontColor('#6B7280')
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
      }

      Blank()

      Row({ space: 8 }) {
        Button({ type: ButtonType.Normal })
          .width(40)
          .height(40)
          .borderRadius(20)
          .backgroundColor('#F3F4F6')
          .backgroundImage($r('app.media.ic_delete'))
          .backgroundImageSize({ width: 20, height: 20 })
          .backgroundImagePosition({ x: 10, y: 10 })
          .onClick(() => this.handleClearChat())

        Button({ type: ButtonType.Normal })
          .width(40)
          .height(40)
          .borderRadius(20)
          .backgroundColor('#F3F4F6')
          .backgroundImage($r('app.media.ic_export'))
          .backgroundImageSize({ width: 20, height: 20 })
          .backgroundImagePosition({ x: 10, y: 10 })
          .onClick(() => this.handleExport())

        Button({ type: ButtonType.Normal })
          .width(40)
          .height(40)
          .borderRadius(20)
          .backgroundColor('#F3F4F6')
          .backgroundImage($r('app.media.ic_settings'))
          .backgroundImageSize({ width: 20, height: 20 })
          .backgroundImagePosition({ x: 10, y: 10 })
          .onClick(() => {
            this.showSettings = !this.showSettings;
          })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(Color.White)
    .shadow({
      radius: 4,
      color: '#10000000',
      offsetY: 2
    })
  }

  @Builder
  buildSettingsPanel() {
    Column({ space: 16 }) {
      Row() {
        Text('回答模式')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#374151')

        Blank()

        Row({ space: 8 }) {
          Button('轻量思考')
            .fontSize(14)
            .height(32)
            .backgroundColor(this.currentMode === 'low' ? '#3B82F6' : '#E5E7EB')
            .fontColor(this.currentMode === 'low' ? Color.White : '#6B7280')
            .onClick(async () => {
              this.currentMode = 'low';
              await this.viewModel.updateMode('low');
            })

          Button('深度分析')
            .fontSize(14)
            .height(32)
            .backgroundColor(this.currentMode === 'high' ? '#3B82F6' : '#E5E7EB')
            .fontColor(this.currentMode === 'high' ? Color.White : '#6B7280')
            .onClick(async () => {
              this.currentMode = 'high';
              await this.viewModel.updateMode('high');
            })
        }
      }
      .width('100%')

      Row() {
        Column({ space: 4 }) {
          Text('深度思考模式')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#374151')

          Text('开启思考模式，模型强制先思考再回答。')
            .fontSize(12)
            .fontColor('#9CA3AF')
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Toggle({ type: ToggleType.Switch})
          .selectedColor('#3B82F6')
          .onChange(async (isOn: boolean) => {
            // this.memoryEnabled = isOn;
            await this.viewModel.updateMemorySetting(isOn);
          })
      }
      .width('100%')

      Button('管理记忆')
        .width('100%')
        .height(40)
        .fontSize(14)
        .backgroundColor('#F3F4F6')
        .fontColor('#374151')
        .onClick(() => {
          router.pushUrl({ url: 'pages/MemoryPage' });
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .border({
      width: { bottom: 1 },
      color: '#E5E7EB'
    })
  }

  @Builder
  // 欢迎页，初始化聊天页
  buildWelcomeScreen() {
    Column() {
      Image($r('app.media.icon'))
        .width(80)
        .height(80)
        .margin({ bottom: 16 })

      Text('欢迎使用 Harmony AI 助理')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2937')
        .margin({ bottom: 8 })

      Text('我是您的智能对话助手，有什么可以帮到您？')
        .fontSize(14)
        .fontColor('#6B7280')
        .margin({ bottom: 32 })

      Grid() {
        GridItem() {
          this.buildQuickAction('💡 帮我解释一个技术概念')
        }

        GridItem() {
          this.buildQuickAction('✍️ 帮我写一份工作邮件')
        }

        GridItem() {
          this.buildQuickAction('🔍 帮我分析一个问题')
        }

        GridItem() {
          this.buildQuickAction('📚 帮我学习一个新知识')
        }
      }
      .columnsTemplate('1fr 1fr')
      .rowsTemplate('1fr 1fr')
      .columnsGap(12)
      .rowsGap(12)
      .width('90%')
      .height(200)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildQuickAction(text: string) {
    Column() {
      Text(text)
        .fontSize(14)
        .fontColor('#374151')
        .textAlign(TextAlign.Start)
        .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: '#10000000'
    })
    .onClick(() => {
      const prompt = text.substring(2); // 移除 emoji
      this.handleSendMessage(prompt);
    })
  }

  @Builder
  buildMessageList() {
    Scroll(this.scroller) {
      Column({ space: 16 }) {
        ForEach(this.messages, (msg: Message, index: number) => {
          ChatBubble({
            message: msg,
            onReport: () => {
              promptAction.showToast({
                message: '感谢您的反馈，我们会审核这条消息',
                duration: 2000
              });
            }
          })
        }, (msg: Message) => msg.id)

        if (this.isLoading) {
          this.buildLoadingIndicator()
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  buildLoadingIndicator() {
    Row() {
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

      Row({ space: 6 }) {
        Circle({ width: 8, height: 8 })
          .fill('#9CA3AF')

        Circle({ width: 8, height: 8 })
          .fill('#9CA3AF')

        Circle({ width: 8, height: 8 })
          .fill('#9CA3AF')
      }
      .padding(12)
      .backgroundColor(Color.White)
      .borderRadius(16)
      .shadow({
        radius: 4,
        color: '#10000000'
      })
    }
    .justifyContent(FlexAlign.Start)
    .width('100%')
  }
}
