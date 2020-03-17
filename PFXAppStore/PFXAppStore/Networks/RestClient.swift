//
//  RestClient.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/16.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import RxSwift

class RestClient: ClientProtocol {
    private var urlSession = URLSession(configuration: .default)

    func request(targetPath: String, parameterDict: [String : String]) -> Observable<Data> {
        return Observable.create { observer in
            guard var components = URLComponents(string: targetPath) else {
                observer.onError(NSError(domain: "\(#function) : \(#line)", code: PBError.network_invalid_url.rawValue, userInfo: nil))
                return Disposables.create()
            }

            components.queryItems = parameterDict.map { (key, value) in
                URLQueryItem(name: key, value: value)
            }

            components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
            
            guard let url = components.url else {
                observer.onError(NSError(domain: "\(#function) : \(#line)", code: PBError.network_invalid_url.rawValue, userInfo: nil))
                return Disposables.create()
            }
            
            let request = URLRequest(url: url)
            let task = self.urlSession.dataTask(with: request) { (data, response, error) in
                guard let httpResponse = response as? HTTPURLResponse else {
                    observer.onError(NSError(domain: "\(#function) : \(#line)", code: PBError.network_invalid_response_data.rawValue, userInfo: nil))
                    return
                }
                let statusCode = httpResponse.statusCode
                let data = data ?? Data()
                if (200...399).contains(statusCode) {
                    observer.onNext(data)
                }
                else {
                    observer.onError(NSError(domain: "\(#function) : \(#line)", code: PBError.network_invalid_status.rawValue, userInfo: nil))
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
