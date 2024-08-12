<div align="center">
<h1>droplet</h1>
</div>

<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v0.0.1-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/build-pass-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v0.53.4-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/project-open-brightgreen" style="display: inline-block;" />
</p>

## 介绍

droplet是一个图像加载缓存库，致力于更高效、更轻便、更简单得加载图片。在图片列表滚动时候实现平滑滚动得效果。


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
├── library                                 #源码目录 
└── entry                                     #测试用例目录
```

### 接口说明

主要类和函数接口说明详见 [API](./doc/feature_api.md)


## 使用说明

### 编译构建

描述具体的编译过程：

```shell
    第一步.由于该库的transform依赖C的代码，因此首先要用library/cpp下的C代码编译成so
      编译方法，新建一个仓颉UI项目，然后在entry/src/main/下面建一个文件夹，这个文件夹是和cangjie文件夹平级的，给他取一个名字比如cjdropletOpenGl,然后把刚才的
      C代码，放入这个文件夹，
      然后看新建项目的entry下面的build-profile.json5,在buildOption层级下加上这个
      "externalNativeOptions": {
       "path":"./src/main/cjdropletOpenGl/CMakeLists.txt",
       "arguments": "",
       "cppFlags": "",
       "abiFilters": [
         "arm64-v8a",
         "armeabi-v7a"
       ]
      }
      这个代码和cangjieOptions平级，其中的path路径就是刚新建的目录的下面的CMakeLists.txt
      注意，还有一个细节在entry/src/main/下面要建一个cpp名字的文件夹，没有的话可能编译so会失败
      接下来点击deveco的build菜单下的Build Haps/Apps 里的Build Haps 
      构建结束后，最后，会在entry/build/default/intermediates/cmake/default/obj/里面找到arm64-v8a这个文件夹，里面有libc++_shared.so libglwrapper.so两个文件
      其中的libglwrapper.so就是我们需要的so，注意libglwrapper这个名字跟你CMakeLists.txt里面的定义有关
    
    第二步
     在得到第一步的so之后，我们把这个so放入我们项目下的library/libs里面即可
     然后在library/src/main/cangjie/cjpm.toml里面添加   
     [ffi.c]
        glwrapper = {path = "../../../libs/"}   
    其中glwrapper是so的名字，如果你修改了c代码改了名字，要在这里同步修改，后面那个路径就是根据cjpm.toml的相对路径
    
    最后
       点击Build菜单下的Rebuild Project就能把项目编译成功 
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
        label: Option<String>.Some("page"),                                       // 生命周期标签 （可选）
        signature:Option<String>.Some("1111"), //不同的signature可保证缓存key的唯一    （可选）   
        transformCate:Option<PixelMapTransformation>.Some(RoundedCorners(50)), //transform效果 （可选）
        transitionOption:Option<TransitionOption>.Some(transitionOption)  //过渡动画 （可选）
    )

    public func onAppear(): Unit {
        Droplet.get(globalAbilityContext.getOrThrow()).onAppear(option.label)
    }
    public func onDisappear(): Unit {
        Droplet.get(globalAbilityContext.getOrThrow()).onDisAppear(option.label)
    }

    func build() {
        Column(30) {
            Column() {
                DropletImageComponent(globalContext:globalAbilityContext,option: option, beginFn: {=> text = "begin";AppLog.error("droplet hhs begin")}, endFn: {=> textTmp = "end";AppLog.error("droplet hhs end")})
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

当前基于 OpenHarmony Cangjie Mobile B100 版本实现的

## 开源协议

本项目基于 [Google License](./LICENSE) ，请自由的享受和参与开源。

## 参与贡献

欢迎给我们提交PR，欢迎给我们提交Issue，欢迎参与任何形式的贡献。