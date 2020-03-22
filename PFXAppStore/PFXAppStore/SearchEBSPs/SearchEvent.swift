//
//  SearchEvent.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/16.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import RxSwift

protocol SearchEventProtocol: BaseEventProtocol {
}

class FetchingSearchEvent: SearchEventProtocol {
    var disposeBag = DisposeBag()
    let parameterDict: [String : String]
    var searchProvider: SearchProviderProtocol = SearchProvider()
    
    init(parameterDict: [String : String]) {
        self.parameterDict = parameterDict
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
            
            observer.on(.next(FetchingSearchState()))
            self.searchProvider.fetchingSearch(parameterDict: self.parameterDict)
                .subscribe(onSuccess: { [weak self] appStoreResponseModel in
                    guard let self = self else { return }
                    defer {
                        self.sendIdleState(observer: observer)
                    }
                    
                    guard let term = self.parameterDict["term"], let offset = self.parameterDict["offset"] else {
                        return
                    }
                    
                    if appStoreResponseModel.resultCount == 0 && Int(offset) == 0 {
                        observer.onNext(EmptySearchState(text: term))
                        return
                    }

                    observer.onNext(FetchedSearchState(appStoreResponseModel: appStoreResponseModel))
                }) { error in
                    observer.onNext(ErrorSearchState(error: error as NSError))
                    self.sendIdleState(observer: observer)
                }
                .disposed(by: self.disposeBag)
            return Disposables.create()
            } as! Observable<Element>
    }
    
    func sendIdleState(observer: AnyObserver<BaseStateProtocol>) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            observer.onNext(IdleSearchState())
        }
    }
}
