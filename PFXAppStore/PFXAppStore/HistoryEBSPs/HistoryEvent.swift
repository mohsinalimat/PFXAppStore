//
//  HistoryEvent.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/21.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import RxSwift

protocol HistoryEventProtocol: BaseEventProtocol {
}

class RecentHistoryEvent: HistoryEventProtocol {
    var disposeBag = DisposeBag()
    let isAscending: Bool
    let limit: Int
    var historyProvider: HistoryProviderProtocol = HistoryProvider()
    
    init(isAscending: Bool, limit: Int) {
        self.isAscending = isAscending
        self.limit = limit
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
            
            observer.on(.next(FetchingHistoryState()))
            self.historyProvider.recent(isAscending: self.isAscending, limit: self.limit)
                .subscribe(onSuccess: { [weak self] datas in
                    guard let self = self else { return }
                    defer {
                        self.sendIdleState(observer: observer)
                    }

                    observer.onNext(RecentHistoryState(datas: datas))
                }) { error in
                    observer.onNext(ErrorHistoryState(error: error as NSError))
                    self.sendIdleState(observer: observer)
                }
                .disposed(by: self.disposeBag)
            return Disposables.create()
            } as! Observable<Element>
    }
    
    func sendIdleState(observer: AnyObserver<BaseStateProtocol>) {
        observer.onNext(IdleHistoryState())
    }
}

class AllHistoryEvent: HistoryEventProtocol {
    var disposeBag = DisposeBag()
    let text: String
    var historyProvider: HistoryProviderProtocol = HistoryProvider()
    
    init(text: String) {
        self.text = text
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
            
            observer.on(.next(FetchingHistoryState()))
            self.historyProvider.all(text: self.text)
                .subscribe(onSuccess: { [weak self] datas in
                    guard let self = self else { return }
                    defer {
                        self.sendIdleState(observer: observer)
                    }

                    observer.onNext(AllHistoryState(datas: datas))
                }) { error in
                    observer.onNext(ErrorHistoryState(error: error as NSError))
                    self.sendIdleState(observer: observer)
                }
                .disposed(by: self.disposeBag)
            return Disposables.create()
            } as! Observable<Element>
    }
    
    func sendIdleState(observer: AnyObserver<BaseStateProtocol>) {
        observer.onNext(IdleHistoryState())
    }
}


class UpdateHistoryEvent: HistoryEventProtocol {
    var disposeBag = DisposeBag()
    let historyModel: HistoryModel
    var historyProvider: HistoryProviderProtocol = HistoryProvider()
    
    init(historyModel: HistoryModel) {
        self.historyModel = historyModel
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
            
            observer.on(.next(FetchingHistoryState()))
            self.historyProvider.update(model: self.historyModel)
                .subscribe(onCompleted: {
                    defer {
                        self.sendIdleState(observer: observer)
                    }

                    observer.onNext(CompletedHistoryState())
                }, onError: { error in
                    observer.onNext(ErrorHistoryState(error: error as NSError))
                    self.sendIdleState(observer: observer)
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
            } as! Observable<Element>
    }
    
    func sendIdleState(observer: AnyObserver<BaseStateProtocol>) {
        observer.onNext(IdleHistoryState())
    }
}

class DeleteHistoryEvent: HistoryEventProtocol {
    var disposeBag = DisposeBag()
    let historyModel: HistoryModel
    var historyProvider: HistoryProviderProtocol = HistoryProvider()
    
    init(historyModel: HistoryModel) {
        self.historyModel = historyModel
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
            
            observer.on(.next(FetchingHistoryState()))
            self.historyProvider.delete(model: self.historyModel)
                .subscribe(onCompleted: {
                    defer {
                        self.sendIdleState(observer: observer)
                    }

                    observer.onNext(CompletedHistoryState())
                }, onError: { error in
                    observer.onNext(ErrorHistoryState(error: error as NSError))
                    self.sendIdleState(observer: observer)
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
            } as! Observable<Element>
    }
    
    func sendIdleState(observer: AnyObserver<BaseStateProtocol>) {
        observer.onNext(IdleHistoryState())
    }
}
