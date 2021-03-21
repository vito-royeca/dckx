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
import SDWebImageSwiftUI

// MARK: - WhatIfListView

struct WhatIfListView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var fetcher: WhatIfFetcher
    @State var query: String?
    @State var scopeSelection: Int = 0
    
    @State var viewModel: WhatIfListViewModel = WhatIfListViewModel(query: nil,
                                                                    scopeIndex: 0)
    @State var shouldAnimate: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .center) {
                WhatIfTextListView(action: selectWhatIf(num:))
                ActivityIndicatorView(shouldAnimate: $shouldAnimate)
            }
            .navigationBarTitle(Text("What If?"), displayMode: .automatic)
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
                                        WhatIfTextListView(action: selectWhatIf(num:))
                                        ActivityIndicatorView(shouldAnimate: $shouldAnimate)
                                    }
                                 })
        }
        .environmentObject(viewModel)
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
    
    func selectWhatIf(num: Int32) {
        fetcher.load(num: num)
        presentationMode.wrappedValue.dismiss()
    }
    
    // MARK: - SearchBar methods
    
    func doSearch() {
//        print("\(Date()): query=\(self.query), scope=\(self.scopeSelection)")

        DispatchQueue.global(qos: .background).async {
            self.shouldAnimate = true
            self.viewModel = WhatIfListViewModel(query: self.query,
                                                 scopeIndex: self.scopeSelection)
            
            DispatchQueue.main.async {
                self.shouldAnimate = false
            }
        }
    }
}

// MARK: - ListView_Previews

struct WhatIfListView_Previews: PreviewProvider {
    static var previews: some View {
        WhatIfListView().environmentObject(WhatIfFetcher())
    }
}

// MARK: - WhatIfTextListView

struct WhatIfTextListView: View {
    @EnvironmentObject var viewModel: WhatIfListViewModel
    var action: (Int32) -> Void
    
    var body: some View {
        VStack {
            List(viewModel.whatIfs) { whatIf in
                WhatIfListRow(num: whatIf.num,
                              thumbnail: whatIf.thumbnail ?? "",
                              title: whatIf.title ?? "",
                              action: self.action)
                    .onTapGesture {
                        self.action(whatIf.num)
                    }
                    .onAppear(perform: {
                        if self.viewModel.shouldLoadMore(whatIf: whatIf) {
                            self.viewModel.loadData()
                        }
                    })
            }
            .resignKeyboardOnDragGesture()
        }
    }
}

// MARK: - WhatIfListRow

struct WhatIfListRow: View {
    var num: Int32
    var thumbnail: String
    var title: String
    var action: (Int32) -> Void
    @ObservedObject var imageManager: ImageManager
    
    init(num: Int32, thumbnail: String, title: String, action: @escaping (Int32) -> Void) {
        self.num = num
        self.thumbnail = thumbnail
        self.title = title
        self.action = action
        imageManager = ImageManager(url: URL(string: thumbnail))
    }
    
    var body: some View {
        HStack {
            VStack {
                Image(uiImage: imageManager.image ?? UIImage(named: "logo")!)
                .resizable()
                .frame(width: 50, height: 50)
            }
                .background(Color.white)
                .onAppear {
                    self.imageManager.load()
                }
                .onDisappear {
                    self.imageManager.cancel()
                }
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

// MARK: - WhatIfListViewModel

class WhatIfListViewModel: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
    @Published var query: String?
    @Published var scopeIndex: Int
    
    private var controller: NSFetchedResultsController<WhatIf>?
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
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        objectWillChange.send()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        objectWillChange.send()
    }
    
    // MARK: Custom methods
    var whatIfs: [WhatIf] {
        return controller?.fetchedObjects ?? []
    }
    
    func createFetchRequest(query: String?, scopeIndex: Int) -> NSFetchRequest<WhatIf> {
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
        
        let fetchRequest: NSFetchRequest<WhatIf> = WhatIf.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "num", ascending: false)]
        fetchRequest.predicate = predicate
//        fetchRequest.fetchOffset = fetchOffset
//        fetchRequest.fetchLimit = fetchLimit
        
        return fetchRequest
    }
    
    func shouldLoadMore(whatIf: WhatIf) -> Bool{
        if let last = whatIfs.last {
            return whatIf.num ==  last.num
        }
        return false
    }
    
    func loadData() {
        let fetchRequest = createFetchRequest(query: query,
                                              scopeIndex: scopeIndex)
        
        controller = NSFetchedResultsController<WhatIf>(fetchRequest: fetchRequest,
                                                        managedObjectContext: CoreData.sharedInstance.dataStack.viewContext,
                                                        sectionNameKeyPath: nil,
                                                        cacheName: "WhatIfCache")
        controller!.delegate = self
        
        do {
            NSFetchedResultsController<WhatIf>.deleteCache(withName: controller!.cacheName)
            try controller!.performFetch()
            fetchOffset += fetchBatchSize
//            fetchLimit += fetchOffset
        } catch {
            print(error)
        }
    }
}


