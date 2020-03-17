//
//  ImageProvider.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/17.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import RxSwift

protocol ImageProviderProtocol: BaseProviderProtocol {
    func requestImageData(targetPath: String) -> Single<Data>
}

class ImageProvider: ImageProviderProtocol {
    var disposeBag = DisposeBag()
    var client: ClientProtocol = DependencyInjection.shared.currentClient()
    
    deinit {
        self.disposeBag = DisposeBag()
    }

    func requestImageData(targetPath: String) -> Single<Data> {
        return Single<Data>.create { [weak self] single in
            guard let self = self else {
                single(.error(NSError(domain: "\(#function) : \(#line)", code: PBError.system_deallocated.rawValue, userInfo: nil)))
                return Disposables.create()
            }
            
            if targetPath.count <= 0 {
                single(.error(NSError(domain: "\(#function) : \(#line)", code: PBError.network_invalid_parameter.rawValue, userInfo: nil)))
                return Disposables.create()
            }
            
            self.client.requestImageData(targetPath: targetPath)
                .subscribe(onNext: { data in
                    if data.count <= 0 {
                        single(.error(NSError(domain: "\(#function) : \(#line)", code: PBError.network_invalid_response_data.rawValue, userInfo: nil)))
                        return
                    }
                    
                    single(.success(data))
                }, onError: { error in
                    single(.error(error))
                })
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
   
}
