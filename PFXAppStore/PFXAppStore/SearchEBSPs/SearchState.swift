//
//  SearchState.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/16.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation

protocol SearchStateProtocol: BaseStateProtocol {
}

class FetchingSearchState: SearchStateProtocol {
    
}

class FetchedSearchState: SearchStateProtocol {
    let appStoreResponseModel: AppStoreResponseModel
    init(appStoreResponseModel: AppStoreResponseModel) {
        self.appStoreResponseModel = appStoreResponseModel
    }
}

class EmptySearchState: SearchStateProtocol {
    
}

class IdleSearchState: SearchStateProtocol {
    
}

class ErrorSearchState: SearchStateProtocol {
    let error: NSError
    init(error: NSError) {
        self.error = error
    }
}
