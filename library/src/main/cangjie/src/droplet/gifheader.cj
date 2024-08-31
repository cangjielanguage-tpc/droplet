/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights resvered.
 */

package droplet.droplet

/**
 * A header object containing the number of frames in an animated GIF image as well as basic
 * metadata like width and height that can be used to decode each individual frame of the GIF. Can
 * be shared by one or more {@link com.bumptech.droplet.gifdecoder.GifDecoder}s to play the same
 * animated GIF in multiple views.
 *
 */
public class GifHeader {

  /** The "Netscape" loop count which means loop forever. */
  public static let NETSCAPE_LOOP_COUNT_FOREVER :Int32 = 0
  /** Indicates that this header has no "Netscape" loop count. */
  public static let NETSCAPE_LOOP_COUNT_DOES_NOT_EXIST:Int32 = -1

  var gct:Array<UInt32> = Array<UInt32>()

  var status:Int32 = GifDecoder.STATUS_OK
  var frameCount:Int32 = 0

  var currentFrame:GifFrame = GifFrame()
  var frames: ArrayList<GifFrame>  = ArrayList<GifFrame>()
  /** Logical screen size: Full image width. */
  var width:Int32 =0
  /** Logical screen size: Full image height. */
  var height:Int32=0

  // 1 : global color table flag.
  var gctFlag:Bool = false
  /**
   * Size of Global Color Table.
   * The value is already computed to be a regular number, this field doesn't store the exponent.
   */
  var gctSize:Int32 =0
  /** Background color index into the Global/Local color table. */
  var bgIndex:Int32 =0
  /**
   * Pixel aspect ratio.
   * Factor used to compute an approximation of the aspect ratio of the pixel in the original image.
   */
  var pixelAspect:Int32 = 0
  var bgColor:UInt32 = 0
  var loopCount:Int32 = NETSCAPE_LOOP_COUNT_DOES_NOT_EXIST

   func getHeight(): Int32 {
    return height;
  }

   func getWidth():Int32 {
    return width;
  }
   func setHeight(val:Int32)  {
    height = val
  }

   func setWidth(val:Int32) {
    width = val
  }
   func getNumFrames():Int32 {
    return frameCount;
  }

  /**
   * Global status code of GIF data parsing.
   */
   func getStatus():Int32 {
    return status;
  }
   func getGctFlag():Bool{
    return gctFlag
  }

   func getGctSize():Int32{
    return gctSize
  }
  /** Background color index into the Global/Local color table. */
   func getBgIndex():Int32{
    return bgIndex
  }
  /**
   * Pixel aspect ratio.
   * Factor used to compute an approximation of the aspect ratio of the pixel in the original image.
   */
   func getPixelAspect():Int32{
    return pixelAspect
  }
   func getBgColor():UInt32{
    return bgColor
  }
   func getLoopCount():Int32{
    return loopCount
  }
   func setLoopCount(val:Int32){
    loopCount = val
  }
   func getFrameCount():Int32{
    return frameCount
  }
   func setFrameCount(val:Int32){
    frameCount = val
  }
   func getCurrentFrame():GifFrame {
    return currentFrame
  }
   func getFrames(): ArrayList<GifFrame>{
    return frames
  }

}
