//
//  AppStoreResponseModel.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/16.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation

struct AppStoreResponseModel: Codable {
    var resultCount = 0
    var results = [AppStoreModel]()
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        if let resultCount = try container.decodeIfPresent(Int.self, forKey: .resultCount) { self.resultCount = resultCount }
        if let results = try container.decodeIfPresent(Array<AppStoreModel>.self, forKey: .results) { self.results = results }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(resultCount, forKey: .resultCount)
        try container.encode(results, forKey: .results)
    }

    enum Keys: String, CodingKey {
        case resultCount = "resultCount"
        case results = "results"
    }
}
