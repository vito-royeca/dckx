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

// MARK: ComicListView
struct  ComicListView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var viewModel: ComicListViewModel = ComicListViewModel(query: nil, scopeIndex: 0)
    @State var shouldAnimate: Bool = false
    var fetcher: ComicFetcher
    
    init(fetcher: ComicFetcher) {
        self.fetcher = fetcher
    }
    
    var body: some View {
        VStack {
            ComicListTitleView(presentationMode: presentationMode)
            
            Spacer()
            
            ComicSearchBar(viewModel: $viewModel,
                           shouldAnimate: $shouldAnimate)
            
            Spacer()
            
            ZStack(alignment: .center) {
                ComicTextListView(viewModel: $viewModel,
                                  action: selectComic(num:))
                ActivityIndicatorView(shouldAnimate: $shouldAnimate)
            }
        }
    }
    
    func selectComic(num: Int32) {
        fetcher.load(num: num)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: ListView_Previews
struct ComicListView_Previews: PreviewProvider {
    static var previews: some View {
        ComicListView(fetcher: ComicFetcher())
    }
}

// MARK: ListTitleView
struct ComicListTitleView: View {
    var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        HStack {
            Spacer()
            
            Text("Comics List")
                .font(.custom("xkcd-Script-Regular", size: 20))
            
            Spacer()
            
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("X")
                    .customButton(isDisabled: false)
            }
        }
        .padding(5)
    }
}

// MARK: ComicSearchBar
struct ComicSearchBar: UIViewRepresentable {
    @State var query: String = ""
    @State var scopeIndex: Int = 0
    @Binding var viewModel: ComicListViewModel
    @Binding var shouldAnimate: Bool
    
    init(viewModel: Binding<ComicListViewModel>,
        shouldAnimate: Binding<Bool>) {
        _viewModel = viewModel
        _shouldAnimate = shouldAnimate
    }
    
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var query: String
        @Binding var scopeIndex: Int
        @Binding var viewModel: ComicListViewModel
        @Binding var shouldAnimate: Bool

        init(query: Binding<String>,
             scopeIndex: Binding<Int>,
             viewModel: Binding<ComicListViewModel>,
             shouldAnimate: Binding<Bool>) {
            _query = query
            _scopeIndex = scopeIndex
            _viewModel = viewModel
            _shouldAnimate = shouldAnimate
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            // Throttle typing in the Search bar
            NSObject.cancelPreviousPerformRequests(withTarget: self,
                                                   selector: #selector(self.reloadQuery(_:)),
                                                   object: searchBar)
            perform(#selector(self.reloadQuery(_:)),
                    with: searchBar,
                    afterDelay: 0.75)
        }
        
        func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
            // Throttle selecting scope in the Search bar
            NSObject.cancelPreviousPerformRequests(withTarget: self,
                                                   selector: #selector(self.reloadSearchScope(_:)),
                                                   object: searchBar)
            perform(#selector(self.reloadSearchScope(_:)),
                    with: searchBar,
                    afterDelay: 0.75)
        }
        
        @objc func reloadQuery(_ searchBar: UISearchBar) {
            guard let text = searchBar.text else {
                return
            }
            
            self.query = text
            
            DispatchQueue.global(qos: .background).async {
                self.shouldAnimate = true
                self.viewModel = ComicListViewModel(query: self.query,
                                                    scopeIndex: self.scopeIndex)
                
                DispatchQueue.main.async {
                    self.shouldAnimate = false
                }
            }
        }
        
        @objc func reloadSearchScope(_ searchBar: UISearchBar) {
            self.scopeIndex = searchBar.selectedScopeButtonIndex
            
            DispatchQueue.global(qos: .background).async {
                self.shouldAnimate = true
                self.viewModel = ComicListViewModel(query: self.query,
                                                    scopeIndex: self.scopeIndex)
                
                DispatchQueue.main.async {
                    self.shouldAnimate = false
                }
            }
        }
    }
    
    func makeCoordinator() -> ComicSearchBar.Coordinator {
        return Coordinator(query: $query,
                           scopeIndex: $scopeIndex,
                           viewModel: $viewModel,
                           shouldAnimate: $shouldAnimate)
    }

    func makeUIView(context: UIViewRepresentableContext<ComicSearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.autocapitalizationType = .none
        searchBar.scopeButtonTitles = ["All", "Bookmarked", "Read"]
        searchBar.showsScopeBar = true

        if let font = UIFont(name: "xkcd Script", size: 15) {
            let attrs = [
                NSAttributedString.Key.font: font
            ]
            searchBar.setScopeBarButtonTitleTextAttributes(attrs, for: .normal)
            searchBar.searchTextField.font = font
        }
        
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<ComicSearchBar>) {
        uiView.text = query
        uiView.selectedScopeButtonIndex = scopeIndex
    }
}

// MARK: ComicTextListView
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

// MARK: ComicListViewModel
class ComicListViewModel: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
    private var controller: NSFetchedResultsController<Comic>?
    var fetchBatchSize = 20
    var fetchLimit = 20
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
        case 0:
            ()
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
        fetchRequest.fetchLimit = fetchLimit
        
        
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
            fetchLimit += fetchOffset
        } catch {
            print(error)
        }
    }
}

// MARK: ComicListRow
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
