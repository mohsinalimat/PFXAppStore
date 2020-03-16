//
//  AppStoreRepository.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/16.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import RxSwift

class AppStoreRepository: AppStoreProtocol {
    private lazy var jsonDecoder = JSONDecoder()
    private var urlSession = URLSession(configuration: .default)

    public func requestSearchList(parameterDict: [String : String]) -> Observable<AppStoreResponseModel> {
        return Observable.create { observer in
            guard var components = URLComponents(string: ConstStrings.basePath + "/search") else {
                observer.onError(RepositoryError.error("network_wrong_url"))
                return Disposables.create()
            }

            if let error = AppStoreRepositoryValidator.requestSearchList(parameterDict: parameterDict) {
                observer.onError(error)
                return Disposables.create()
            }

            components.queryItems = parameterDict.map { (key, value) in
                URLQueryItem(name: key, value: value)
            }

            components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
            let request = URLRequest(url: components.url!)
            let task = self.urlSession.dataTask(with: request) { (data, response, error) in
                guard let httpResponse = response as? HTTPURLResponse else {
                    observer.onError(RepositoryError.error("repository_wrong_response"))
                    return
                }
                let statusCode = httpResponse.statusCode
                do {
                    let data = data ?? Data()
                    if (200...399).contains(statusCode) {
                        let responseModel = try self.jsonDecoder.decode(AppStoreResponseModel.self, from: data)
                        observer.onNext(responseModel)
                    }
                    else {
                        observer.onError(RepositoryError.error("repository_wrong_status"))
                    }
                }
                catch {
                    observer.onError(RepositoryError.error("repository_invalid_parse"))
                }

                observer.onCompleted()
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
