<div align="center">
<h1>droplet</h1>
</div>

<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v0.0.1-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/build-pass-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v0.53.12-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/project-open-brightgreen" style="display: inline-block;" />
</p>

## 介绍

droplet是一个图像加载缓存库，致力于更高效、更轻便、更简单地加载图片。在图片列表滚动的时候实现平滑滚动的效果。


### 特性

- 🚀 支持生命周期管理。

- 🚀 支持静态图像加载。

- 💪 支持设置加载中和加载失败图片以及压缩图。

- 🛠️ 加载 gif 图片资源。

- 🌍 支持三级缓存策略。

- 🚀 支持transform图像变换效果。

- 🚀 支持过渡动画。

- 🚀 支持自定义组件的形式加载图片。


## 软件架构

### 架构图

<p align="center">
<img src="./doc/assets/framework1.png" width="60%" >
<img src="./doc/assets/framework2.png" width="60%" >
</p>

架构图文字说明，包括模块说明、架构层次等详细说明。

### 源码目录

```shell
├── README.md                                 #整体介绍
├── doc                                       #文档目录
│   ├── assets                                #文档资源目录
│   └── feature_api.md                        #API接口文档
├── library                                   #源码目录 
├── entry                                     #示例目录
└── hvigor                                    #构建工具目录
```

### 接口说明

主要类和函数接口说明详见 [API](./doc/feature_api.md)


## 使用说明

### 编译构建

描述具体的编译过程：

```shell
    1.先通过命令把代码下载下来,
      git clone -b 具体分支名 https://gitcode.com/Cangjie-TPC/droplet.git
          
    2.选择library模块,点击Build菜单,然后点击 Make Module 'library' 等待编译完成,项目则编译成功
    
```

### 功能示例

#### 1. 把droplet作为三方库依赖引入
当前仓颉语言三方库还不支持中心仓库，可以把依赖库克隆到本地引入，具体步骤如下：

a. 目标工程把依赖库作为git submodule引入

```shell
> cd $工程根目录
>mkdir third-party
>cd  third-party
>git submodule add "https://gitcode.com/Cangjie-TPC/droplet.git"
 然后按照上述办法把droplet编译通过即可
```

b. 打开 .\entry\src\main\cangjie\cjpm.toml，添加依赖

```toml
[dependencies]
  droplet = {path = "../../../../third-party/droplet/library/src/main/cangjie", version = "1.0.0"}
```

#### 2. 在UI代码中使用Droplet组件（DropletImageComponent）
功能示例描述: 加载一个网络图片，支持的图片类型为：bmp、jpg、png、wbep。

示例代码如下：

```cangjie
package ohos_app_cangjie_entry

import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.base.*
import ohos.ability.*

import ohos_app_cangjie_entry.js.globalAbilityContext
import cj_res_entry.app
import droplet.droplet.*

@Entry
@Component
class MyView {

	@State var text: String = ""

    @State var textTmp: String = ""

    var transitionOption:TransitionOption = TransitionOption(TransitionType.Opacity,0.0,1.0,1000) //透明度


    @State
    var option: DropletRequestOption = DropletRequestOption (
        // 加载一张本地的jpg资源（必选）
        loadSrc: "/data/storage/el1/bundle/testjpg.jpg",    // (必选) jpg 注意这里是本地路径，必须本地有这张图片，才能加载 或者自己填写网络图片
        placeholder: Option<CJResource>.Some(@r(app.media.loading)),             // 占位图使用本地资源icon_loading（可选）自己定义
        errholder: Option<CJResource>.Some(@r(app.media.img)),                   // 失败占位图使用本地资源icon_failed（可选） 自己定义
        strategy: Option<DiskCacheStrategy>.Some(DiskCacheStrategyDATA()),       // 磁盘缓存策略（可选）
        label: Option<String>.Some("page"),                                       // 生命周期标签 （可选） 同一个页面不同组件保持相同的标签,或者都不加,
                                                                                  //  这样每个页面的组件会用相同的requestManager管理生命周期
        signature:Option<String>.Some("1111"), //不同的signature可保证缓存key的唯一    （可选）   
        transformCate:Option<PixelMapTransformation>.Some(RoundedCorners(50)), //transform效果 （可选）
        transitionOption:Option<TransitionOption>.Some(transitionOption)  //过渡动画 （可选）
    )

    protected open func aboutToAppear(){
        Droplet.get(globalAbilityContext.getOrThrow()).onAppear(option.label)  //onAppear和onDisAppear一起使用或一起不使用,参数和组件的label保持一致,
                                                                               //组件没设置label,就调用空参的onAppear                      
    }               
    
    protected open func aboutToDisappear(){
        Droplet.get(globalAbilityContext.getOrThrow()).onDisAppear(option.label) //onAppear和onDisAppear一起使用或一起不使用,参数和组件的label保持一致
                                                                                 //组件没设置label,就调用空参的onDisAppear
    }

    func build() {
        Column(30) {
            Column() {
                DropletImageComponent(globalContext:globalAbilityContext,option: option, beginFn: {=> text = "begin";AppLog.error("droplet begin")}, endFn: {=> textTmp = "end";AppLog.error("droplet end")})
            }.width(100.percent)
        }
    }

}


```

执行结果如下：
图片在手机上成功展示。

```shell
load成功
```


## 约束与限制

IDE : DevEco Studio NEXT Beta1(5.0.3.810)

Plugins (SDK) : DevEco Studio NEXT Beta1-Cangjie Plugin(5.0.3.810)


## 开源协议

本项目基于 [Google License](./LICENSE) ，请自由的享受和参与开源。

## 参与贡献

欢迎给我们提交PR，欢迎给我们提交Issue，欢迎参与任何形式的贡献。