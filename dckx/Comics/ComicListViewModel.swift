//
//  ComicListViewModel.swift
//  dckx
//
//  Created by Vito Royeca on 4/13/24.
//  Copyright © 2024 Vito Royeca. All rights reserved.
//

import CoreData
import SwiftUI

class ComicListViewModel: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
    @Published var query: String?
    @Published var scopeIndex: Int
    @Published var comics: [ComicManagedObject] = []
    
    private var controller: NSFetchedResultsController<ComicManagedObject>?
    var fetchBatchSize = 20
//    var fetchLimit = 20
    var fetchOffset = 0
    
    
    // MARK: - Initializer

    init(query: String?, scopeIndex: Int) {
        self.query = query
        self.scopeIndex = scopeIndex
        super.init()
        
        loadData()
    }
 
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let result = controller.fetchedObjects as? [ComicManagedObject] else {
            return
        }

        comics = result
    }
    
    // MARK: - Custom methods

    func createFetchRequest(query: String?, scopeIndex: Int) -> NSFetchRequest<ComicManagedObject> {
        let sensitiveData = SensitiveData()
        var predicate: NSPredicate?
        
        if let query = query {
            if query.count == 1 {
                predicate = NSPredicate(format: "title BEGINSWITH[cd] %@ OR title ==[cd] %@", query, query)
            } else if query.count > 1 {
                predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR title ==[cd] %@", query, query)
            }
            if let num = Int(query) {
                let newPredicate = NSPredicate(format: "num == %i", num)
                predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate!, newPredicate])
            }
        }
        
        switch scopeIndex {
        case 1:
            let newPredicate = NSPredicate(format: "isFavorite == true")
            if predicate != nil {
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate!, newPredicate])
            } else {
                predicate = newPredicate
            }
        case 2:
            let newPredicate = NSPredicate(format: "isRead == true")
            if predicate != nil {
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate!, newPredicate])
            } else {
                predicate = newPredicate
            }
        default:
            ()
        }
        
        predicate = sensitiveData.createComicsPredicate(basePredicate: predicate)
        
        let fetchRequest: NSFetchRequest<ComicManagedObject> = ComicManagedObject.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "num", ascending: false)]
        fetchRequest.predicate = predicate
//        fetchRequest.fetchOffset = fetchOffset
//        fetchRequest.fetchLimit = fetchLimit
        
        return fetchRequest
    }
    
    func shouldLoadMore(comic: ComicManagedObject) -> Bool{
        if let last = comics.last {
            return comic.num ==  last.num
        }
        return false
    }
    
    func loadData() {
        let fetchRequest = createFetchRequest(query: query,
                                              scopeIndex: scopeIndex)
        
//        controller = NSFetchedResultsController<Comic>(fetchRequest: fetchRequest,
//                                                       managedObjectContext: CoreData.sharedInstance.dataStack.viewContext,
//                                                       sectionNameKeyPath: nil,
//                                                       cacheName: "ComicCache")
        controller!.delegate = self
        
        do {
            NSFetchedResultsController<ComicManagedObject>.deleteCache(withName: controller!.cacheName)
            try controller!.performFetch()
            comics = controller!.fetchedObjects ?? []
//            fetchOffset += fetchBatchSize
//            fetchLimit += fetchOffset
        } catch {
            print(error)
        }
    }
}
