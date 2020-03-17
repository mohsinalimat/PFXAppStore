//
//  MockClient.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/16.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import RxSwift

class MockClient: ClientProtocol {
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
            
            if components.url == nil {
                observer.onError(NSError(domain: "\(#function) : \(#line)", code: PBError.network_invalid_url.rawValue, userInfo: nil))
                return Disposables.create()
            }
            
            guard let path = Bundle.main.path(forResource: DependencyInjection.stubModel.fileName, ofType: "plist") else {
                observer.onError(NSError(domain: "\(#function) : \(#line)", code: PBError.system_invalid_stub.rawValue, userInfo: nil))
                return Disposables.create()
            }
            
            guard let dict = NSDictionary(contentsOfFile: path) else {
                observer.onError(NSError(domain: "\(#function) : \(#line)", code: PBError.system_invalid_stub.rawValue, userInfo: nil))
                return Disposables.create()
            }
            
            guard let results = dict[DependencyInjection.stubModel.key] as? String else {
                observer.onError(NSError(domain: "\(#function) : \(#line)", code: PBError.system_invalid_stub.rawValue, userInfo: nil))
                return Disposables.create()
            }
            
            let data = Data(results.utf8)
            observer.onNext(data)

            return Disposables.create {
            }
        }
    }
}
