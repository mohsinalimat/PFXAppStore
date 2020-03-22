//
//  NSURL+Extension.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/22.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import RxSwift

extension NSURL {
    func remoteSize() -> Observable<Int64> {
        return Observable.create { observer in
            var contentLength: Int64 = NSURLSessionTransferSizeUnknown
            let request = NSMutableURLRequest(url: self as URL, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: ConstNumbers.timeoutInterval)
            request.httpMethod = "HEAD";
            let group = DispatchGroup()
            group.enter()
            URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                contentLength = response?.expectedContentLength ?? NSURLSessionTransferSizeUnknown
                group.leave()
                observer.onNext(contentLength)
            }).resume()
            
            return Disposables.create()
        }
    }
}
