//
//  coredata_delete_true_t4_2.swift
//  PFXAppStoreCoreDataTests
//
//  Created by PFXStudio on 2020/03/17.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import XCTest
import RxSwift
import RxCoreData
import CoreData

class coredata_delete_true_t4_2: XCTestCase {
    let timeout = TimeInterval(10)
    var disposeBag = DisposeBag()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        DependencyInjection.coreDataType = NSInMemoryStoreType
        CoreDataHelper.shared.updateHistory(model: HistoryModel(text: "은행", date: Date()))
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.disposeBag = DisposeBag()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let model = HistoryModel(text: "은행", date: Date())
        if let error = CoreDataHelper.shared.deleteHistory(model: model) {
            XCTAssertTrue(false)
        }
        
        XCTAssertTrue(true)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
