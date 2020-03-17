//
//  HistoryModel.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/17.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import CoreData
import RxDataSources
import RxCoreData

struct HistoryModel {
    var text: String
    var date: Date
}

func == (lhs: HistoryModel, rhs: HistoryModel) -> Bool {
    return lhs.text == rhs.text
}

extension HistoryModel : Equatable { }

extension HistoryModel : IdentifiableType {
    typealias Identity = String
    
    var identity: Identity { return text }
}

extension HistoryModel : Persistable {
    typealias T = NSManagedObject
    
    static var entityName: String {
        return "HistoryModel"
    }
    
    static var primaryAttributeName: String {
        return "text"
    }
    
    init(entity: T) {
        text = entity.value(forKey: "text") as! String
        date = entity.value(forKey: "date") as! Date
    }
    
    func update(_ entity: T) {
        entity.setValue(text, forKey: "text")
        entity.setValue(date, forKey: "date")
        
        do {
            try entity.managedObjectContext?.save()
        } catch let e {
            print(e)
        }
    }    
}
