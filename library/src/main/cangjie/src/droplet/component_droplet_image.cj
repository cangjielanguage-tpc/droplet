/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */

package droplet.droplet

import ohos.state_manage.*
import ohos.state_macro_manage.*
internal import ohos.base.*
internal import ohos.component.*
internal import ohos.image.Component as ImageComponent
internal import ohos.image.Image as ImageImage
internal import ohos.image.PixelMap
internal import ohos.image.InitializationOptions
internal import ohos.image.PixelMapFormat
internal import ohos.image.Size
internal import ohos.image.Region
internal import ohos.image.PositionArea
internal import ohos.image.createPixelMap
internal import ohos.image.createImageSource
internal import ohos.image.ImageSource
internal import ohos.image.SourceOptions
internal import ohos.image.DecodingOptions
internal import ohos.image.ImageInfo
internal import ohos.ability.*
internal import ohos.concurrency.*
internal import net.http.*
internal import std.socket.*
internal import net.tls.*
internal import std.io.*
internal import encoding.url.*
internal import std.fs.Path as FSPath
internal import std.fs.*
internal import std.time.*
internal import std.os.posix.*
internal import std.collection.*
internal import std.math.*
internal import std.log.*
internal import encoding.hex.*
internal import std.sync.*
internal import ohos.resource_manager.*
internal import std.format.Formatter
internal import std.overflow.*
internal import ohos.animator.*
internal import std.convert.*

/**
 * Created on 2024/3/4
 */
@Observed
public class DropletRequestOption {

    // 加载一张本地的jpg资源（必选）
    //@Publish
    //public var loadSrc: String = ""
    // 占位图使用本地资源icon_loading（可选）
    @Publish
    public var placeholder: Option<CJResource> = Option<CJResource>.None
    // 失败占位图使用本地资源icon_failed（可选）
    @Publish
    public var errholder: Option<CJResource> = Option<CJResource>.None
    // 磁盘缓存策略（可选）
    @Publish
    public var strategy: Option<DiskCacheStrategy> = Option<DiskCacheStrategy>.None
    //transform
    @Publish
    public var transformCate: Option<PixelMapTransformation> = Option<PixelMapTransformation>.None
    //是否禁用内存缓存
    @Publish
    public var transformListCate: Option<ArrayList<PixelMapTransformation>> = Option<ArrayList<PixelMapTransformation>>.
        None

    @Publish
    public var isSkipMemory: Option<Bool> = Option<Bool>.None
    //Override
    @Publish
    public var overrideWH: Option<(Int64, Int64)> = Option<(Int64, Int64)>.None
    //apply
    @Publish
    public var applyRequestOption: Option<RequestOptions> = Option<RequestOptions>.None
    //只从缓存读取数据
    @Publish
    public var onlyRetrieveFromCache: Option<Bool> = Option<Bool>.None
    //禁用动画
    @Publish
    public var dontTransform: Option<Bool> = Option<Bool>.None
    //usedefault
    @Publish
    public var useDefaultRequestOption: Option<RequestOptions> = Option<RequestOptions>.None
    //thumbnail float
    @Publish
    public var thumbnail: Option<Float32> = Option<Float32>.None
    //thumnail drawable
    @Publish
    public var thumbnaildrawable: Option<RequestBuilder<Drawable>> = Option<RequestBuilder<Drawable>>.None
    //signature
    @Publish
    public var signature: Option<String> = Option<String>.None
    //trisition
    @Publish
    public var transitionOption: Option<TransitionOption> = Option<TransitionOption>.None
}

@Component
public class DropletImageComponent {
    @State
    @Watch[onOptionChanged]
    var option: Option<DropletRequestOption> = Option<DropletRequestOption>.None

    var globalContext: Option<AbilityContext> = Option<AbilityContext>.None

    @State
    var loadSrc: String = ""

    @State
    var loadSrcRes: Option<CJResource> = Option<CJResource>.None

    @State
    var imageViewWidth: Length = Length(0.0, unitType: LengthType.vp)

    @State
    var imageViewHeight: Length = Length(0.0, unitType: LengthType.vp)

    @State
    var imageFit: ImageFit = ImageFit.ScaleDown

    /*生命周期管理用到的标签名称 */
    @State
    var label: String = ""

    /*加载状态*/
    @State
    var isLoading: Bool = true
    /*错误状态*/
    @State
    var isError: Bool = false

    /*加载状态*/
    @State
    var opacityValue: Float64 = 1.0 //默认不透明

    @State
    var rotateValue: Float32 = 0.0

    @State
    var scaleValue: Float32 = 1.0

    @State
    var TranslateValue: Float64 = 0.0

    var flag: Bool = false

    var oldWidth: Int64 = 0
    var oldHeight: Int64 = 0

    let size: Size = Size(width: 1, height: 1)
    let opts: InitializationOptions = InitializationOptions(size: size)
    let color: Array<UInt8> = Array<UInt8>(96, item: 0)
    @State
    var pixelMap: PixelMap = createPixelMap(color, opts)

    func onOptionChanged() {
        updateImg(oldWidth, oldHeight)
    }

    func updateImg(width: Int64, height: Int64) {
        if ((loadSrc != "" && width > 0 && height > 0) || (!loadSrcRes.isNone() && width > 0 && height > 0)) {
            var requestManager = Option<RequestManager>.None

            if (let Some(o) <- option) {
                if (let Some(v) <- o.useDefaultRequestOption) {
                    requestManager = Droplet.withContext(globalContext.getOrThrow(), label).useDefaultRequestOptions(v)
                } else {
                    requestManager = Droplet.withContext(globalContext.getOrThrow(), label)
                }
            } else {
                requestManager = Droplet.withContext(globalContext.getOrThrow(), label)
            }

            var tempBuilder: Option<RequestBuilder<Drawable>> = Option<RequestBuilder<Drawable>>.None
            if (loadSrc != "") {
                tempBuilder = requestManager.getOrThrow().load(loadSrc)
            } else if (!loadSrcRes.isNone()) {
                tempBuilder = requestManager.getOrThrow().load(loadSrcRes.getOrThrow())
            } else {
                throw Exception("loadSrc and loadSrcRes can not both be empty")
            }

            var builder = tempBuilder.getOrThrow()

            //设置三级缓存策略
            if (let Some(o) <- option) {
                if (let Some(v) <- o.strategy) {
                    builder = builder.setDiskCacheStrategy(v)
                }
            }

            if (let Some(o) <- option) {
                if (let Some(v) <- o.onlyRetrieveFromCache) {
                    builder = builder.onlyRetrieveFromCachecj(v, builder)
                }
            }

            if (let Some(o) <- option) {
                if (let Some(v) <- o.isSkipMemory) {
                    builder = builder.skipMemoryCache(v, builder)
                }
            }

            if (let Some(o) <- option) {
                if (let Some(v) <- o.thumbnail) {
                    builder = builder.thumbnail(v)
                }
            }

            if (let Some(o) <- option) {
                if (let Some(v) <- o.thumbnaildrawable) {
                    builder = builder.thumbnail(v)
                }
            }

            if (let Some(o) <- option) {
                if (let Some(v) <- o.overrideWH) {
                    builder = builder.setOverride(v[0], v[1])
                }
            }

            if (let Some(o) <- option) {
                if (let Some(v) <- o.transformCate) {
                    builder = builder.transform(v)
                }
            }

            if (let Some(o) <- option) {
                if (let Some(v) <- o.transformListCate) {
                    if (v.size > 1) {
                        builder = builder.transforms(v)
                    } else if (v.size == 1) {
                        builder = builder.transform(v[0])
                    }
                }
            }

            if (let Some(o) <- option) {
                if (let Some(v) <- o.dontTransform) {
                    if (v) {
                        builder = builder.dontTransform(builder)
                    }
                }
            }

            if (let Some(o) <- option) {
                if (let Some(v) <- o.errholder) {
                    builder = builder.error(v)
                }
            }

            if (let Some(o) <- option) {
                if (let Some(v) <- o.applyRequestOption) {
                    builder = builder.apply(v)
                }
            }

            if (let Some(o) <- option) {
                if (let Some(v) <- o.signature) {
                    builder = builder.setSignature(StringKey(v))
                }
            }

            builder.listener(
                {
                    drawable: Drawable, model: Model, target: Target<Drawable>, datasource: DataSource, 
                    isFirstResource: Bool => return false
                },
                {
                    e: DropletException, model: Model, target: Target<Drawable>, isFirstResource: Bool => return false
                }
            ).into(
                {
                    p: PixelMap => launch {
                        isLoading = false
                        pixelMap = p
                        if (let Some(o) <- option) {
                            if (let Some(i) <- o.transitionOption) {
                                //创建动画对象
                                var backAnimator: ?AnimatorResult = AnimatorResult(
                                    AnimatorOptions(
                                        duration: i.getDuration(),
                                        easing: "linear",
                                        delay: 0,
                                        fill: AnimatorFill.Forwards,
                                        direction: AnimatorDirection.Normal,
                                        iterations: 1,
                                        begin: i.getBegin(),
                                        end: i.getEnd()
                                    )
                                )
                                //表明有动画
                                match (i.getTransType()) {
                                    case Opacity => backAnimator?.onframe = {
                                        value: Float64 => this.opacityValue = value
                                    }
                                    case Rotate => backAnimator?.onframe = {
                                        value: Float64 => this.rotateValue = (Float32(value))
                                    }
                                    case Scale => backAnimator?.onframe = {
                                        value: Float64 => this.scaleValue = (Float32(value))
                                    }
                                    case Translate => backAnimator?.onframe = {
                                        value: Float64 => this.TranslateValue = value
                                    }
                                    case _ => false
                                }
                                let callBackGet2 = backAnimator?.onframe
                                let fun2 = callBackGet2.getOrThrow()
                                backAnimator?.play()
                            }
                        }
                    }
                },
                {
                    cjres: CJResource, isErrorPic: Bool => if (isErrorPic) {
                        launch {
                            isError = true
                        }
                    }
                },
                width,
                height
            )
        }
    }

    func build() {
        Column() {
            if (isError) {
                if (let Some(o) <- option) {
                    if (let Some(w) <- o.errholder) {
                        if (imageViewWidth.value == 0.0 || imageViewHeight.value == 0.0) {
                            Image(w).width(100.percent).objectFit(ImageFit.ScaleDown)
                        } else {
                            Image(w).width(imageViewWidth).height(imageViewHeight).objectFit(ImageFit.ScaleDown)
                        }
                    }
                }
            } else {
                //有占位图的时候加载中走这里
                if (isLoading) {
                    if (let Some(o) <- option) {
                        if (let Some(v) <- o.placeholder) {
                            if (imageViewWidth.value == 0.0 || imageViewHeight.value == 0.0) {
                                Image(v).width(100.percent).objectFit(ImageFit.ScaleDown).onAreaChange(
                                    {
                                        oldArea, newArea =>
                                        let newWidth: Int64 = Int64(newArea.width)
                                        let newHeight: Int64 = Int64(newArea.height)
                                        if (oldWidth != newWidth || oldHeight != newHeight) {
                                            if (!flag && newWidth > 0 && newHeight > 0) {
                                                flag = true
                                                updateImg(newWidth, newHeight)
                                                oldWidth = newWidth
                                                oldHeight = newHeight
                                            }
                                        }
                                    }
                                )
                            } else {
                                Image(v).width(imageViewWidth).height(imageViewHeight).objectFit(ImageFit.ScaleDown).onAreaChange(
                                    {
                                        oldArea, newArea =>
                                        let newWidth: Int64 = Int64(newArea.width)
                                        let newHeight: Int64 = Int64(newArea.height)
                                        if (oldWidth != newWidth || oldHeight != newHeight) {
                                            if (!flag && newWidth > 0 && newHeight > 0) {
                                                flag = true
                                                updateImg(newWidth, newHeight)
                                                oldWidth = newWidth
                                                oldHeight = newHeight
                                            }
                                        }
                                    }
                                )
                            }
                        } else {
                            //没有展位图
                            //没有占位图的时候加载中走这里
                            if (imageViewWidth.value == 0.0 || imageViewHeight.value == 0.0) {
                                Image(pixelMap).width(100.percent).onAreaChange(
                                    {
                                        oldArea, newArea =>
                                        let newWidth: Int64 = Int64(newArea.width)
                                        let newHeight: Int64 = Int64(newArea.height)
                                        if (oldWidth != newWidth || oldHeight != newHeight) {
                                            if (!flag && newWidth > 0 && newHeight > 0) {
                                                flag = true
                                                updateImg(newWidth, newHeight)
                                                oldWidth = newWidth
                                                oldHeight = newHeight
                                            }
                                        }
                                    }
                                )
                            } else {
                                Image(pixelMap).width(imageViewWidth).height(imageViewHeight).onAreaChange(
                                    {
                                        oldArea, newArea =>
                                        let newWidth: Int64 = Int64(newArea.width)
                                        let newHeight: Int64 = Int64(newArea.height)
                                        if (oldWidth != newWidth || oldHeight != newHeight) {
                                            if (!flag && newWidth > 0 && newHeight > 0) {
                                                flag = true
                                                updateImg(newWidth, newHeight)
                                                oldWidth = newWidth
                                                oldHeight = newHeight
                                            }
                                        }
                                    }
                                )
                            }
                        }
                    } else {
                        //没有展位图
                        //没有占位图的时候加载中走这里
                        if (imageViewWidth.value == 0.0 || imageViewHeight.value == 0.0) {
                            Image(pixelMap).width(100.percent).onAreaChange(
                                {
                                    oldArea, newArea =>
                                    let newWidth: Int64 = Int64(newArea.width)
                                    let newHeight: Int64 = Int64(newArea.height)
                                    if (oldWidth != newWidth || oldHeight != newHeight) {
                                        if (!flag && newWidth > 0 && newHeight > 0) {
                                            flag = true
                                            updateImg(newWidth, newHeight)
                                            oldWidth = newWidth
                                            oldHeight = newHeight
                                        }
                                    }
                                }
                            )
                        } else {
                            Image(pixelMap).width(imageViewWidth).height(imageViewHeight).onAreaChange(
                                {
                                    oldArea, newArea =>
                                    let newWidth: Int64 = Int64(newArea.width)
                                    let newHeight: Int64 = Int64(newArea.height)
                                    if (oldWidth != newWidth || oldHeight != newHeight) {
                                        if (!flag && newWidth > 0 && newHeight > 0) {
                                            flag = true
                                            updateImg(newWidth, newHeight)
                                            oldWidth = newWidth
                                            oldHeight = newHeight
                                        }
                                    }
                                }
                            )
                        }
                    }
                } else {
                    //主图显示
                    //控件宽高不设置 控件大小和pixelmap大小一样
                    if (imageViewWidth.value == 0.0 || imageViewHeight.value == 0.0) {
                        Image(pixelMap).opacity(opacityValue).rotate(rotateValue).scale(scaleValue).translateX(
                            TranslateValue).width(100.percent).objectFit(imageFit)
                    } else {
                        Image(pixelMap).opacity(opacityValue).rotate(rotateValue).scale(scaleValue).translateX(
                            TranslateValue).width(imageViewWidth).height(imageViewHeight).objectFit(imageFit)
                    }
                }
            }
        }
    }
}
