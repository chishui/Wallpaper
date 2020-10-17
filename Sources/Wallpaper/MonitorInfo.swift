//
//  MonitorInfo.swift
//  WallpaperSplit
//
//  Created by Liyun Xiu on 10/4/20.
//

import Foundation
import AppKit

// Singleton
class MonitorInfo {
    static let shared = MonitorInfo()
    let workspace = NSWorkspace.shared
    private(set) var screens: [Screen] = []
    private(set) var frames: [NSRect] = []
    
    private init() {
        loadScreen()
    }

    public func getFrame() -> NSRect? {
        var unionFrame : NSRect?
        for screen in NSScreen.screens {
            if unionFrame == nil {
                unionFrame = screen.frame
            } else {
                unionFrame = unionFrame!.union(screen.frame)
            }
        }
        return unionFrame
    }

    public func loadScreen() {
        for screen in NSScreen.screens {
            self.screens.append(Screen(with: screen))
        }
    }
}
