//
//  ImageEvent.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/17.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import RxSwift

protocol ImageEventProtocol: BaseEventProtocol {
}

class DownloadImageEvent: ImageEventProtocol {
    var disposeBag = DisposeBag()
    let targetPath: String
    var imageProvider: ImageProviderProtocol = ImageProvider()
    
    init(targetPath: String) {
        self.targetPath = targetPath
    }

    deinit {
        self.disposeBag = DisposeBag()
    }
    
    func applyAsync<Element>() -> Observable<Element> {
        return PublishSubject<BaseStateProtocol>.create { [weak self] observer -> Disposable in
            guard let self = self else {
                observer.onError(NSError(domain: "\(#function) : \(#line)", code: PBError.system_deallocated.rawValue, userInfo: nil))
                return Disposables.create()
            }
            
            observer.on(.next(DownloadingImageState()))
            self.imageProvider.requestImageData(targetPath: self.targetPath)
                .subscribe(onSuccess: { data in
                    defer {
                        self.sendIdleState(observer: observer)
                    }

                    observer.onNext(DownloadImageState(data: data))
                }) { error in
                    observer.onNext(ErrorImageState(error: error as NSError))
                    self.sendIdleState(observer: observer)
                }
                .disposed(by: self.disposeBag)
            return Disposables.create()
            } as! Observable<Element>
    }
    
    func sendIdleState(observer: AnyObserver<BaseStateProtocol>) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            observer.onNext(IdleImageState())
        }
    }
}
