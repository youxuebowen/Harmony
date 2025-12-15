// 输入栏组件
// ============================================

@Component
export struct InputBar {
  @State inputText: string = '';
  @Prop isLoading: boolean;
  @Prop showRegenerate: boolean;
  @Prop currentMode: string;
  @Prop memoryEnabled: boolean;
  onSend?: (text: string) => void;
  onRegenerate?: () => void;

  build() {
    Column() {
      Row({ space: 12 }) {
        TextInput({ text: this.inputText, placeholder: '输入您的问题...' })
          .layoutWeight(1)
          .height(48)
          .borderRadius(24)
          .backgroundColor(Color.White)
          .onChange((value: string) => {
            this.inputText = value;
          })
          .onSubmit(() => {
            this.handleSend();
          })

        if (this.showRegenerate) {

          Button({ type: ButtonType.Circle }) {
            Image($r('app.media.ic_refresh'))
              .width(20)
              .height(20)
          }
          .width(48)
          .height(48)
          .backgroundColor(this.inputText.trim() && !this.isLoading ? '#3B82F6' : '#D1D5DB')
          .onClick(() => this.handleSend())
          .enabled(this.inputText.trim() !== '' && !this.isLoading)
        }


        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.ic_send'))
            .width(20)
            .height(20)
        }
        .width(48)
        .height(48)
        .backgroundColor(this.inputText.trim() && !this.isLoading ? '#3B82F6' : '#D1D5DB')
        .onClick(() => this.handleSend())
        .enabled(this.inputText.trim() !== '' && !this.isLoading)


      }
      .padding(12)


      Row({ space: 16 }) {
        Text(`当前模式: ${this.currentMode === 'low' ? 'low' : 'high'}`)
          .fontSize(12)
          .fontColor('#6B7280')

        if (this.memoryEnabled) {
          Text('✓ 记忆已启用')
            .fontSize(12)
            .fontColor('#6B7280')
        }

        Blank()

        Row({ space: 4 }) {
          Image($r('app.media.ic_warning'))
            .width(14)
            .height(14)

          Text('请勿发送敏感个人信息')
            .fontSize(12)
            .fontColor('#6B7280')
        }
      }
      .padding({ left: 16, right: 16, bottom: 8 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .shadow({
      radius: 8,
      color: '#20000000',
      offsetY: -2
    })
  }

  handleSend() {
    if (this.inputText.trim() && !this.isLoading && this.onSend) {
      this.onSend(this.inputText.trim());
      this.inputText = '';
    }
  }
}