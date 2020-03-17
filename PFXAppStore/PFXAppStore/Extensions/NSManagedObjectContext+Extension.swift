//
//  NSManagedObjectContext+Extension.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/17.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import CoreData

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
