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

import { goodsInitialList, GoodsListItemType } from './InitialData';
import { MAGNIFICATION, MAX_DATA_LENGTH } from '../common/CommonConstants';

/**
 * 创建列表数据范围
 * 通过复制基础数据MAGNIFICATION倍来生成初始列表数据
 * @returns 扩展后的商品列表数据
 */
const createListRange = (): GoodsListItemType[] => {
  // 创建空数组用于存储结果
  let result = new Array<GoodsListItemType>();
  // 循环MAGNIFICATION次，将基础数据连接到结果数组中
  for (let i = 0; i < MAGNIFICATION; i++) {
    result = result.concat(goodsInitialList);
  }
  return result;
}

/**
 * 基础数据源类，实现IDataSource接口
 * 提供数据监听和通知机制
 */
class BasicDataSource implements IDataSource {
  // 数据变更监听器数组
  private listeners: DataChangeListener[] = [];

  /**
   * 获取数据总数
   * @returns 数据总数
   */
  public totalCount(): number {
    return 0;
  }

  /**
   * 根据索引获取数据项
   * @param index 数据索引
   * @returns 对应索引的数据项或undefined
   */
  public getData(index: number): GoodsListItemType | undefined {
    return undefined;
  }

  /**
   * 注册数据变更监听器
   * @param listener 数据变更监听器
   */
  registerDataChangeListener(listener: DataChangeListener): void {
    // 避免重复注册监听器
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  /**
   * 注销数据变更监听器
   * @param listener 数据变更监听器
   */
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const position = this.listeners.indexOf(listener);
    // 如果监听器存在，则从数组中移除
    if (position >= 0) {
      this.listeners.splice(position, 1);
    }
  }

  /**
   * 通知所有监听器数据已重新加载
   */
  notifyDataReload(): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataReloaded();
    })
  }

  /**
   * 通知所有监听器有新数据添加
   * @param index 添加数据的索引位置
   */
  notifyDataAdd(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataAdd(index);
    })
  }

  /**
   * 通知所有监听器数据已变更
   * @param index 变更数据的索引位置
   */
  notifyDataChange(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataChange(index);
    })
  }

  /**
   * 通知所有监听器有数据被删除
   * @param index 删除数据的索引位置
   */
  notifyDataDelete(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataDelete(index);
    })
  }

  /**
   * 通知所有监听器数据位置移动
   * @param from 移动前的位置
   * @param to 移动后的位置
   */
  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataMove(from, to);
    })
  }
}

/**
 * 列表数据源类，继承自BasicDataSource
 * 管理商品列表数据，支持动态添加数据
 */
export class ListDataSource extends BasicDataSource {
  // 当前列表数据
  private listData = createListRange();

  /**
   * 获取当前数据总数
   * @returns 列表数据长度
   */
  public totalCount(): number {
    return this.listData.length;
  }

  /**
   * 根据索引获取商品数据
   * @param index 数据索引
   * @returns 对应的商品数据项
   */
  public getData(index: number): GoodsListItemType {
    return this.listData[index];
  }

  /**
   * 向列表中添加新数据
   * 当数据量未达到最大限制时，将基础商品数据追加到列表末尾
   */
  public pushData(): void {
    // 检查是否达到最大数据长度限制
    if (this.listData.length < MAX_DATA_LENGTH) {
      // 将基础商品数据连接到当前列表
      this.listData = this.listData.concat(goodsInitialList);
      // 通知监听器数据已添加
      this.notifyDataAdd(this.listData.length - 1);
    }
  }
}
