//
//  CoreData.swift
//  dckx
//
//  Created by Vito Royeca on 2/13/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import Foundation
import CoreData
import PromiseKit
import Sync

class CoreData {
    // MARK: DataStack
    private let dataStack: DataStack!
    
    // MARK: Singleton
    static let sharedInstance = CoreData(storeType: .sqLite)
    static let mockInstance = CoreData(storeType: .inMemory)
    private init(storeType: DataStackStoreType) {
        dataStack = DataStack(modelName: "dckx", storeType: storeType)
    }    
    
    // MARK: Database methods
    func saveComics(data: [[String: Any]]) -> Promise<Void> {
        return Promise { seal in
            let completion = { (error: NSError?) in
                if let error = error {
                    seal.reject(error)
                } else {
                    seal.fulfill(())
                }
            }
            guard let first = data.first,
                let num = first["num"] as? Int32 else {
                seal.fulfill(())
                return
            }
            let predicate = NSPredicate(format: "num = %i", num)
            
            dataStack.sync(data,
                           inEntityNamed: String(describing: Comic.self),
                           predicate: predicate,
                           operations: .all,
                           completion: completion)
        }
    }
    
    func loadComic(num: Int32) -> Promise<Comic> {
        return Promise { seal in
            let error = NSError(domain: "",
                                code: 404,
                                userInfo: [NSLocalizedDescriptionKey: "Comic with ID \(num) not found."])
            
            do {
                if let comic = try dataStack.fetch(num, inEntityNamed: String(describing: Comic.self)) as? Comic {
                    seal.fulfill(comic)
                } else {
                    seal.reject(error)
                }
            } catch {
                seal.reject(error)
            }
        }
    }
    
    func loadLastComic() -> Promise<Comic> {
        return Promise { seal in
            let error = NSError(domain: "",
                                code: 404,
                                userInfo: [NSLocalizedDescriptionKey: "Current Comic not found."])
            
            do {
                let request: NSFetchRequest<NSFetchRequestResult> = Comic.fetchRequest()
                request.fetchLimit = 1
                request.sortDescriptors = [NSSortDescriptor(key: "num", ascending: false)]
                
                guard let array = try dataStack.execute(request, with: dataStack.mainContext) as? [NSManagedObject],
                    let comic = array.first as? Comic else {
                    throw(error)
                }
                seal.fulfill(comic)
            } catch {
                seal.reject(error)
            }
        }
    }
    
//    func createBlankComics(lastNum: Int32) {
//        var data = [[String: Any]]()
//        
//        for i in stride(from: lastNum, to: 1, by: -1) {
//            data.append(["num": Int32(i)])
//        }
//        
//        firstly {
//            saveComics(data: data)
//        }.done {
//            
//        }.catch { error in
//            
//        }
//    }
}
