//
//  coredata_update_false_t2_2.swift
//  PFXAppStoreCoreDataTests
//
//  Created by PFXStudio on 2020/03/17.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import XCTest
import RxSwift
import RxCoreData
import CoreData

class coredata_update_false_t2_2: XCTestCase {
    let timeout = TimeInterval(10)
    var disposeBag = DisposeBag()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        DependencyInjection.coreDataType = NSInMemoryStoreType
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.disposeBag = DisposeBag()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        if let error = CoreDataHelper.shared.updateHistory(model: HistoryModel(text: "3lMvTNjyoZSj2dxbo77yhGIkEjoua5fy1", date: Date())) {
            XCTAssertTrue(error.code == PBError.coredata_invalid_entity.rawValue)
            return
        }

        XCTAssertTrue(false)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
