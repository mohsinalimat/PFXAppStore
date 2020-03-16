//
//  AppStoreRepositoryValidator.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/16.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation

class AppStoreRepositoryValidator {
    class func requestSearchList(parameterDict: [String: String]) -> RepositoryError? {
        guard let term = parameterDict["term"] else {
            return RepositoryError.error("repository_wrong_parameter")
        }

        if term.count <= 0 {
            return RepositoryError.error("repository_wrong_parameter")
        }

        guard let offset = parameterDict["offset"] else {
            return RepositoryError.error("repository_wrong_parameter")
        }

        if Int(offset) == nil {
            return RepositoryError.error("repository_wrong_parameter")
        }

        return nil
    }
}
