//
//  ComicWidgetProvider.swift
//  dckx
//
//  Created by Vito Royeca on 4/22/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

import Foundation

class ComicWidgetProvider {
    func reloadData() {
//        let dataStack = CoreData.sharedInstance.dataStack
//        
//        dataStack.newBackgroundContext().perform({
//            
//        })
    }
    
//    private func fetchLastComic() -> Comic {
//        do {
//            let sensitiveData = SensitiveData()
//            let request: NSFetchRequest<NSFetchRequestResult> = Comic.fetchRequest()
//            request.fetchLimit = 1
//            request.sortDescriptors = [NSSortDescriptor(key: "num", ascending: false)]
//            request.predicate = sensitiveData.createComicsPredicate(basePredicate: nil)
//            
//            let dataStack = CoreData.sharedInstance.dataStack
//            
//            if let c = try dataStack.fetch(Int32(1), inEntityNamed: String(describing: Comic.self)) as? Comic {
////            if let a = try dataStack.execute(request, with: dataStack.mainContext) as? [Comic] {
//                print(c.title)
//            }
//            
//            guard let array = try dataStack.execute(request, with: dataStack.mainContext) as? [NSManagedObject],
//                let comic = array.first as? Comic else {
//                
//                let error = NSError(domain: "",
//                                    code: 404,
//                                    userInfo: [NSLocalizedDescriptionKey: "Last Comic not found."])
//                throw(error)
//            }
//            
//            return comic
//        }
//        catch {
//            fatalError()
//        }
//    }
//    
//    private func fetchComic(num: Int32) -> Comic {
//        do {
//            let dataStack = CoreData.sharedInstance.dataStack
//            
//            if let comic = try dataStack.fetch(num, inEntityNamed: String(describing: Comic.self)) as? Comic {
//                return comic
//            } else {
//                let error = NSError(domain: "",
//                                    code: 404,
//                                    userInfo: [NSLocalizedDescriptionKey: "Comic with ID \(num) not found."])
//                throw(error)
//            }
//        } catch {
//            fatalError()
//        }
//    }
}
