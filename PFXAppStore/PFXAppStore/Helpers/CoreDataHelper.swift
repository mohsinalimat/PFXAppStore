//
//  CoreDataHelper.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/17.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import CoreData
import RxCoreData
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
        let storeURL = docURL.appendingPathComponent("PFXAppStore.sqlite")
        let mOptions = [NSMigratePersistentStoresAutomaticallyOption: true,
                        NSInferMappingModelAutomaticallyOption: true]
        
        do {
            try coordinator!.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)

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
    
    func entityHistories(isAscending: Bool, limit: Int) -> Observable<[HistoryModel]> {
        return managedObjectContext.rx.entities(HistoryModel.self, limit: 10, sortDescriptors: [NSSortDescriptor(key: "date", ascending: isAscending)])
    }

    func entityHistories(text: String) -> Observable<[HistoryModel]> {
        return managedObjectContext.rx.entities(HistoryModel.self, predicate: NSPredicate(format: "text beginsWith[c] %@", text))
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
    
    func initializeStub(completion: @escaping ((NSError?) -> Void)) {
        self.deleteAllHistory { error in
            if error != nil { return }
            do {
                guard let url = Bundle.main.url(forResource: "stub_words", withExtension: "json"),
                    let data = try? Data(contentsOf: url) else { return }
                let words = try JSONDecoder().decode([String].self, from: data)
                for word in words {
                    if let error = self.updateHistory(model: HistoryModel(text: word, date: Date())) {
                        print(error.description)
                    }
                }
                
                self.managedObjectContext.saveContextWithoutErrorHandling()
                completion(nil)
            }
            catch {
                
            }
        }
    }
}
