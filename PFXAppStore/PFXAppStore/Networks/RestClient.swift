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
    var disposeBag = DisposeBag()
    deinit {
        self.disposeBag = DisposeBag()
    }
    
    func request(targetPath: String, parameterDict: [String : String]) -> Observable<Data> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NSError(domain: "\(#function) : \(#line)", code: PBError.system_deallocated.rawValue, userInfo: nil))
                return Disposables.create()
            }
            
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
    
    func requestImageData(targetPath: String) -> Observable<Data> {
        return self.contentsSize(targetPath: targetPath).flatMap { remoteSize -> Observable<Data> in
            return Observable.create { observer in
                guard let url = URL(string: targetPath) else {
                    observer.onError(NSError(domain: "\(#function) : \(#line)", code: PBError.network_invalid_url.rawValue, userInfo: nil))
                    return Disposables.create()
                }
                
                let folderName = ((targetPath as NSString).lastPathComponent as NSString).deletingPathExtension
                if let cacheData = FileCacheHelper.shared.loadImageData(folderName: folderName, key: targetPath, remoteSize: remoteSize) {
                    observer.onNext(cacheData as Data)
                    return Disposables.create()
                }

                if let cacheData = CacheHelper.shared.imageDatas.object(forKey: targetPath as NSString) {
                    observer.onNext(cacheData as Data)
                    return Disposables.create()
                }
                let task = self.urlSession.dataTask(with: url) { data, response, error in
                    guard let data = data as NSData? else {
                        observer.onError(NSError(domain: "\(#function) : \(#line)", code: PBError.network_invalid_response_data.rawValue, userInfo: nil))
                        return
                    }

                    FileCacheHelper.shared.saveImageData(folderName: folderName, key: targetPath, data: data as Data)
                    CacheHelper.shared.imageDatas.setObject(data, forKey: targetPath as NSString)
                    observer.onNext(data as Data)
                }
                task.resume()
                
                return Disposables.create {
                    task.cancel()
                }
            }
        }
    }

    // contentsSize 체크 함수는 원격을 한번 호출 하기 때문에 화면에 공백이 보인다.
    // cell에서 파일 캐쉬 데이터 로드 하여 표기하고 호출 됨.
    func contentsSize(targetPath: String) -> Observable<Int64> {
        self.urlSession = URLSession(configuration: .ephemeral)
        return Observable.create({ (observer) -> Disposable in
            guard let url = URL(string: targetPath) else {
                observer.onError(NSError(domain: "\(#function) : \(#line)", code: PBError.network_invalid_url.rawValue, userInfo: nil))
                return Disposables.create()
            }
            
            (url as NSURL).remoteSize()
                .subscribe(onNext: { remoteSize in
                    observer.onNext(remoteSize)
                }, onError: { error in
                    observer.onError(error)
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        })
    }
}
