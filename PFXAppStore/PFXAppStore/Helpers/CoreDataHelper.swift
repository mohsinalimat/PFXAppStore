//
//  CoreDataHelper.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/17.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import CoreData
import RxDataSources
import RxSwift

class CoreDataHelper {
    static let shared = CoreDataHelper()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
       let modelURL = Bundle.main.url(forResource: "PFXAppStore", withExtension: "momd")!
       return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var applicationDocumentsDirectory: URL = {
       let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
       return urls.last!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator! = {
       var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
       let docURL = self.applicationDocumentsDirectory
       let fileManager = FileManager.default
       let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
       let finalDatabaseURL = documentsUrl.first!.appendingPathComponent(ConstStrings.sqliteFileName)
       do {
           let fileExists = try finalDatabaseURL.checkResourceIsReachable()
           if fileExists == false {
               let documentsURL = Bundle.main.resourceURL?.appendingPathComponent(ConstStrings.sqliteFileName)
               try fileManager.copyItem(atPath: (documentsURL?.path)!, toPath: finalDatabaseURL.path)
           }
       } catch let error as NSError {
           print("path : \(finalDatabaseURL.path) error : \(error)")
       }
       
       let mOptions = [NSMigratePersistentStoresAutomaticallyOption: true,
                       NSInferMappingModelAutomaticallyOption: true]
       
       do {
        try coordinator!.addPersistentStore(ofType: DependencyInjection.coreDataType, configurationName: nil, at: finalDatabaseURL, options: nil)

       } catch {
           coordinator = nil
           abort()
       }
       
       return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
       let coordinator = self.persistentStoreCoordinator
       var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
       managedObjectContext.persistentStoreCoordinator = coordinator
       return managedObjectContext
    }()

    func updateHistory(model: HistoryModel) -> NSError? {
        if model.text.count <= 0 || model.text.count > ConstNumbers.maxHistoryLength {
           return NSError(domain: "\(#function) : \(#line)", code: PBError.coredata_invalid_entity.rawValue, userInfo: nil)
        }

        do {
           try self.managedObjectContext.rx.update(model)
        }
        catch {
           return NSError(domain: "\(#function) : \(#line)", code: PBError.coredata_invalid_entity.rawValue, userInfo: nil)
        }

        self.managedObjectContext.saveContextWithoutErrorHandling()
        return nil
    }

    func recentHistories(isAscending: Bool, limit: Int) -> [HistoryModel]? {
        print("recent load histories")
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "HistoryModel")
        let sort = NSSortDescriptor(key: "date", ascending: isAscending)
        request.sortDescriptors = [sort]
        request.fetchLimit = limit
         
        do {
            var results = [HistoryModel]()
            guard let values = try managedObjectContext.fetch(request) as? [NSManagedObject] else {
                return results
            }
            
            for value in values {
                guard let text = value.value(forKey: "text") as? String,
                    let date = value.value(forKey: "date") as? Date else {
                        return results
                }
                
                let model = HistoryModel(text: text, date: date)
                results.append(model)
            }
            
            return results
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
    }

    func allHistories(text: String) -> [HistoryModel]? {
       print("select histories")
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "HistoryModel")
        request.predicate = NSPredicate(format: "text beginsWith[c] %@", text)

        do {
            var results = [HistoryModel]()
            guard let values = try managedObjectContext.fetch(request) as? [NSManagedObject] else {
                return results
            }
            
            for value in values {
                guard let text = value.value(forKey: "text") as? String,
                    let date = value.value(forKey: "date") as? Date else {
                        return results
                }
                
                let model = HistoryModel(text: text, date: date)
                results.append(model)
            }
            
            return results
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
    }


    func deleteHistory(model: HistoryModel) -> NSError? {
       if model.text.count <= 0 || model.text.count > ConstNumbers.maxHistoryLength {
           return NSError(domain: "\(#function) : \(#line)", code: PBError.coredata_invalid_entity.rawValue, userInfo: nil)
       }
       
       do {
           try self.managedObjectContext.rx.delete(model)
       } catch {
           return NSError(domain: "\(#function) : \(#line)", code: PBError.coredata_invalid_entity.rawValue, userInfo: nil)
       }

       self.managedObjectContext.saveContextWithoutErrorHandling()
       return nil
    }

    func deleteAllHistory(completion: @escaping ((NSError?) -> Void)) {
       DispatchQueue.global().async {
           let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: HistoryModel.entityName)
           fetchRequest.returnsObjectsAsFaults = false
           do {
               let results = try self.managedObjectContext.fetch(fetchRequest)
               for object in results {
                   guard let objectData = object as? NSManagedObject else {continue}
                   self.managedObjectContext.delete(objectData)
               }
               
               completion(nil)
               
           } catch {
               completion(NSError(domain: "\(#function) : \(#line)", code: PBError.coredata_delete_entity.rawValue, userInfo: nil))
           }
       }
    }
}
