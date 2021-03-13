//
//  ListView.swift
//  dckx
//
//  Created by Vito Royeca on 3/13/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI
import CoreData
import SDWebImage

// MARK: ListViewDelegate
protocol ListViewDelegate {
    func select(objectID: NSManagedObjectID)
}

struct ListView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var viewModel: ListViewModel = ListViewModel(query: nil, scopeIndex: 0)
    @State var shouldAnimate: Bool = false
    var delegate: ListViewDelegate?
    var title: String
    
    init(title: String, delegate: ListViewDelegate?) {
        self.title = title
        self.delegate = delegate
    }
    
    var body: some View {
        VStack {
            ListTitleView(title: title,
                          presentationMode: presentationMode)
            
            Spacer()
            
            SearchBar(viewModel: $viewModel,
                      shouldAnimate: $shouldAnimate)
            
            Spacer()
            
            ZStack(alignment: .center) {
                TextListView(viewModel: $viewModel,
                             action: select(objectID:))
                ActivityIndicatorView(shouldAnimate: $shouldAnimate)
            }
        }
    }
    
    func select(objectID: NSManagedObjectID) {
        delegate?.select(objectID: objectID)
        presentationMode.wrappedValue.dismiss()
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(title: "Title", delegate: nil)
    }
}

// MARK: ListTitleView
struct ListTitleView: View {
    var title: String
    var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        HStack {
            Spacer()
            
            Text(title)
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

// MARK: SearchBar
struct SearchBar: UIViewRepresentable {
    @State var query: String = ""
    @State var scopeIndex: Int = 0
    @Binding var viewModel: ListViewModel<CoreDataObject>
    @Binding var shouldAnimate: Bool
    
    init(viewModel: Binding<ListViewModel<CoreDataObject>>,
        shouldAnimate: Binding<Bool>) {
        _viewModel = viewModel
        _shouldAnimate = shouldAnimate
    }
    
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var query: String
        @Binding var scopeIndex: Int
        @Binding var viewModel: ListViewModel<CoreDataObject>
        @Binding var shouldAnimate: Bool

        init(query: Binding<String>,
             scopeIndex: Binding<Int>,
             viewModel: Binding<ListViewModel<CoreDataObject>>,
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
                self.viewModel = ListViewModel(query: self.query,
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
                self.viewModel = ListViewModel(query: self.query,
                                               scopeIndex: self.scopeIndex)
                
                DispatchQueue.main.async {
                    self.shouldAnimate = false
                }
            }
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

// MARK: TextListView
struct TextListView: View {
    @Binding var viewModel: ListViewModel<CoreDataObject>
    var action: (NSManagedObjectID) -> Void
    
    init(viewModel: Binding<ListViewModel<CoreDataObject>>, action: @escaping (NSManagedObjectID) -> Void) {
        _viewModel = viewModel
        self.action = action
    }
    
    var body: some View {
        VStack {
            List(viewModel.objects) { object in
                ListViewRow(imageLink: "",
                            text: "",
                            objectID: object,
                            action: self.action)
                    .onTapGesture {
                        self.action(object)
                    }
                    .onAppear(perform: {
                        if self.viewModel.shouldLoadMore(object: object) {
                            self.viewModel.loadData()
                        }
                    })
            }
                .resignKeyboardOnDragGesture()
        }
    }
}

struct ListViewRow: View {
    var imageLink: String
    var text: String
    var objectID: NSManagedObjectID
    var action: (NSManagedObjectID) -> Void
    
    var body: some View {
        HStack {
            VStack {
                Image(uiImage: SDImageCache.shared.imageFromCache(forKey: imageLink) ?? UIImage(named: "logo")!)
                    .resizable()
                    .frame(width: 50, height: 50)
            }
                .background(Color.white)
            Text(text)
                .font(.custom("xkcd-Script-Regular", size: 15))
            Spacer()
            Button(action: {
                self.action(self.objectID)
            }) {
                Text(">")
                    .font(.custom("xkcd-Script-Regular", size: 15))
            }
        }
    }
}

// MARK: ListViewModel
class ListViewModel<T: CoreDataObject>: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
    private var controller: NSFetchedResultsController<T>?
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
 
    // MARK: Custom methods
    var objects: [T] {
        return controller?.fetchedObjects ?? []
    }
    
    func createFetchRequest(query: String?, scopeIndex: Int) -> NSFetchRequest<T> {
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
        
        let fetchRequest: NSFetchRequest<T> = NSFetchRequest<T>(entityName: "Comic")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "num", ascending: false)]
        fetchRequest.predicate = predicate
        
        return fetchRequest
    }
    
    func shouldLoadMore(object: T) -> Bool {
        return false
    }
    
    func loadData() {
        let fetchRequest = createFetchRequest(query: query,
                                              scopeIndex: scopeIndex)
        fetchRequest.fetchOffset = fetchOffset
        fetchRequest.fetchLimit = fetchLimit
        
        controller = NSFetchedResultsController<T>(fetchRequest: fetchRequest,
                                                   managedObjectContext: CoreData.sharedInstance.dataStack.viewContext,
                                                   sectionNameKeyPath: nil,
                                                   cacheName: ListViewModel.description())
        controller!.delegate = self
        
        do {
            NSFetchedResultsController<T>.deleteCache(withName: controller!.cacheName)
            try controller!.performFetch()
            fetchOffset += fetchBatchSize
            fetchLimit += fetchOffset
        } catch {
            print(error)
        }
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        objectWillChange.send()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        objectWillChange.send()
    }
}
