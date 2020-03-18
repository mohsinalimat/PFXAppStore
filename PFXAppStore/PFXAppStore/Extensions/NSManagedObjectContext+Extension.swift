//
//  NSManagedObjectContext+Extension.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/17.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import CoreData
import RxSwift
import RxCoreData

extension NSManagedObjectContext {
    public func saveContextWithoutErrorHandling() {
        do {
            if hasChanges {
                try save()
            }
        }
        catch {
            print(error)
        }
    }
}

extension Reactive where Base: NSManagedObjectContext {
    func entities<P: Persistable>(_ type: P.Type = P.self,
                                  predicate: NSPredicate? = nil,
                                  limit: Int = 0,
                                  sortDescriptors: [NSSortDescriptor]? = nil) -> Observable<[P]> {
        
        let fetchRequest: NSFetchRequest<P.T> = NSFetchRequest(entityName: P.entityName)
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = limit
        fetchRequest.sortDescriptors = sortDescriptors ?? [NSSortDescriptor(key: P.primaryAttributeName, ascending: true)]
        
        return entities(fetchRequest: fetchRequest).map {$0.map(P.init)}
    }
}
