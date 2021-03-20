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
    @State var viewModel: ComicListViewModel = ComicListViewModel(query: nil, scopeIndex: 0)
    @State var shouldAnimate: Bool = false
    var fetcher: ComicFetcher
    
    @State var query: String = ""
    @State var scopeSelection: Int = 0
    
    init(fetcher: ComicFetcher) {
        self.fetcher = fetcher
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .center) {
                ComicTextListView(viewModel: $viewModel,
                                  action: selectComic(num:))
                ActivityIndicatorView(shouldAnimate: $shouldAnimate)
            }
            .navigationBarTitle(Text("Comics"), displayMode: .automatic)
            .navigationBarItems(
                trailing: closeButton
            )
            .navigationSearchBar(text: $query,
                                 scopeSelection: $scopeSelection,
                                 options: [
                                    .automaticallyShowsSearchBar: true,
                                    .obscuresBackgroundDuringPresentation: true,
                                    .hidesNavigationBarDuringPresentation: true,
                                    .hidesSearchBarWhenScrolling: false,
                                    .placeholder: "Search",
                                    .showsBookmarkButton: false,
                                    .scopeButtonTitles: ["All", "Bookmarked", "Read"],
                                    .scopeBarButtonTitleTextAttributes: [NSAttributedString.Key.font: UIFont(name: "xkcd Script", size: 15)],
                                    .searchTextFieldFont: UIFont(name: "xkcd Script", size: 15)!
                                    
                                 ],
                                 actions: [
                                    .onCancelButtonClicked: {
                                        doSearch()
                                    },
                                    .onSearchButtonClicked: {
                                        doSearch()
                                    },
                                    .onScopeButtonClicked: {
                                        doSearch()
                                    },
                                    .onSearchTextChanged: {
                                        doSearch()
                                    }
                                 ], searchResultsContent: {
                                    ZStack(alignment: .center) {
                                        ComicTextListView(viewModel: $viewModel,
                                                          action: selectComic(num:))
                                        ActivityIndicatorView(shouldAnimate: $shouldAnimate)
                                    }
                                 })
        }
    }
    
    var closeButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "xmark")
                .imageScale(.large)
//                            .foregroundColor(.dckxBlue)
        }
    }
    
    func selectComic(num: Int32) {
        if !query.isEmpty {
            query = ""
            scopeSelection = 0
            viewModel = ComicListViewModel(query: query,
                                           scopeIndex: scopeSelection)
        }
        fetcher.load(num: num)
        presentationMode.wrappedValue.dismiss()
    }
    
    // MARK: - SearchBar methods
    
    func doSearch() {
//        print("\(Date()): query=\(self.query), scope=\(self.scopeSelection)")

        DispatchQueue.global(qos: .background).async {
            self.shouldAnimate = true
            self.viewModel = ComicListViewModel(query: self.query,
                                                scopeIndex: self.scopeSelection)
            
            DispatchQueue.main.async {
                self.shouldAnimate = false
            }
        }
    }
}

// MARK: - ListView_Previews

struct ComicListView_Previews: PreviewProvider {
    static var previews: some View {
        ComicListView(fetcher: ComicFetcher())
    }
}


// MARK: - ComicTextListView

struct ComicTextListView: View {
    @Binding var viewModel: ComicListViewModel
    var action: (Int32) -> Void
    
    init(viewModel: Binding<ComicListViewModel>, action: @escaping (Int32) -> Void) {
        _viewModel = viewModel
        self.action = action
    }
    
    var body: some View {
        VStack {
            List(viewModel.comics) { comic in
                ComicListRow(num: comic.num,
                             title: comic.title ?? "",
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

// MARK: - ComicListRow

struct ComicListRow: View {
    var num: Int32
    var title: String
    var action: (Int32) -> Void
    
    var body: some View {
        HStack {
            Text("#\(String(num)): \(title)")
                .font(.custom("xkcd-Script-Regular", size: 15))
            Spacer()
            Button(action: {
                self.action(self.num)
            }) {
                Text(">")
                    .font(.custom("xkcd-Script-Regular", size: 15))
            }
        }
    }
}

// MARK: - ComicListViewModel

class ComicListViewModel: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
    private var controller: NSFetchedResultsController<Comic>?
    var fetchBatchSize = 20
//    var fetchLimit = 20
    var fetchOffset = 0
    var query: String?
    var scopeIndex: Int
    
    // MARK: Initializer
    init(query: String?, scopeIndex: Int) {
        self.query = query
        self.scopeIndex = scopeIndex
        super.init()
        
        loadData()
    }
 
    // MARK: NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        objectWillChange.send()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        objectWillChange.send()
    }
    
    // MARK: Custom methods
    var comics: [Comic] {
        return controller?.fetchedObjects ?? []
    }
    
    func createFetchRequest(query: String?, scopeIndex: Int) -> NSFetchRequest<Comic> {
        var predicate: NSPredicate?
        
        if let query = query {
            if query.count == 1 {
                predicate = NSPredicate(format: "num BEGINSWITH[cd] %@ OR title BEGINSWITH[cd] %@", query, query)
            } else if query.count > 1 {
                predicate = NSPredicate(format: "num CONTAINS[cd] %@ OR title CONTAINS[cd] %@ OR alt CONTAINS[cd] %@", query, query, query)
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
        fetchRequest.fetchOffset = fetchOffset
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
            fetchOffset += fetchBatchSize
//            fetchLimit += fetchOffset
        } catch {
            print(error)
        }
    }
}

