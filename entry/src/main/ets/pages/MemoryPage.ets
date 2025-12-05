// 记忆管理页面
// ============================================

import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { MemoryViewModel } from '../viewmodel/MemoryViewModel';
import { UserMemory } from '../model/UserMemory';

@Entry
@Component
struct MemoryPage {
  @State memories: UserMemory[] = [];
  private viewModel: MemoryViewModel = new MemoryViewModel();

  aboutToAppear() {
    this.loadMemories();
  }

  async loadMemories() {
    this.memories = await this.viewModel.getAllMemories();
  }

  async deleteMemory(id: string) {
    await this.viewModel.deleteMemory(id);
    await this.loadMemories();
    promptAction.showToast({
      message: '已删除',
      duration: 1500
    });
  }

  async clearAll() {
    AlertDialog.show({
      title: '确认清除',
      message: '确定要清除所有记忆吗？此操作不可恢复。',
      autoCancel: true,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '清除',
        fontColor: '#E74C3C',
        action: async () => {
          await this.viewModel.clearAll();
          await this.loadMemories();
        }
      }
    });
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Button({ type: ButtonType.Normal })
          .width(40)
          .height(40)
          .borderRadius(20)
          .backgroundColor('#F3F4F6')
          .backgroundImage($r('app.media.ic_back'))
          .backgroundImageSize({ width: 20, height: 20 })
          .onClick(() => {
            router.back();
          })

        Text('记忆管理')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2937')
          .margin({ left: 12 })

        Blank()

        if (this.memories.length > 0) {
          Button('清除全部')
            .fontSize(14)
            .fontColor('#EF4444')
            .backgroundColor('#FEE2E2')
            .onClick(() => this.clearAll())
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)

      if (this.memories.length === 0) {
        Column() {
          Image($r('app.media.ic_empty'))
            .width(80)
            .height(80)
            .margin({ bottom: 16 })

          Text('暂无记忆')
            .fontSize(16)
            .fontColor('#9CA3AF')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 12 }) {
          ForEach(this.memories, (memory: UserMemory) => {
            ListItem() {
              this.buildMemoryCard(memory)
            }
          }, (memory: UserMemory) => memory.id)
        }
        .width('100%')
        .layoutWeight(1)
        .padding(16)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  @Builder
  buildMemoryCard(memory: UserMemory) {
    Column({ space: 8 }) {
      Row() {
        Text(memory.key)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2937')

        Blank()

        Text(this.getCategoryName(memory.category))
          .fontSize(12)
          .fontColor('#6B7280')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('#F3F4F6')
          .borderRadius(4)
      }
      .width('100%')

      Text(memory.value)
        .fontSize(14)
        .fontColor('#6B7280')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Row() {
        Text(this.formatTime(memory.createdAt))
          .fontSize(12)
          .fontColor('#9CA3AF')

        Blank()

        Button('删除')
          .fontSize(12)
          .height(28)
          .fontColor('#EF4444')
          .backgroundColor('#FEE2E2')
          .onClick(() => this.deleteMemory(memory.id))
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 4,
      color: '#10000000'
    })
  }

  getCategoryName(category: string): string {
    const map: Record<string, string> = {
      'preference': '偏好',
      'fact': '事实',
      'habit': '习惯'
    };
    return map[category] || category;
  }

  formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getMonth() + 1}/${date.getDate()} ${date.getHours()}:${date.getMinutes().toString().padStart(2, '0')}`;
  }
}