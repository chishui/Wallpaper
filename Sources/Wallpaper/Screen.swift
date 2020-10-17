//
//  Screen.swift
//  WallpaperSplit
//
//  Created by Liyun Xiu on 10/5/20.
//

import Foundation
import AppKit

struct Screen: Hashable {
    let screenRef: NSScreen
    private(set) var name: String
    let frame: NSRect
    
    init(with screen: NSScreen) {
        self.screenRef = screen
        self.frame = screen.frame
        //self.name = ""
        if #available(macOS 10.15, *) {
            self.name = screen.localizedName
        } else {
            self.name = Screen.getScreenName(screen: screen) ?? ""
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func getScreenName(screen: NSScreen) -> String? {
        let displayId = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as! CGDirectDisplayID
        var name: String? = nil
        var object : io_object_t
        var serialPortIterator = io_iterator_t()
        let matching = IOServiceMatching("IODisplayConnect")
        let kernResult = IOServiceGetMatchingServices(kIOMasterPortDefault, matching, &serialPortIterator)
        if KERN_SUCCESS == kernResult && serialPortIterator != 0 {
            repeat {
                object = IOIteratorNext(serialPortIterator)
                let info = IODisplayCreateInfoDictionary(object, UInt32(kIODisplayOnlyPreferredName)).takeRetainedValue() as NSDictionary as! [String:AnyObject]
                if (info["DisplayVendorID"] as! UInt32) == CGDisplayVendorNumber(displayId), (info["DisplayProductID"] as! UInt32) == CGDisplayModelNumber(displayId) {
                    if let productName = info["DisplayProductName"] as? [String:String],
                    let firstKey = Array(productName.keys).first {
                        name = productName[firstKey]!
                        break
                    }
                }
            } while object != 0
        }
        IOObjectRelease(serialPortIterator)
        return name
    }
}
