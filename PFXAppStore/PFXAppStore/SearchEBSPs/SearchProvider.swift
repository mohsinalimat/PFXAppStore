//
//  SearchProvider.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/16.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import RxSwift

protocol SearchProviderProtocol: BaseProviderProtocol {
    func fetchingSearch(parameterDict: [String : String]) -> Single<AppStoreResponseModel>
}

class SearchProvider: SearchProviderProtocol {
    private lazy var jsonDecoder = JSONDecoder()
    var disposeBag = DisposeBag()
    var repository: AppStoreProtocol = AppStoreRepository()
    
    deinit {
        self.disposeBag = DisposeBag()
    }

    func fetchingSearch(parameterDict: [String : String]) -> Single<AppStoreResponseModel> {
        return Single<AppStoreResponseModel>.create { [weak self] single in
            guard let self = self else {
                single(.error(NSError(domain: "\(#function) : \(#line)", code: PBError.system_deallocated.rawValue, userInfo: nil)))
                return Disposables.create()
            }

            if let error = AppStoreRepositoryValidator.requestSearchList(parameterDict: parameterDict) {
                single(.error(NSError(domain: "\(#function) : \(#line)", code: error.rawValue, userInfo: nil)))
                return Disposables.create()
            }

            self.repository.request(targetPath: ConstStrings.basePath + "/search", parameterDict: parameterDict)
                .subscribe(onNext: { data in
                    do {
                        let responseModel = try self.jsonDecoder.decode(AppStoreResponseModel.self, from: data)
                        single(.success(responseModel))
                    }
                    catch {
                        single(.error(error))
                    }
                }, onError: { error in
                    single(.error(error))
                })
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
   
}
