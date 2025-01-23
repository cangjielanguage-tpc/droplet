/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
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
internal import ohos.resource_manager.*
internal import ohos.animator.*
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
internal import std.format.Formatter
internal import std.overflow.*
internal import std.convert.*

/**
 * Created on 2024/3/4
 */
@Observed
public class DropletRequestOption {

    @Publish
    public var loadSrc: String = ""

    @Publish
    public var loadSrcRes: ?CJResource = Option<CJResource>.None

    @Publish
    public var placeholder: ?CJResource = Option<CJResource>.None
    // 失败占位图使用本地资源icon_failed（可选）
    @Publish
    public var errholder: ?CJResource = Option<CJResource>.None
    // 磁盘缓存策略（可选）
    @Publish
    public var strategy: ?DiskCacheStrategy = Option<DiskCacheStrategy>.None
    //transform
    @Publish
    public var transformCate: ?PixelMapTransformation = Option<PixelMapTransformation>.None
    //是否禁用内存缓存
    @Publish
    public var transformListCate: ?ArrayList<PixelMapTransformation> = Option<ArrayList<PixelMapTransformation>>
        .None

    @Publish
     public var isSkipMemory: ?Bool = Option<Bool>.None
    //Override
    @Publish
    public var overrideWH: ?(Int64, Int64) = Option<(Int64, Int64)>.None
    //apply
    @Publish
    public var applyRequestOption: ?RequestOptions = Option<RequestOptions>.None
    //只从缓存读取数据
    @Publish
    public var onlyRetrieveFromCache: ?Bool = Option<Bool>.None
    //禁用动画
    @Publish
    public var dontTransform: ?Bool = Option<Bool>.None
    //usedefault
    @Publish
    public var useDefaultRequestOption: ?RequestOptions = Option<RequestOptions>.None
    //thumbnail float
    @Publish
    public var thumbnail: ?Float32 = Option<Float32>.None
    //thumnail drawable
    @Publish
    public var thumbnaildrawable: ?RequestBuilder<Drawable> = Option<RequestBuilder<Drawable>>.None
    //signature
    @Publish
    public var signature: ?String = Option<String>.None
    //trisition
    @Publish
    public var transitionOption: ?TransitionOption = Option<TransitionOption>.None

}

@Component
public class DropletImageComponent {

    @Link
    @Watch[onOptionChanged]
    var dropletOption: DropletRequestOption

    var globalContext: Option<AbilityContext> = Option<AbilityContext>.None

    @State
    var imageViewWidth: Length = Length(100,unitType: LengthType.percent)

    @State
    var imageViewHeight: Length =  Length(100, unitType: LengthType.percent)

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
        if ((dropletOption.loadSrc != "" && width > 0 && height > 0) || (!dropletOption.loadSrcRes.isNone() && width > 0 && height > 0)) {
            var requestManager = Option<RequestManager>.None

            if (let Some(v) <- dropletOption.useDefaultRequestOption) {
                requestManager = Droplet.withContext(globalContext.getOrThrow(), label).useDefaultRequestOptions(v)
            } else {
                requestManager = Droplet.withContext(globalContext.getOrThrow(), label)
            }

            var tempBuilder: Option<RequestBuilder<Drawable>> = Option<RequestBuilder<Drawable>>.None
            if (dropletOption.loadSrc != "") {
                tempBuilder = requestManager.getOrThrow().load(dropletOption.loadSrc)
            } else if (!dropletOption.loadSrcRes.isNone()) {
                tempBuilder = requestManager.getOrThrow().load(dropletOption.loadSrcRes.getOrThrow())
            } else {
                throw Exception("loadSrc and loadSrcRes can not both be empty")
            }

            var builder = tempBuilder.getOrThrow()

            //设置三级缓存策略
            if (let Some(v) <- dropletOption.strategy) {
                builder = builder.setDiskCacheStrategy(v)
            }

            if (let Some(v) <- dropletOption.onlyRetrieveFromCache) {
                builder = builder.onlyRetrieveFromCachecj(v, builder)
            }

            if (let Some(v) <- dropletOption.isSkipMemory) {
                builder = builder.skipMemoryCache(v, builder)
            }

            if (let Some(v) <- dropletOption.thumbnail) {
                builder = builder.thumbnail(v)
            }

            if (let Some(v) <- dropletOption.thumbnaildrawable) {
                builder = builder.thumbnail(v)
            }

            if (let Some(v) <- dropletOption.overrideWH) {
                builder = builder.setOverride(v[0], v[1])
            }

            if (let Some(v) <- dropletOption.transformCate) {
                builder = builder.transform(v)
            }

            if (let Some(v) <- dropletOption.transformListCate) {
                if (v.size > 1) {
                    builder = builder.transforms(v)
                } else if (v.size == 1) {
                    builder = builder.transform(v[0])
                }
            }

              if (let Some(v) <- dropletOption.dontTransform) {
                if (v) {
                    builder = builder.dontTransform(builder)
                }
            }

            if (let Some(v) <- dropletOption.errholder) {
                builder = builder.error(v)
            }

            if (let Some(v) <- dropletOption.applyRequestOption) {
                builder = builder.apply(v)
            }

             if (let Some(v) <- dropletOption.signature) {
                builder = builder.setSignature(StringKey(v))
            }

            builder
                .listener(
                    {
                        drawable: Drawable, model: Model, target: Target<Drawable>, datasource: DataSource, 
                        isFirstResource: Bool => return false
                    },
                    {
                        e: DropletException, model: Model, target: Target<Drawable>, isFirstResource: Bool => return false
                    }
                )
                .into(
                    {
                        p: PixelMap => launch {
                            isLoading = false
                            pixelMap = p
                            AppLog.error("pix 进来主图")

                            if (let Some(i) <- dropletOption.transitionOption) {
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
                    },
                    {
                        cjres: CJResource, isErrorPic: Bool => if (isErrorPic) {
                            launch {
                                isError = true
                                 if (let Some(v) <- dropletOption.errholder) {
                                    this.pixelMap = errorhoderToPiexlMap().getOrThrow()
                                 }
                            }
                        }
                    },
                    width,
                    height
                )
        }
    }

    protected override func aboutToAppear() {
         if (let Some(v) <- dropletOption.placeholder) {
            this.pixelMap = placehoderToPiexlMap().getOrThrow()
        }
    }



    func errorhoderToPiexlMap():?PixelMap{
        if (let Some(v) <- dropletOption.errholder) {
            //这里将他转化为pixleMap
            let resourceManager = ResourceManager.getResourceManager(getStageContext(globalContext.getOrThrow()))
            let arr: Array<UInt8> = resourceManager.getMediaContent(Int32(v.id),0)
            let imageSource:ImageSource =  createImageSource(arr)
            let regionSize: Size = Size(width: imageSource.getImageInfo().size.width, height: imageSource.getImageInfo().size.height)
            let desiredRegion: Region = Region(regionSize, 0, 0)
            let desiredSize: Size = Size(width: imageSource.getImageInfo().size.width, height: imageSource.getImageInfo().size.height)
            let decodingOptions = DecodingOptions(
                rotate: 0, //rotate: UInt32, //旋转角度。
                desiredSize: desiredSize, //desiredSize: Size, //期望输出大小。
                desiredRegion: desiredRegion, //desiredRegion: Region, //解码区域。
                index: 0, //index: Int32, //解码图片序号。
                desiredPixelFormat: PixelMapFormat.RGBA_8888, //解码的像素格式。
                editable: true,
                sampleSize: 1
            )
            return imageSource.createPixelMap(options: decodingOptions)
        }else{
            return Option<PixelMap>.None
        }
    }


    func placehoderToPiexlMap():?PixelMap{
        if (let Some(v) <- dropletOption.placeholder) {
            //这里将他转化为pixleMap
            let resourceManager = ResourceManager.getResourceManager(getStageContext(globalContext.getOrThrow()))
            let arr: Array<UInt8> = resourceManager.getMediaContent(Int32(v.id),0)
            let imageSource:ImageSource =  createImageSource(arr)
            let regionSize: Size = Size(width: imageSource.getImageInfo().size.width, height: imageSource.getImageInfo().size.height)
            let desiredRegion: Region = Region(regionSize, 0, 0)
            let desiredSize: Size = Size(width: imageSource.getImageInfo().size.width, height: imageSource.getImageInfo().size.height) // 548 342
            let decodingOptions = DecodingOptions(
                rotate: 0, //rotate: UInt32, //旋转角度。
                desiredSize: desiredSize, //desiredSize: Size, //期望输出大小。
                desiredRegion: desiredRegion, //desiredRegion: Region, //解码区域。
                index: 0, //index: Int32, //解码图片序号。
                desiredPixelFormat: PixelMapFormat.RGBA_8888, //解码的像素格式。
                editable: true,
                sampleSize: 1
            )
            return imageSource.createPixelMap(options: decodingOptions)

        }else{
            return Option<PixelMap>.None
        }
    }


    func build() {
        Image(this.pixelMap)
            .width(imageViewWidth)
            .height(imageViewHeight)
            .objectFit(imageFit)
            .opacity(opacityValue)
            .rotate(rotateValue)
            .scale(scaleValue)
            .translateX(TranslateValue)
            .onAreaChange(
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
