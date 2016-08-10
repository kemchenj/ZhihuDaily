# 知乎日报Demo
> **平台:** iOS 10, Xcode 8.0(beta 4)
>
> **语言:** Swift 3.0(beta 4)

![Demo Preview](https://github.com/kemchenj/ZhihuDaily/blob/master/Demo Preview.gif)

这个项目不打算使用第三方库, 基础功能全部手撸

## 待办功能
#### UI
- [x] 启动页图片
- [x] 下拉渐变导航栏
- [x] 图片轮播
    - [x] 下拉拉伸
    - [x] 数据协议
    - [ ] 定时轮播
- [ ] 下拉刷新
- [ ] 侧滑菜单
- [ ] 自定义Transition

#### 数据
- [x] 模型协议
    - [x] 解析JSON
- [ ] 缓存

#### 联网模块
- [x] 基于URLSession封装一个NetworkClient
    - [x] 前台下载, 后台下载
    - [x] 线程管理
    - [ ] 回调
    - [ ] 通知
