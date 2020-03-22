//
//  FileCacheHelper.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/17.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation

class FileCacheHelper {
    static let shared = FileCacheHelper()
    
    func cacheDirectory() -> URL {
        let urls = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
        var library = urls.last!
        library.appendPathComponent("imageCaches")
        do {
            try FileManager.default.createDirectory(at: library, withIntermediateDirectories: true, attributes: nil)
        }
        catch {
            
        }
        
        return library
    }


    func loadImageData(folderName: String, key: String) -> Data? {
        let encodingKey = key.replacingOccurrences(of: "/", with: "(@)")
        let folderPath = self.cacheDirectory().appendingPathComponent(folderName)
        do {
            try FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: true, attributes: nil)
        }
        catch {
            return nil
        }

        let filePath = self.cacheDirectory().absoluteString.appending("\(folderName)/\(encodingKey)")
        guard let fileUrl = URL(string: filePath) else {
            return nil
        }

        if FileManager.default.fileExists(atPath: fileUrl.path) {
            do {
                let data = try Data(contentsOf: fileUrl)
                return data
            }
            catch {
                
                return nil
            }
        }
        
        return nil
    }
    
    func saveImageData(folderName: String, key: String, data: Data) -> NSError? {
        let encodingKey = key.replacingOccurrences(of: "/", with: "(@)")
        let folderPath = self.cacheDirectory().appendingPathComponent(folderName)
        do {
            try FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: true, attributes: nil)
        }
        catch {
            return NSError(domain: "\(#function) : \(#line)", code: PBError.filedata_invalid_folderPath.rawValue, userInfo: nil)
        }

        let filePath = self.cacheDirectory().absoluteString.appending("\(folderName)/\(encodingKey)")
        guard let fileUrl = URL(string: filePath) else {
            return nil
        }
        
        do {
            try data.write(to: fileUrl)
            return nil
        }
        catch {
            return NSError(domain: "\(#function) : \(#line)", code: PBError.filedata_invalid_filepath.rawValue, userInfo: nil)
        }
    }
}
