package ohos_app_cangjie_entry

import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.base.*
import ohos.ability.*

import droplet.*
import ohos.resource_manager.__GenerateResource__
import droplet.TransitionType as DropletTransitionType

@Entry
@Component
class TestCase {

	@State var label: String = "EntryView"

    @State
    var option: DropletRequestOption = DropletRequestOption (
         //网络图片
         //loadSrc: "http://www....../testjpg.jpg",
         //本地图片
         //loadSrc: "/data/storage/el1/bundle/testjpg.jpg",
         //加载raw文件图片
         //loadSrc："raw1.png"  //要加载的raw文件夹下图片名称
         //读取res下的资源文件
         loadSrcRes: @r(app.media.cat), //loadSrc和loadSrcRes二选一 二者都存在的话loadSrc优先
         placeholder: @r(app.media.loading),             // 占位图使用本地资源icon_loading（可选）自己定义
         errholder: @r(app.media.error),                   // 失败占位图使用本地资源icon_failed（可选） 自己定义
         strategy: DiskCacheStrategyDATA(),       // 磁盘缓存策略（可选）
         signature:"1111", //不同的signature可保证缓存key的唯一    （可选）
         transformCate:RoundedCorners(50), //transform效果（可选）
         //说明：RoundedCorners 走 native GL 变换偶现阻塞（详见 gl_wrapper.cpp pThreadLock），
         //圆角改用组件的 borderRadius+clip 实现，见下方 DropletImageComponent 的链式属性
         transitionOption:TransitionOption(DropletTransitionType.Opacity,0.0,1.0,1000),  //过渡动画 （可选）
         imageFit: ImageFit.Contain //图片相对控件对齐方式 默认ImageFit.Scale 可选
    )

    protected open func aboutToAppear(){
        Droplet.get(getStageContext(globalAbilityContext.getOrThrow())).onAppear(label)  //onAppear和onDisAppear一起使用，参数和组件的label保持一致,
    }

    protected open func aboutToDisappear(){
        Droplet.get(getStageContext(globalAbilityContext.getOrThrow())).onDisAppear(label) //onAppear和onDisAppear一起使用,参数和组件的label保持一致
    }

    func build() {
        Column(30) {
            Column() {
                DropletImageComponent(
                    //控件宽度 支持百分比和vp 可选 //建议都设置(宽高默认为100%percent)
                    imageViewWidth: 50.percent,
                    //控件高度 支持百分比和vp 可选 //建议都设置(宽高默认为100%percent)
                    imageViewHeight: 120.vp,
                    //context对象
                    globalContext:getStageContext(globalAbilityContext.getOrThrow()), //(必选)
                    //droplet选项
                    dropletOption: option,//(必选)
                    // 生命周期标签 同一个页面不同组件保持相同的标签,
                    label: label,
                    resourceFn: {
                        pixelMap =>
                        var width = pixelMap.getImageInfo().size.width
                        var height = pixelMap.getImageInfo().size.height
                        AppLog.error("droplet--- resourceFn width=${width} height=${height}")
                    }, //加载成功的回调 可以获取显示在控件上的图片的宽和高
                    failedFn: {
                        e:DropletException => AppLog.error("droplet--- failedFn")
                    }  //加载失败的回调
                )
                //.borderRadius(50)  // 圆角改用组件属性实现，替代 RoundedCorners 变换
                //.clip(true)
            }.width(100.percent)
        }
    }

}