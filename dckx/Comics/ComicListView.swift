//
//  ComicListView.swift
//  dckx
//
//  Created by Vito Royeca on 2/21/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI
import Combine
import CoreData

// MARK: - ComicListView

struct  ComicListView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var fetcher: ComicFetcher
//    @EnvironmentObject var settings: Settings
    @State var query: String?
    @State var scopeSelection: Int = 0
    
    @State var viewModel: ComicListViewModel = ComicListViewModel(query: nil,
                                                                  scopeIndex: 0)
    @State var shouldAnimate: Bool = false
    
    var body: some View {
        SearchNavigation(query: $query,
                         scopeSelection: $scopeSelection,
                         delegate: self) {
            ZStack(alignment: .center) {
                if viewModel.comics.isEmpty {
                    Text("No results found.")
                        .font(.custom("xkcd-Script-Regular", size: 15))
                } else {
                    ComicTextListView(viewModel: $viewModel,
                                      action: selectComic(num:))
                }
                ActivityIndicatorView(shouldAnimate: $shouldAnimate)
            }
                .navigationBarTitle(Text("Comics"), displayMode: .automatic)
                .navigationBarItems(
                    trailing: closeButton
                )
        }
            .edgesIgnoringSafeArea(.top)
    }
    
    var closeButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "xmark.circle.fill")
                .imageScale(.large)
        }
    }
    
    func selectComic(num: Int32) {
        fetcher.load(num: num)
        presentationMode.wrappedValue.dismiss()
    }
    
}

// MARK: - ListView_Previews

struct ComicListView_Previews: PreviewProvider {
    static var previews: some View {
        ComicListView().environmentObject(ComicFetcher())
    }
}

// MARK: - SearchNavigation

extension ComicListView: SearchNavigationDelegate {
    var options: [NavigationSearchBarOptionKey : Any]? {
        return [
            .automaticallyShowsSearchBar: true,
            .obscuresBackgroundDuringPresentation: true,
            .hidesNavigationBarDuringPresentation: true,
            .hidesSearchBarWhenScrolling: false,
            .placeholder: "Search",
            .showsBookmarkButton: false,
            .scopeButtonTitles: ["All", "Bookmarked", "Seen"],
            .scopeBarButtonTitleTextAttributes: [NSAttributedString.Key.font: UIFont(name: "xkcd-Script-Regular", size: 15)!],
            .searchTextFieldFont: UIFont(name: "xkcd-Script-Regular", size: 15)!
         ]
    }
    
    func search() {
        DispatchQueue.global(qos: .background).async {
            self.shouldAnimate = true
            self.viewModel = ComicListViewModel(query: self.query,
                                                scopeIndex: self.scopeSelection)
            DispatchQueue.main.async {
                self.shouldAnimate = false
            }
        }
    }
    
    func scope() {
        search()
    }
    
    func cancel() {
        search()
    }
}

// MARK: - ComicTextListView

struct ComicTextListView: View {
    @Binding var viewModel: ComicListViewModel
    var action: (Int32) -> Void
    
    var body: some View {
        VStack {
            List(viewModel.comics) { comic in
                ListRowView(num: comic.num,
                            thumbnail: comic.img ?? "",
                            title: comic.title ?? "",
                            isFavorite: comic.isFavorite,
                            isSeen: comic.isRead,
                            font: .custom("xkcd-Script-Regular", size: 15),
                            action: self.action)
                    .onTapGesture {
                        self.action(comic.num)
                    }
                    .onAppear(perform: {
                        if self.viewModel.shouldLoadMore(comic: comic) {
                            self.viewModel.loadData()
                        }
                    })
            }
            .resignKeyboardOnDragGesture()
        }
    }
}


// MARK: - ComicListViewModel

class ComicListViewModel: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
    @Published var query: String?
    @Published var scopeIndex: Int
    @Published var comics: [Comic] = []
    
    private var controller: NSFetchedResultsController<Comic>?
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
        guard let result = controller.fetchedObjects as? [Comic] else {
            return
        }

        comics = result
    }
    
    // MARK: - Custom methods

    func createFetchRequest(query: String?, scopeIndex: Int) -> NSFetchRequest<Comic> {
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
        
        let fetchRequest: NSFetchRequest<Comic> = Comic.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "num", ascending: false)]
        fetchRequest.predicate = predicate
//        fetchRequest.fetchOffset = fetchOffset
//        fetchRequest.fetchLimit = fetchLimit
        
        return fetchRequest
    }
    
    func shouldLoadMore(comic: Comic) -> Bool{
        if let last = comics.last {
            return comic.num ==  last.num
        }
        return false
    }
    
    func loadData() {
        let fetchRequest = createFetchRequest(query: query,
                                              scopeIndex: scopeIndex)
        
        controller = NSFetchedResultsController<Comic>(fetchRequest: fetchRequest,
                                                       managedObjectContext: CoreData.sharedInstance.dataStack.viewContext,
                                                       sectionNameKeyPath: nil,
                                                       cacheName: "ComicCache")
        controller!.delegate = self
        
        do {
            NSFetchedResultsController<Comic>.deleteCache(withName: controller!.cacheName)
            try controller!.performFetch()
            comics = controller!.fetchedObjects ?? []
//            fetchOffset += fetchBatchSize
//            fetchLimit += fetchOffset
        } catch {
            print(error)
        }
    }
}

