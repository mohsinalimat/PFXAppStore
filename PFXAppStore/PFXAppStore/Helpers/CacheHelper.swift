//
//  CacheHelper.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/17.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation

class CacheHelper {
    let imageDatas = NSCache<NSString, NSData>()
    static let shared = CacheHelper()
}
