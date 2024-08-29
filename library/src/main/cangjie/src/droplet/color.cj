/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights resvered.
 */
 
package droplet.droplet

public class Color{
     static func red(val:UInt32):UInt32 {
        return (val >> 16) & 0xFF;
    }


     static func green(val:UInt32):UInt32 {
        return (val >> 8) & 0xFF;
    }


     static func blue(val:UInt32):UInt32 {
        return (val >> 0) & 0xFF;
    }


     static func alpha(val:UInt32):UInt32 {
        return (val >> 24) & 0xff;
    }
    public static let TRANSPARENT:UInt32 = (0xFF >> 24)
}