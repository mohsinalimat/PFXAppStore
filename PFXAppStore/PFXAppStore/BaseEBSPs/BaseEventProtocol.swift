//
//  BaseEventProtocol.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/16.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import RxSwift

// ViewModel -> Bloc에게 전달하는 이벤트 프로토콜
protocol BaseEventProtocol {
    // 비즈니스 로직 실행
    func applyAsync() -> Observable<BaseStateProtocol>
}
