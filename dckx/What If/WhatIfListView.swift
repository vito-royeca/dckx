//
//  WhatIfListView.swift
//  dckx
//
//  Created by Vito Royeca on 3/10/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI
import Combine
import CoreData
import PromiseKit
import SDWebImage

struct WhatIfListView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var viewModel: WhatIfListViewModel = WhatIfListViewModel()
    @State var shouldAnimate: Bool = false
    var fetcher: WhatIfFetcher
    
    init(fetcher: WhatIfFetcher) {
        self.fetcher = fetcher
    }
    
    var body: some View {
        VStack {
            WhatIfListTitleView(presentationMode: presentationMode)
            
            Spacer()
            
            WhatIfSearchBar(viewModel: $viewModel,
                            shouldAnimate: $shouldAnimate)
            
            Spacer()
            
            ZStack(alignment: .center) {
                WhatIfTextListView(viewModel: $viewModel,
                                   action: selectWhatIf(num:))
                ActivityIndicatorView(shouldAnimate: $shouldAnimate)
            }
        }
    }
    
    func selectWhatIf(num: Int32) {
        fetcher.load(num: num)
        presentationMode.wrappedValue.dismiss()
    }
}

struct WhatIfListView_Previews: PreviewProvider {
    static var previews: some View {
        WhatIfListView(fetcher: WhatIfFetcher())
    }
}

// MARK: WhatIfListTitleView
struct WhatIfListTitleView: View {
    var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        HStack {
            Spacer()
            
            Text("What If? List")
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

// MARK: WhatIfSearchBar
struct WhatIfSearchBar: UIViewRepresentable {
    @Binding var viewModel: WhatIfListViewModel
    @Binding var shouldAnimate: Bool
    @State var query: String = ""
    @State var scopeIndex: Int = 0
    
    init(viewModel: Binding<WhatIfListViewModel>,
        shouldAnimate: Binding<Bool>) {
        _viewModel = viewModel
        _shouldAnimate = shouldAnimate
    }
    
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var query: String
        @Binding var scopeIndex: Int
        @Binding var viewModel: WhatIfListViewModel
        @Binding var shouldAnimate: Bool

        init(query: Binding<String>,
             scopeIndex: Binding<Int>,
             viewModel: Binding<WhatIfListViewModel>,
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
                self.viewModel = WhatIfListViewModel(query: self.query,
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
                self.viewModel = WhatIfListViewModel(query: self.query,
                                                     scopeIndex: self.scopeIndex)
                
                DispatchQueue.main.async {
                    self.shouldAnimate = false
                }
            }
        }
    }
    
    func makeCoordinator() -> WhatIfSearchBar.Coordinator {
        return Coordinator(query: $query,
                           scopeIndex: $scopeIndex,
                           viewModel: $viewModel,
                           shouldAnimate: $shouldAnimate)
    }

    func makeUIView(context: UIViewRepresentableContext<WhatIfSearchBar>) -> UISearchBar {
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

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<WhatIfSearchBar>) {
        uiView.text = query
        uiView.selectedScopeButtonIndex = scopeIndex
    }
}

// MARK: WhatIfTextListView
struct WhatIfTextListView: View {
    @Binding var viewModel: WhatIfListViewModel
    var action: (Int32) -> Void
    
    init(viewModel: Binding<WhatIfListViewModel>, action: @escaping (Int32) -> Void) {

        _viewModel = viewModel
        self.action = action
    }
    
    var body: some View {
        VStack {
            List(viewModel.whatIfs) { whatIf in
                WhatIfListRow(num: whatIf.num,
                              thumbnail: whatIf.thumbnail ?? "",
                              title: whatIf.title ?? "",
                              action: self.action)
                    .onTapGesture { self.action(whatIf.num) }
            }
                .resignKeyboardOnDragGesture()
        }
    }
}

// MARK: WhatIfListViewModel
class WhatIfListViewModel: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
    private var controller: NSFetchedResultsController<WhatIf>?
 
    override convenience init() {
        self.init(query: "", scopeIndex: 0)
    }
    
    init(query: String, scopeIndex: Int) {
        super.init()
        let fetchRequest = createFetchRequest(query: query,
                                              scopeIndex: scopeIndex)
        
        controller = NSFetchedResultsController<WhatIf>(fetchRequest: fetchRequest,
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
     
    var whatIfs: [WhatIf] {
        return controller?.fetchedObjects ?? []
    }
    
    func createFetchRequest(query: String, scopeIndex: Int) -> NSFetchRequest<WhatIf> {
        var predicate: NSPredicate?
        
        if query.count == 1 {
            predicate = NSPredicate(format: "num BEGINSWITH[cd] %@ OR title BEGINSWITH[cd] %@", query, query)
        } else if query.count > 1 {
            predicate = NSPredicate(format: "num CONTAINS[cd] %@ OR title CONTAINS[cd] %@ OR alt CONTAINS[cd] %@", query, query, query)
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
        
        let fetchRequest: NSFetchRequest<WhatIf> = WhatIf.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "num", ascending: false)]
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 20
        
        return fetchRequest
    }
}

// MARK: WhatIfListRow
struct WhatIfListRow: View {
    var num: Int32
    var thumbnail: String
    var title: String
    var action: (Int32) -> Void
    
    var body: some View {
        HStack {
            VStack {
                Image(uiImage: SDImageCache.shared.imageFromCache(forKey: thumbnail) ?? UIImage(named: "logo")!)
                .resizable()
                .frame(width: 50, height: 50)
            }
                .background(Color.white)
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
    
    func fetchThumbnail(thumbnail: String) -> Promise<UIImage> {
        return Promise { seal in
            if let image = SDImageCache.shared.imageFromCache(forKey: thumbnail) {
                seal.fulfill(image)
            } else {
                let callback = { (image: UIImage?, data: Data?, error: Error?, finished: Bool) in
                    if let error = error {
                        seal.reject(error)
                    } else {
                        SDWebImageManager.shared.imageCache.store(image,
                                                                  imageData: data,
                                                                  forKey: thumbnail,
                                                                  cacheType: .disk,
                                                                  completion: {
                                                                    seal.fulfill(image ?? UIImage(named: "logo")!)
                        })
                    }
                }
                SDWebImageManager.shared.imageLoader.requestImage(with: URL(string: thumbnail),
                                                                  options: .highPriority,
                                                                  context: nil,
                                                                  progress: nil,
                                                                  completed: callback)
            }
        }
    }
}

