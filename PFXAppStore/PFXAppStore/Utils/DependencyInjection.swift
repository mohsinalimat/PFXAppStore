//
//  DependencyInjection.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/16.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation

class DependencyInjection {
    static let shared = DependencyInjection()
    static var clientType = ClientType.mock
    
    func currentClient() -> ClientProtocol {
        if DependencyInjection.clientType == ClientType.mock {
            return MockClient()
        }
        
        return RestClient()
    }
}
