//
//  PathHelper.swift
//  WallpaperSplit
//
//  Created by Liyun Xiu on 10/8/20.
//

import Foundation

// Singleton
class PathHelper {
    static let shared = PathHelper()
    let fileManager = FileManager.default
    private init() {}
    
    func getApplicationFolder() -> URL? {
        let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let displayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "OneWallpaper"
        //  Create subdirectory
        let directoryURL = appSupportURL.appendingPathComponent(displayName)
        if !fileManager.fileExists(atPath: directoryURL.path) {
            do {
                try fileManager.createDirectory (at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("create directory \(directoryURL) failed! \(error)")
                return nil
            }
        }
        return directoryURL
    }
    
    func getImageFolder() -> URL?{
        guard let appFolder = getApplicationFolder() else { return nil }
        let imageTempFolder = appFolder.appendingPathComponent("wallpaper")
        if !fileManager.fileExists(atPath: imageTempFolder.path) {
            do {
                try fileManager.createDirectory (at: imageTempFolder, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("create directory \(imageTempFolder) failed! \(error)")
                return nil
            }
        }
        return imageTempFolder
    }
    
    func delete(file: URL) {
        if !fileManager.fileExists(atPath: file.path) { return }
        do {
            try fileManager.removeItem(atPath: file.path)
        } catch {
            print("remove file \(file) failed! \(error)")
        }
    }
}
