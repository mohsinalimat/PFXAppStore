//
//  HistoryState.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/21.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation

protocol HistoryStateProtocol: BaseStateProtocol {
}

class FetchingHistoryState: HistoryStateProtocol {
}

class CompletedHistoryState: HistoryStateProtocol {
}

class RecentHistoryState: HistoryStateProtocol {
    let datas: [HistoryModel]
    init(datas: [HistoryModel]) {
        self.datas = datas
    }
}

class AllHistoryState: HistoryStateProtocol {
    let datas: [HistoryModel]
    init(datas: [HistoryModel]) {
        self.datas = datas
    }
}

class IdleHistoryState: HistoryStateProtocol {
}

class ErrorHistoryState: HistoryStateProtocol {
    let error: NSError
    init(error: NSError) {
        self.error = error
    }
}
