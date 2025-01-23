/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */
 
package droplet.droplet


public class Manager {
    private var mtx: ReentrantMutex
    // modelloaders
    private let stringModelLoaders: ArrayList<ModelLoader> = ArrayList<ModelLoader>()
    private let fileModelLoaders: ArrayList<ModelLoader> = ArrayList<ModelLoader>()
    private let resourceModelLoaders: ArrayList<ModelLoader> = ArrayList<ModelLoader>()

    // decoders
    private let drawableResourceDecoders: ArrayList<ResourceDecoder<Array<UInt8>, Drawable>> = ArrayList<ResourceDecoder<Array<UInt8>, Drawable>>()
    private let pixelMapResourceDecoders: ArrayList<ResourceDecoder<Array<UInt8>, PixelMap>> = ArrayList<ResourceDecoder<Array<UInt8>, PixelMap>>()

    private let drawableResourceParser: PixelMapDrawableResourceParser = PixelMapDrawableResourceParser()

    public init(mtx: ReentrantMutex) {
        this.mtx = mtx
        this.stringModelLoaders.append(StringModelLoader())
        this.resourceModelLoaders.append(ResourceModelLoader())
        this.fileModelLoaders.append(FileModelLoader())

        this.drawableResourceDecoders.append(PixelMapDrawableResourceDecoder())
        this.drawableResourceDecoders.append(GifDrawableResourceDecoder())

        this.pixelMapResourceDecoders.append(PixelMapResourceDecoder())
    }

     func getStringModelLoaders(): ArrayList<ModelLoader> {
        synchronized (mtx) {
            return stringModelLoaders
        }
    }

      func getResourceModelLoaders(): ArrayList<ModelLoader> {
        synchronized (mtx) {
            return resourceModelLoaders
        }
    }

     func getFileModelLoaders(): ArrayList<ModelLoader> {
        synchronized (mtx) {
            return fileModelLoaders
        }
    }

     func setStringModelLoader(modelLoader: ModelLoader): Unit {
        synchronized (mtx) {
            this.stringModelLoaders.clear()
            this.stringModelLoaders.append(modelLoader)
        }
    }

    func setResourceModelLoader(modelLoader: ModelLoader): Unit {
        synchronized (mtx) {
            this.resourceModelLoaders.clear()
            this.resourceModelLoaders.append(modelLoader)
        }
    }

     func setFileModelLoader(modelLoader: ModelLoader): Unit {
        synchronized (mtx) {
            this.fileModelLoaders.clear()
            this.fileModelLoaders.append(modelLoader)
        }
    }

     func addDrawableResourceDecoder(decoder: ResourceDecoder<Array<UInt8>, Drawable>): Unit {
        synchronized (mtx) {
            this.drawableResourceDecoders.append(decoder)
        }
    }

     func getDrawableResourceParser(): ResourceDecoder<Array<UInt8>, Drawable> {
        synchronized (mtx) {
            return drawableResourceParser
        }
    }

     func getDrawableResourceDecoders(): ArrayList<ResourceDecoder<Array<UInt8>, Drawable>> {
        synchronized (mtx) {
            return this.drawableResourceDecoders
        }
    }

     func addPixelMapResourceDecoder(decoder: ResourceDecoder<Array<UInt8>, PixelMap>): Unit {
        synchronized (mtx) {
            this.pixelMapResourceDecoders.append(decoder)
        }
    }

     func getPixelMapResourceDecoders(): ArrayList<ResourceDecoder<Array<UInt8>, PixelMap>> {
        synchronized (mtx) {
            return this.pixelMapResourceDecoders
        }
    }

}
