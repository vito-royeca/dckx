//
//  ListView.swift
//  dckx
//
//  Created by Vito Royeca on 2/21/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI
import Combine
import CoreData

struct  ListView: View {
    @Environment(\.managedObjectContext) var mainContext
    @Environment(\.presentationMode) var presentationMode
    @State var viewModel: ComicListViewModel = ComicListViewModel(fetchRequest: nil)
    @State var shouldAnimate: Bool = false
    
    var fetcher: ComicFetcher

    
    init(fetcher: ComicFetcher) {
        self.fetcher = fetcher
    }
    
    var body: some View {
        VStack {
            ListTitleView(presentationMode: presentationMode)
            
            Spacer()
            
            SearchBar(viewModel: $viewModel,
                      shouldAnimate: $shouldAnimate)
            
            Spacer()
            
            ZStack(alignment: .center) {
                ComicListView(viewModel: $viewModel,
                              action: selectComic(num:))
                ActivityIndicator(shouldAnimate: $shouldAnimate)
            }
        }
    }
    
    func selectComic(num: Int32) {
        fetcher.loadComic(num: num)
        presentationMode.wrappedValue.dismiss()
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(fetcher: ComicFetcher())
            .environment(\.managedObjectContext,  CoreData.sharedInstance.dataStack.viewContext)
    }
}

struct ListTitleView: View {
    var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        HStack {
            Spacer()
            
            Text("List")
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

struct SearchBar: UIViewRepresentable {
    @Binding var viewModel: ComicListViewModel
    @Binding var shouldAnimate: Bool
    @State var query: String = ""
    @State var scopeIndex: Int = 0
    
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
                self.viewModel = ComicListViewModel(fetchRequest: self.createFetchRequest())
                
                DispatchQueue.main.async {
                    self.shouldAnimate = false
                }
            }
        }
        
        @objc func reloadSearchScope(_ searchBar: UISearchBar) {
            self.scopeIndex = searchBar.selectedScopeButtonIndex
            
            DispatchQueue.global(qos: .background).async {
                self.shouldAnimate = true
                self.viewModel = ComicListViewModel(fetchRequest: self.createFetchRequest())
                
                DispatchQueue.main.async {
                    self.shouldAnimate = false
                }
            }
        }
        
        func createFetchRequest() -> NSFetchRequest<Comic> {
            let param = query
            var predicate: NSPredicate?
            
            if query.count == 1 {
                
                predicate = NSPredicate(format: "num BEGINSWITH[cd] %@ OR title BEGINSWITH[cd] %@", param, param)
            } else if query.count > 1 {
                predicate = NSPredicate(format: "num CONTAINS[cd] %@ OR title CONTAINS[cd] %@ OR alt CONTAINS[cd] %@", param, param, param)
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
            
            return fetchRequest
        }
    }
    
    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(query: $query,
                           scopeIndex: $scopeIndex,
                           viewModel: $viewModel,
                           shouldAnimate: $shouldAnimate)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
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

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = query
        uiView.selectedScopeButtonIndex = scopeIndex
    }
}

struct ComicListView: View {
    @Binding var viewModel: ComicListViewModel
    var action: (Int32) -> Void
    
    init(viewModel: Binding<ComicListViewModel>, action: @escaping (Int32) -> Void) {

        _viewModel = viewModel
        self.action = action
    }
    
    var body: some View {
        VStack {
            List(viewModel.comics) { comic in
                ComicRow(num: comic.num,
                         title: comic.title ?? "",
                         action: self.action)
                    .onTapGesture { self.action(comic.num) }
            }
                .resignKeyboardOnDragGesture()
        }
    }
}

class ComicListViewModel: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
    private var controller: NSFetchedResultsController<Comic>?
 
    init(fetchRequest: NSFetchRequest<Comic>?) {
        super.init()
        var fr = fetchRequest
        
        if fr == nil {
            fr = Comic.fetchRequest()
            fr!.sortDescriptors = [NSSortDescriptor(key: "num", ascending: false)]
        }
        
        
        controller = NSFetchedResultsController<Comic>(fetchRequest: fr!,
                                                       managedObjectContext: CoreData.sharedInstance.dataStack.viewContext,
                                                       sectionNameKeyPath: nil,
                                                       cacheName: nil)
        controller!.delegate = self
        
        do {
            try controller!.performFetch()
        } catch {
            print(error)
        }
    }
 
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        objectWillChange.send()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        objectWillChange.send()
    }
     
    var comics: [Comic] {
        return controller?.fetchedObjects ?? []
    }
}

struct ComicRow: View {
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

struct ActivityIndicator: UIViewRepresentable {
    @Binding var shouldAnimate: Bool
    
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        return UIActivityIndicatorView()
    }

    func updateUIView(_ uiView: UIActivityIndicatorView,
                      context: Context) {
        if self.shouldAnimate {
            uiView.startAnimating()
            
        } else {
            uiView.stopAnimating()
        }
    }
}
