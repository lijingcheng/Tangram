//
//  FileManagerExt.swift
//  Tangram
//
//  Created by 李京城 on 2019/9/17.
//  Copyright © 2019 李京城. All rights reserved.
//

import Foundation

extension FileManager {
    /// 根据参数返回该文件在 documents 目录下的的全路径
    public static func documentsDirectoryPath(_ fileName: String) -> String {
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        var url = URL(fileURLWithPath: documents, isDirectory: true)
        
        do {
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try url.setResourceValues(resourceValues)
        } catch {
            print("Error: failed to set resource value.")
        }
        
        return url.appendingPathComponent(fileName).path
    }
    
    /// 根据参数返回该文件在 cache/download 目录下的的全路径
    public static func downloadDirectoryPath(_ fileName: String) -> String {
        return caches("download").appendingPathComponent(fileName).path
    }
    
    /// 根据参数返回该文件在 cache/image 目录下的的全路径
    public static func imageDirectoryPath(_ fileName: String) -> String {
        return caches("image").appendingPathComponent(fileName).path
    }
    
    /// 写文件
    @discardableResult
    public static func writeCacheData(_ data: Any?, atPath path: String?) -> Bool {
        if let cacheData = data, let path = path {
            if #available(iOS 12.0, *) {
                try? NSKeyedArchiver.archivedData(withRootObject: cacheData, requiringSecureCoding: false).write(to: URL(fileURLWithPath: path))
                
                return true
            } else {
                return NSKeyedArchiver.archiveRootObject(cacheData, toFile: path)
            }
        }
        
        return false
    }
    
    /// 读文件
    public static func readCacheData(_ path: String?) -> Any? {
        if FileManager.default.fileExists(atPath: path ?? "") {
            if #available(iOS 12.0, *) {
                return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(Data(contentsOf: URL(fileURLWithPath: path!)))
            } else {
                return try? NSKeyedUnarchiver.unarchiveObject(with: Data(contentsOf: URL(fileURLWithPath: path!)))
            }
        }
        
        return nil
    }
    
    /// 删文件
    public static func removeFile(_ path: String?) {
        if FileManager.default.fileExists(atPath: path ?? "") {
            try? FileManager.default.removeItem(atPath: path!)
        }
    }
    
    // MARK: -
    private static func caches(_ folderName: String) -> URL {
        let caches = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let folder = URL(fileURLWithPath: caches).appendingPathComponent(folderName).absoluteString
        
        if !FileManager.default.fileExists(atPath: folder) {
            try? FileManager.default.createDirectory(atPath: folder, withIntermediateDirectories: true, attributes: nil)
        }
        
        return URL(fileURLWithPath: folder)
    }
}
