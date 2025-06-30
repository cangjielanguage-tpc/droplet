/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2025. All rights reserved.
 */
 
package droplet.droplet



public class DropletString <: AnyDropletOptionValue & DropletAny<DropletString> {
  public let str: String
  public init(str: String) {
    this.str = str
  }
  public func toString(): String {
    return str
  }

  public operator func ==(that: AnyDropletOptionValue): Bool {
    if(that is DropletString) {
        return this.str == (that as DropletString).getOrThrow().str
    }
    return false
  }

  public operator func !=(that: AnyDropletOptionValue): Bool {
    if(that is DropletString) {
        return this.str != (that as DropletString).getOrThrow().str
    }
      return true
  }

  public operator func ==(that: DropletString): Bool {
    return this.str == that.str
  }

  public operator func !=(that: DropletString): Bool {
    return this.str != that.str
  }

  public func hashCode(): Int64 {
      return this.str.hashCode()
  }
}

public class DropletInt <: AnyDropletOptionValue {

    public var key: Int64 = 0
    public init(key: Int64) {
        this.key = key
    }

    public operator func ==(that: AnyDropletOptionValue): Bool {
        if(that is DropletInt) {
            return key == (that as DropletInt).getOrThrow().key
        }
        return false;
    }

    public operator func !=(that: AnyDropletOptionValue): Bool {
        if(that is DropletInt) {
            return key != (that as DropletInt).getOrThrow().key
        }
        return true
    }

    public func hashCode(): Int64 {
        return key.hashCode()
    }

    public func toString(): String {
        return "Option{key=${key}}";
    }
}

public interface AnyDropletOptionValue <: DropletAny<AnyDropletOptionValue> {

}

public interface DropletAny<K> <: ToString & Equatable<K> & Hashable {
}

public class DropletFile <: DropletAny<DropletFile> {
    public var filePath: FSPath
    public var file: Option<File> = None
    public var directory: Option<Directory> = None
    public var stringWriter: Option<StringWriter<File>> = None
    public var stringReader: Option<StringReader<File>> = None
    private let mtx = ReentrantMutex()

    public init(){
        this.filePath = FSPath("")
    }

    public init(path: FSPath) {
        this.filePath = path
    }

    public init(file: File) {
        this.filePath = file.info.path
        this.file = Some(file)
    }

    public init(path: String) {
        this(FSPath(path))
    }
    
    public init(parent: String, child: String) {
        this("${parent}/${child}")
    }

    public init(parent: DropletFile, child: String) {
        this(parent.filePath.join(child))
    }

    public init(parent: DropletFile, child: FSPath) {
        this(parent.filePath.join(child))
    }

    func openFile() {
        if(Directory.exists(this.filePath) && this.filePath.isDirectory()) {
            this.directory = Some(Directory(this.filePath))
        } else if(File.exists(this.filePath) && this.filePath.isFile()) {
            this.file = Some(File(this.filePath, OpenOption.Open(true, true)))
        } else if(!File.exists(this.filePath)) {
            this.file = Some(File(this.filePath, OpenOption.Create(true)))
        } else {
            throw Exception("openFile: error  file path ${this.filePath}")
        }
    }

     func safeOpenFile() {
        if(let Some(i) <- this.file){
            if(i.isClosed()) {
                openFile()
            }
        }else{
            openFile()
        }
    }

     func close(): Unit {
        if(!this.file.getOrThrow().isClosed()) {
            this.file.getOrThrow().close()
        }
    }

     func getStringReader(): StringReader<File> {
        safeOpenFile()
        return StringReader(this.file.getOrThrow())
    }

     func getStringWriter(): StringWriter<File> {
        safeOpenFile()
        this.file.getOrThrow().seek(SeekPosition.End(0))
        return StringWriter(this.file.getOrThrow())
    }

     func getFile(): File {
        safeOpenFile()
        this.file.getOrThrow().seek(SeekPosition.End(0))
        return this.file.getOrThrow()
    }

     func getFileNoSeek(): File {
        safeOpenFile()
        return this.file.getOrThrow()
    }

     func toByteArrayStream(): ByteArrayStream {
        synchronized (mtx) {
            let outStream: ByteArrayStream = ByteArrayStream()
            safeOpenFile()
            this.file.getOrThrow().copyTo(outStream)
            this.file.getOrThrow().close()
            return outStream
        }
    }

     func length(): Int64 {
        return FileInfo(this.filePath).length
    }

     func isDirectory(): Bool {
        let r = Directory.exists(this.filePath) && this.filePath.isDirectory()
        return r
    }

     func isFile(): Bool {
        return File.exists(this.filePath) && this.filePath.isFile()
    }

     func exists(): Bool {
        if(Directory.exists(this.filePath)) {
            return true
        } else if(File.exists(this.filePath)) {
            return true
        }
        return false
    }

    func delete(): Bool {
        if (isFile()) {
            if (let Some(i) <- this.file) {
                i.close()
            }
            File.delete(this.filePath)
            return true
        } else if (isDirectory()) {
            if (let Some(i) <- this.directory) {
                Directory.delete(this.filePath)
                return true
            }
        }
        return false
    }

     func renameTo(to: DropletFile): Bool {
        if(!isFile()) {
            return false
        }
        try {
            File.move(this.filePath, to.filePath, false)
        } catch(e: Exception) {
            return false
        }

        return true
    }

     func mkdirs(): Bool {
        if(isFile()) {
            return false
        }
        if(!Directory.exists(this.filePath)) {
            this.directory = Some(Directory.create(this.filePath, recursive: true))
            return true
        }
        return false
    }

    public func toString(): String {
        return this.filePath.toString()
    }

    public func hashCode(): Int64 {
        return this.filePath.hashCode()
    }

    public operator func ==(that: DropletFile): Bool {
        return this.filePath == that.filePath
    }

    public operator func !=(that: DropletFile): Bool {
        return this.filePath != that.filePath
    }


}
