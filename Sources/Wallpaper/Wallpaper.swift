//
//  Wallpaper.swift
//  WallpaperSplit
//
//  Created by Liyun Xiu on 10/5/20.
//

import Foundation
import AppKit

public enum SetWallpaperMethod {
    case duplicate // set same wallpaper for all monitors
    case across // set wallpaper across all monitors so they look like one
}

public enum SetWallpaperError : Error {
    case fileNotExist
    case setWallpaperFail
    case saveTemporaryImageFileFail
    case unknown
}

public class Wallpaper {
    let workspace = NSWorkspace.shared
    let monitorInfo = MonitorInfo.shared
    let imageCutter = ImageCutter()
    let pathHelper = PathHelper.shared
    let fileManager = FileManager.default
  
    // make initializer public
    public init() {}
    
    // MARK: Set Wallpaper
    // return: Result<successful monitor count, error>
    public func setWallpaper(with wallpaper: String, by method: SetWallpaperMethod = .across) -> Result<Int, SetWallpaperError> {
        guard fileManager.fileExists(atPath: wallpaper) else {
            return .failure(.fileNotExist)
        }
        let wallpaperUrl = NSURL.fileURL(withPath: wallpaper)
        do {
            switch method {
            case .across:
                try setWallpaperAcrossMonitors(wallpaperUrl: wallpaperUrl)
            case .duplicate:
                try setWallpaperDuplicateInMonitors(wallpaperUrl: wallpaperUrl)
            }
        } catch SetWallpaperError.setWallpaperFail, SetWallpaperError.saveTemporaryImageFileFail {
            return .failure(.setWallpaperFail)
        } catch {
            return .failure(.unknown)
        }

        return .success(0)
    }
    
    // MARK: private functions
    private func setWallpaperAcrossMonitors(wallpaperUrl: URL) throws {
        do {
            let m = try imageCutter.cut(wallpaperUrl: wallpaperUrl)
            let options = getSetWallpaperOptions()
            for (screen, wallpaperUrl) in m {
                try clearCurrentWallpaperIfFileExist(screen: screen, wallpaperUrl: wallpaperUrl)
                try setWallpaper(screen: screen, wallpaperUrl: wallpaperUrl, options: options)
            }
        } catch NSImageExtensionError.unwrappingPNGRepresentationFailed {
            throw SetWallpaperError.saveTemporaryImageFileFail
        } catch {
            throw SetWallpaperError.setWallpaperFail
        }
    }
    
    private func setWallpaperDuplicateInMonitors(wallpaperUrl: URL) throws {
        do {
            let options = getSetWallpaperOptions()
            for screen in monitorInfo.screens {
                try clearCurrentWallpaperIfFileExist(screen: screen, wallpaperUrl: wallpaperUrl)
                try setWallpaper(screen: screen, wallpaperUrl: wallpaperUrl, options: options)
            }
        } catch {
            throw SetWallpaperError.setWallpaperFail
        }
    }
    
    private func getSetWallpaperOptions() -> [NSWorkspace.DesktopImageOptionKey: Any] {
        var options = [NSWorkspace.DesktopImageOptionKey: Any]()
        options[.imageScaling] = NSImageScaling.scaleProportionallyUpOrDown.rawValue
        options[.allowClipping] = true
        options[.fillColor] = nil
        return options
    }
    
    // If set wallpaper with same name image, it will fail
    // So we do this hack to set wallpaper to empty first
    private func clearCurrentWallpaperIfFileExist(screen: Screen, wallpaperUrl: URL) throws {
        if !FileManager.default.fileExists(atPath: wallpaperUrl.path) { return }
        try workspace.setDesktopImageURL(URL.init(fileURLWithPath: ""), for: screen.screenRef, options: [:])
        Thread.sleep(forTimeInterval: 0.4)
    }
 
    private func setWallpaper(screen: Screen, wallpaperUrl: URL, options: [NSWorkspace.DesktopImageOptionKey: Any]) throws {
        try workspace.setDesktopImageURL(wallpaperUrl, for: screen.screenRef, options: options)
    }
    
    private func getWallpaper(screen: Screen) -> URL {
        return NSWorkspace.shared.desktopImageURL(for: screen.screenRef)!
    }
}
