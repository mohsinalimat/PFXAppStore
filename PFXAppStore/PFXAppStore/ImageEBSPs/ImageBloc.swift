//
//  ImageBloc.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/17.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class ImageBloc: BaseBlocProtocol {
    var currentState: BaseStateProtocol? = IdleImageState()
    
    let stateRelay = PublishRelay<BaseStateProtocol>()
    var disposeBag = DisposeBag()
    
    init() {
    }
    
    deinit {
        self.disposeBag = DisposeBag()
    }

    func dispatch(event: BaseEventProtocol) {
        event.applyAsync()
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                guard let imageState = state as? ImageStateProtocol else {
                    return
                }
                
                self.currentState = imageState
                self.stateRelay.accept(imageState)
            }, onError: { [weak self] error in
                guard let self = self else { return }
                self.stateRelay.accept(ErrorImageState(error: error as NSError))
            })
            .disposed(by: self.disposeBag)
    }
    
}
