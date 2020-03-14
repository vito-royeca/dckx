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
    // MARK: Variables
    let dataStack: DataStack
    
    // MARK: Singleton
    static let sharedInstance = CoreData(storeType: .sqLite)
    static let mockInstance = CoreData(storeType: .inMemory)
    private init(storeType: DataStackStoreType) {
        dataStack = DataStack(modelName: "dckx", storeType: storeType)
    }
    
    // MARK: Comic Database methods
    func saveComic(data: [String: Any]) -> Promise<Void> {
        return Promise { seal in
            let completion = { (error: NSError?) in
                if let error = error {
                    seal.reject(error)
                } else {
                    seal.fulfill(())
                }
            }
            guard let num = data["num"] as? Int32 else {
                seal.fulfill(())
                return
            }
            let predicate = NSPredicate(format: "num = %i", num)
            
            // create a date property
            var newData = [String: Any]()
                var year = "2020"
                var month = "1"
                var day = "1"
                
                for (k,v) in data {
                    switch k {
                    case "year":
                        if let v = v as? String {
                            year = v
                        }
                    case "month":
                        if let v = v as? String,
                            let num = Int(v) {
                            month = num < 10 ? "0\(num)" : "\(num)"
                        }
                    case "day":
                        if let v = v as? String,
                            let num = Int(v) {
                            day = num < 10 ? "0\(num)" : "\(num)"
                        }
                    default:
                        newData[k] = v
                    }
                newData["date"] = "\(year)-\(month)-\(day)"
            }
            
            dataStack.sync([newData],
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
                                userInfo: [NSLocalizedDescriptionKey: "Last Comic not found."])
            
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
    
    // MARK: WhatIf Database methods
    func saveWhatIf(data: [String: Any]) -> Promise<Void> {
        return Promise { seal in
            let completion = { (error: NSError?) in
                if let error = error {
                    seal.reject(error)
                } else {
                    seal.fulfill(())
                }
            }
            guard let num = data["num"] as? Int32 else {
                seal.fulfill(())
                return
            }
            let predicate = NSPredicate(format: "num = %i", num)
            
            dataStack.sync([data],
                           inEntityNamed: String(describing: WhatIf.self),
                           predicate: predicate,
                           operations: .all,
                           completion: completion)
        }
    }
    
    func loadWhatIf(num: Int32) -> Promise<WhatIf> {
        return Promise { seal in
            let error = NSError(domain: "",
                                code: 404,
                                userInfo: [NSLocalizedDescriptionKey: "WhatIf with ID \(num) not found."])
            
            do {
                if let whatIf = try dataStack.fetch(num, inEntityNamed: String(describing: WhatIf.self)) as? WhatIf {
                    seal.fulfill(whatIf)
                } else {
                    seal.reject(error)
                }
            } catch {
                seal.reject(error)
            }
        }
    }
    
    func loadLastWhatIf() -> Promise<WhatIf> {
        return Promise { seal in
            let error = NSError(domain: "",
                                code: 404,
                                userInfo: [NSLocalizedDescriptionKey: "Last WhatIf not found."])
            
            do {
                let request: NSFetchRequest<NSFetchRequestResult> = WhatIf.fetchRequest()
                request.fetchLimit = 1
                request.sortDescriptors = [NSSortDescriptor(key: "num", ascending: false)]
                
                guard let array = try dataStack.execute(request, with: dataStack.mainContext) as? [NSManagedObject],
                    let whatIf = array.first as? WhatIf else {
                    throw(error)
                }
                seal.fulfill(whatIf)
            } catch {
                seal.reject(error)
            }
        }
    }
}
