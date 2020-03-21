//
//  HistoryProvider.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/21.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

protocol HistoryProviderProtocol: BaseProviderProtocol {
    func recent(isAscending: Bool, limit: Int) -> Single<[HistoryModel]>
    func update(model: HistoryModel) -> Completable
    func all(text: String) -> Single<[HistoryModel]>
    func delete(model: HistoryModel) -> Completable
}

class HistoryProvider: HistoryProviderProtocol {
    var disposeBag = DisposeBag()

    deinit {
        self.disposeBag = DisposeBag()
    }

    func recent(isAscending: Bool, limit: Int) -> Single<[HistoryModel]> {
        return Single<[HistoryModel]>.create { [weak self] single in
            guard let self = self else {
                single(.error(NSError(domain: "\(#function) : \(#line)", code: PBError.system_deallocated.rawValue, userInfo: nil)))
                return Disposables.create()
            }
            
            guard let results = CoreDataHelper.shared.recentHistories(isAscending: isAscending, limit: limit) else {
                single(.error(NSError(domain: "\(#function) : \(#line)", code: PBError.coredata_select_entity.rawValue, userInfo: nil)))
                return Disposables.create()
            }
            
            single(.success(results))
            return Disposables.create()
        }
    }
    
    func update(model: HistoryModel) -> Completable {
        return Completable.create { [weak self] completable in
            guard let self = self else {
                completable(.error(NSError(domain: "\(#function) : \(#line)", code: PBError.system_deallocated.rawValue, userInfo: nil)))
                return Disposables.create()
            }

            if let error = CoreDataHelper.shared.updateHistory(model: model) {
                completable(.error(error))
                return Disposables.create()
            }

            completable(.completed)
            return Disposables.create()
        }
    }
    
    func all(text: String) -> Single<[HistoryModel]> {
        return Single<[HistoryModel]>.create { [weak self] single in
            guard let self = self else {
                single(.error(NSError(domain: "\(#function) : \(#line)", code: PBError.system_deallocated.rawValue, userInfo: nil)))
                return Disposables.create()
            }
            
            guard let results = CoreDataHelper.shared.allHistories(text: text) else {
                single(.error(NSError(domain: "\(#function) : \(#line)", code: PBError.coredata_select_entity.rawValue, userInfo: nil)))
                return Disposables.create()
            }
            
            single(.success(results))
            return Disposables.create()
        }
    }
    
    func delete(model: HistoryModel) -> Completable {
        return Completable.create { [weak self] completable in
            guard let self = self else {
                completable(.error(NSError(domain: "\(#function) : \(#line)", code: PBError.system_deallocated.rawValue, userInfo: nil)))
                return Disposables.create()
            }

            if let error = CoreDataHelper.shared.deleteHistory(model: model) {
                completable(.error(error))
                return Disposables.create()
            }
            
            completable(.completed)
            return Disposables.create()
        }
    }
}
