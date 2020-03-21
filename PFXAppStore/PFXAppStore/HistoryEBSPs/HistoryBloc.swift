//
//  HistoryBloc.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/21.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class HistoryBloc: BaseBlocProtocol {
    var currentState: BaseStateProtocol? = IdleHistoryState()
    
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
                guard let state = state as? HistoryStateProtocol else {
                    return
                }
                
                self.currentState = state
                self.stateRelay.accept(state)
            }, onError: { [weak self] error in
                guard let self = self else { return }
                self.stateRelay.accept(ErrorHistoryState(error: error as NSError))
            })
            .disposed(by: self.disposeBag)
    }
}
