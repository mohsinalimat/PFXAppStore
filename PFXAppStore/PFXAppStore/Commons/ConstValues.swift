//
//  ConstValues.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/16.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import UIKit

struct ConstStrings {
    static let basePath = "https://itunes.apple.com"
    static let sqliteFileName = "PFXAppStore.sqlite"
}

struct Size {
    var width: Float = 0
    var height: Float = 0
    
    func isPortrait() -> Bool {
        return self.height > self.width
    }
}

struct ConstNumbers {
    static let maxLoadLimit = 30
    static let maxTermLength = 32
    static let maxHistoryLength = 32
    static let maxRecentHistoryCount = 10
    static let artworkImageViewRound: Float = 5
    static let appStoreImageViewRound: Float = 5
    static let buttonRound: Float = 5
    // phone : 392x696
    // pad : 576x768
    static let portraitPhoneImageCellSize = Size(width: 170, height: 300)
    static let landscapePhoneImageCellSize = Size(width: 300, height: 170)
    static let portraitPadImageCellSize = Size(width: 225, height: 300)
    static let landscapePadImageCellSize = Size(width: 300, height: 225)
    static let portraitPhoneImageSize = Size(width: 225, height: 400)
    static let landscapePhoneImageSize = Size(width: 400, height: 225)
    static let portraitPadImageSize = Size(width: 300, height: 400)
    static let landscapePadImageSize = Size(width: 400, height: 300)
}

struct ConstColors {
    static let rateColorRange = (
//        UIColor(red: 218 / 255, green: 56 / 255, blue: 81 / 255, alpha: 1),
//        UIColor(red: 87 / 255, green: 173 / 255, blue: 175 / 255, alpha: 1)
        UIColor(red: 121 / 255, green: 40 / 255, blue: 65 / 255, alpha: 1),
        UIColor(red: 228 / 255, green: 125 / 255, blue: 121 / 255, alpha: 1)
    )
}
