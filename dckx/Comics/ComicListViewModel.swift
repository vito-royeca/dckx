//
//  ComicListViewModel.swift
//  dckx
//
//  Created by Vito Royeca on 4/13/24.
//  Copyright © 2024 Vito Royeca. All rights reserved.
//

import SwiftUI
import SwiftData

@Observable
class ComicListViewModel {
    var modelContext: ModelContext
   var searchText = ""
    var comics = [ComicModel]()
    
    // MARK: - Initializer

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        Task {
            do {
                try await loadComics()
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: - Custom methods

//    func createFetchRequest(query: String?, scopeIndex: Int) -> NSFetchRequest<ComicManagedObject> {
//        let sensitiveData = SensitiveData()
//        var predicate: NSPredicate?
//        
//        if let query = query {
//            if query.count == 1 {
//                predicate = NSPredicate(format: "title BEGINSWITH[cd] %@ OR title ==[cd] %@", query, query)
//            } else if query.count > 1 {
//                predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR title ==[cd] %@", query, query)
//            }
//            if let num = Int(query) {
//                let newPredicate = NSPredicate(format: "num == %i", num)
//                predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate!, newPredicate])
//            }
//        }
//        
//        switch scopeIndex {
//        case 1:
//            let newPredicate = NSPredicate(format: "isFavorite == true")
//            if predicate != nil {
//                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate!, newPredicate])
//            } else {
//                predicate = newPredicate
//            }
//        case 2:
//            let newPredicate = NSPredicate(format: "isRead == true")
//            if predicate != nil {
//                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate!, newPredicate])
//            } else {
//                predicate = newPredicate
//            }
//        default:
//            ()
//        }
//        
//        predicate = sensitiveData.createComicsPredicate(basePredicate: predicate)
//        
//        let fetchRequest: NSFetchRequest<ComicManagedObject> = ComicManagedObject.fetchRequest()
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "num", ascending: false)]
//        fetchRequest.predicate = predicate
////        fetchRequest.fetchOffset = fetchOffset
////        fetchRequest.fetchLimit = fetchLimit
//        
//        return fetchRequest
//    }
    
    func setRead(comic: ComicModel) {
        do {
            comic.isRead = true
            try modelContext.save()
        } catch {
            print(error)
        }
    }

    func loadComics() async throws{
        do {
            let descriptor = FetchDescriptor<ComicModel>(sortBy: [SortDescriptor(\.num, order: .reverse)])
            comics = try modelContext.fetch(descriptor)
        } catch {
            print("Fetch failed")
        }
    }

//    func shouldLoadMore(comic: ComicManagedObject) -> Bool{
//        if let last = comics.last {
//            return comic.num ==  last.num
//        }
//        return false
//    }
//    
//    func loadData() {
//        let fetchRequest = createFetchRequest(query: query,
//                                              scopeIndex: scopeIndex)
//        
////        controller = NSFetchedResultsController<Comic>(fetchRequest: fetchRequest,
////                                                       managedObjectContext: CoreData.sharedInstance.dataStack.viewContext,
////                                                       sectionNameKeyPath: nil,
////                                                       cacheName: "ComicCache")
//        controller!.delegate = self
//        
//        do {
//            NSFetchedResultsController<ComicManagedObject>.deleteCache(withName: controller!.cacheName)
//            try controller!.performFetch()
//            comics = controller!.fetchedObjects ?? []
////            fetchOffset += fetchBatchSize
////            fetchLimit += fetchOffset
//        } catch {
//            print(error)
//        }
//    }
}
