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
    // MARK: Singleton
    static let sharedInstance = CoreData()
    private init() {
        
    }

    // MARK: DataStack
    private let dataStack = DataStack(modelName: "dckx")
    
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
            
            dataStack.sync(data,
                           inEntityNamed: String(describing: Comic.self),
                           predicate: nil,
                           operations: .all,
                           completion: completion)
        }
    }
    
    func loadComic(num: Int16) -> Promise<Comic> {
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
}
