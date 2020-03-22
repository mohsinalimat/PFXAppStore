//
//  ConstEnums.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/16.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation

public enum ClientType {
    case mock
    case rest
}

public enum PBError: Int {
    case network_too_many_request = 429
    case network_invalid_url = 40000
    case network_invalid_response_data
    case network_invalid_parameter
    case network_invalid_status
    case network_invalid_parse

    case coredata_invalid_initialize
    case coredata_invalid_entity
    case coredata_select_entity
    case coredata_delete_entity
    
    case filedata_invalid_encoding
    case filedata_invalid_folderPath
    case filedata_invalid_filepath

    case system_deallocated = 44444
    case system_invalid_stub
    case unknown_code = 55555

    static func messageKey(value: Int) -> String {
        switch value {
        case Self.network_too_many_request.rawValue: return "network_too_many_request"
        case Self.network_invalid_url.rawValue: return "network_invalid_url"
        case Self.network_invalid_response_data.rawValue: return "network_invalid_response_data"
        case Self.network_invalid_parameter.rawValue: return "network_invalid_parameter"
        case Self.network_invalid_status.rawValue: return "network_invalid_status"
        case Self.network_invalid_parse.rawValue: return "network_invalid_parse"
        case Self.coredata_invalid_initialize.rawValue: return "coredata_invalid_initialize"
        case Self.coredata_invalid_entity.rawValue: return "coredata_invalid_entity"
        case Self.coredata_select_entity.rawValue: return "coredata_select_entity"
        case Self.coredata_delete_entity.rawValue: return "coredata_delete_entity"
        case Self.filedata_invalid_encoding.rawValue: return "filedata_invalid_encoding"
        case Self.filedata_invalid_folderPath.rawValue: return "filedata_invalid_folderPath"
        case Self.filedata_invalid_filepath.rawValue: return "filedata_invalid_filepath"
        case Self.system_deallocated.rawValue: return "system_deallocated"
        case Self.system_invalid_stub.rawValue: return "system_invalid_stub"
        default:
            return "unknown_code"
        }
    }
}

struct AdaptError: Error {
    let error: NSError
}

extension Error {
    var nsError: NSError? { return (self as? AdaptError)?.error }
}

public enum AppInfoSectionType: Int {
    case info = 0
    case iphoneScreenshot
    case ipadScreenshot
    case description
}


