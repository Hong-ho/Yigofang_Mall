/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { initTabBarData } from '../viewmodel/InitialData';
import {
  LAYOUT_WIDTH_OR_HEIGHT,
  NORMAL_FONT_SIZE,
  BIGGER_FONT_SIZE,
  MAX_FONT_SIZE,
  MAX_OFFSET_Y,
  REFRESH_TIME,
  GOODS_EVALUATE_FONT_SIZE,
  MAX_LINES_TEXT
} from '../common/CommonConstants';
import GoodsList from './GoodsListComponent';
import PutDownRefresh from './PutDownRefreshLayout';

/**
 * 标签页组件
 * 实现商品分类标签切换功能
 * 支持下拉刷新和页面切换
 */
@Component
export default struct TabBar {
  // 记录当前触摸点Y坐标
  private currentOffsetY: number = 0;
  // 刷新定时器
  private timer: number = 0;
  // 当前标签页索引
  @State tabsIndex: number = 0;
  // 刷新状态标识
  @State refreshStatus: boolean = false;
  // 刷新文本
  @State refreshText: Resource = $r('app.string.refresh_text');

  /**
   * 构建第一个标签页（默认选中标签）
   * 根据当前标签页索引调整字体大小和颜色
   */
  @Builder
  firstTabBar() {
    Column() {
      Text($r('app.string.selected'))
        // 根据是否选中调整字体大小
        .fontSize(this.tabsIndex === 0 ? BIGGER_FONT_SIZE : NORMAL_FONT_SIZE)
        // 根据是否选中调整字体颜色
        .fontColor(this.tabsIndex === 0 ? Color.Black : $r('app.color.gray'))
        .maxLines(MAX_LINES_TEXT)
        .minFontSize(this.tabsIndex === 0 ? NORMAL_FONT_SIZE : GOODS_EVALUATE_FONT_SIZE)
        .maxFontSize(this.tabsIndex === 0 ? BIGGER_FONT_SIZE : NORMAL_FONT_SIZE)
    }
    .width(LAYOUT_WIDTH_OR_HEIGHT)
    .height(LAYOUT_WIDTH_OR_HEIGHT)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 构建其他标签页
   * @param content 标签页内容
   * @param index 标签页索引
   */
  @Builder
  otherTabBar(content: Resource, index: number) {
    Column() {
      Text(content)
        // 根据是否选中调整字体大小
        .fontSize(this.tabsIndex === index + 1 ? BIGGER_FONT_SIZE : NORMAL_FONT_SIZE)
        // 根据是否选中调整字体颜色
        .fontColor(this.tabsIndex === index + 1 ? Color.Black : $r('app.color.gray'))
        .maxLines(MAX_LINES_TEXT)
        .minFontSize(this.tabsIndex === index + 1 ? NORMAL_FONT_SIZE : GOODS_EVALUATE_FONT_SIZE)
        .maxFontSize(this.tabsIndex === index + 1 ? BIGGER_FONT_SIZE : NORMAL_FONT_SIZE)
    }
    .width(LAYOUT_WIDTH_OR_HEIGHT)
    .height(LAYOUT_WIDTH_OR_HEIGHT)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 处理下拉刷新逻辑
   * @param event 触摸事件
   */
  putDownRefresh(event?: TouchEvent): void {
    if (event === undefined) {
      return;
    }
    switch (event.type) {
      // 记录手指按下的y坐标
      case TouchType.Down:
        this.currentOffsetY = event.touches[0].y;
        break;
      case TouchType.Move:
        // 根据下拉偏移量判断是否触发刷新
        this.refreshStatus = event.touches[0].y - this.currentOffsetY > MAX_OFFSET_Y;
        break;
      case TouchType.Cancel:
        break;
      case TouchType.Up:
        // 模拟刷新效果，不实际请求数据
        this.timer = setTimeout(() => {
          this.refreshStatus = false;
        }, REFRESH_TIME);
        break;
      default:
        break;
    }
  }

  /**
   * 组件销毁前清理工作
   * 清除刷新定时器
   */
  aboutToDisappear() {
    clearTimeout(this.timer);
  }

  build() {
    // 标签页容器
    Tabs() {
      // 第一个标签内容（商品列表页）
      TabContent() {
        // 可滚动容器
        Scroll() {
          Column() {
            // 根据刷新状态决定是否显示刷新组件
            if (this.refreshStatus) {
              PutDownRefresh({ refreshText: $refreshText })
            }
            // 商品列表组件
            GoodsList()
            // 到底提示文本
            Text($r('app.string.to_bottom')).fontSize(NORMAL_FONT_SIZE).fontColor($r('app.color.gray'))
          }
          .width(LAYOUT_WIDTH_OR_HEIGHT)
        }
        .scrollBar(BarState.Off) // 隐藏滚动条
        .edgeEffect(EdgeEffect.Spring) // 设置边缘弹性效果
        .width(LAYOUT_WIDTH_OR_HEIGHT)
        .height(LAYOUT_WIDTH_OR_HEIGHT)
        // 监听触摸事件处理下拉刷新
        .onTouch((event?: TouchEvent) => {
          this.putDownRefresh(event);
        })
      }
      .tabBar(this.firstTabBar) // 设置标签栏

      // 循环创建其他标签页
      ForEach(initTabBarData, (item: Resource, index?: number) => {
        TabContent() {
          Column() {
            Text(item).fontSize(MAX_FONT_SIZE)
          }
          .justifyContent(FlexAlign.Center)
          .width(LAYOUT_WIDTH_OR_HEIGHT)
          .height(LAYOUT_WIDTH_OR_HEIGHT)
        }
        .tabBar(this.otherTabBar(item, index !== undefined ? index : 0))
      })
    }
    // 标签页切换回调
    .onChange((index: number) => {
      this.tabsIndex = index;
    })
    .vertical(false) // 水平排列标签页
  }
}