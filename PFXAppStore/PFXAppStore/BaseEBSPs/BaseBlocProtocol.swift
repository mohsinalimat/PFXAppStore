//
//  BaseBlocProtocol.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/16.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation

// 비즈니스 로직 관제 프로토콜
protocol BaseBlocProtocol {
    var currentState: BaseStateProtocol? { get }
    // ViewModel에서 이벤트 발생 -> Event에게 비즈니스 로직 위임
    func dispatch(event: BaseEventProtocol)
}
