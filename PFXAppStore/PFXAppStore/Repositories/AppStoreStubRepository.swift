//
//  AppStoreStubRepository.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/16.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import RxSwift

class AppStoreStubRepository: AppStoreProtocol {
    func request(targetPath: String, parameterDict: [String : String]) -> Observable<Data> {
        return Observable.create { observer in
            return Disposables.create()
        }
    }
}
