//
//  AppStoreRepositoryValidator.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/16.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation

class AppStoreRepositoryValidator {
    class func requestSearchList(parameterDict: [String: String]) -> PBError? {
        guard let term = parameterDict["term"] else {
            return PBError.network_invalid_parameter
        }

        if term.count <= 0 || term.count > ConstNumbers.maxTermLength {
            return PBError.network_invalid_parameter
        }

        guard let offset = parameterDict["offset"] else {
            return PBError.network_invalid_parameter
        }

        if Int(offset) == nil {
            return PBError.network_invalid_parameter
        }

        return nil
    }
}
