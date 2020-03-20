//
//  ScreenshotModel.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/20.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation

struct ScreenshotModel {
    var targetPaths: [String]!
    var width: Float!
    var height: Float!
    
    func isPortrait() -> Bool {
        return height > width
    }
}
