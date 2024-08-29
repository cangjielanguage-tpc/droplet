/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights resvered.
 */
 
package droplet.droplet



public enum ModelType {
    ARRAY | STRING | FILE | GIFDECODER | NONE
}

public abstract class Model <: DropletAny<Model> {
    public var arr: Array<UInt8> = Array<UInt8>()
    public var str: String = ""
    public var file: DropletFile = DropletFile("")
    public var decoder: Option<GifDecoder> = None
    public var modelType: ModelType = ModelType.NONE

    init(arr: Array<UInt8>) {
        this.arr = arr
        this.modelType = ModelType.ARRAY
    }

    init(str: String) {
        this.str = str
        this.modelType = ModelType.STRING
    }

    init(file: FSPath) {
        this.file = DropletFile(file)
        this.modelType = ModelType.FILE
    }

    init(file: File) {
        this.file = DropletFile(file)
        this.modelType = ModelType.FILE
    }

    init(decoder: GifDecoder) {
        this.decoder = Some(decoder)
        this.modelType = ModelType.GIFDECODER
    }

    public func toString(): String {
        match(modelType) {
            case ModelType.ARRAY => "modeltype: ${this.arr}"
            case ModelType.STRING => "modeltype: ${this.str}"
            case ModelType.FILE => "modeltype: ${this.file}"
            case ModelType.GIFDECODER => "modeltype: ${this.file}"
            case ModelType.NONE => "modeltype: NONE"
        }
    }

    public func hashCode(): Int64 {
        match(modelType) {
            case ModelType.ARRAY => Utils.hashCode<UInt8>(this.arr)
            case ModelType.STRING => this.str.hashCode()
            case ModelType.FILE => this.file.hashCode()
            case ModelType.GIFDECODER => 0i64
            case ModelType.NONE => 0i64
        }
    }

    public operator func ==(that: Model): Bool {
        if(that is LoadModel) {
            var t = (that as LoadModel).getOrThrow()
            return this.arr == t.arr && this.str == t.str && this.file == t.file
        }
        return false
    }

    public operator func !=(that: Model): Bool {
        if(that is LoadModel) {
            var t = (that as LoadModel).getOrThrow()
            return !(this.arr == t.arr && this.str == t.str && this.file == t.file)
        }
        return true
    }

    func getDataSource(): DataSource {
        match(modelType) {
            case ModelType.ARRAY => DataSource.LOCAL
            case ModelType.STRING => 
                if(str.startsWith("/")) {
                    DataSource.LOCAL
                } else if(str.startsWith("http")) {
                    DataSource.REMOTE
                } else {
                    DataSource.LOCAL
                }
            case ModelType.FILE => DataSource.LOCAL
            case ModelType.GIFDECODER => DataSource.LOCAL
            case ModelType.NONE => DataSource.NONE
        }
    }

}

public class LoadModel <: Model {
    init(arr: Array<UInt8>) {
        super(arr)
    }

    init(str: String) {
        super(str)
    }

    init(file: FSPath) {
        super(file)
    }

    init(file: File) {
        super(file)
    }
}
