//
//  ImageState.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/17.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation

protocol ImageStateProtocol: BaseStateProtocol {
}

class DownloadingImageState: ImageStateProtocol {
}

class DownloadImageState: ImageStateProtocol {
    let data: Data
    init(data: Data) {
        self.data = data
    }
}

class IdleImageState: ImageStateProtocol {
}

class ErrorImageState: ImageStateProtocol {
    let error: NSError
    init(error: NSError) {
        self.error = error
    }
}
