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
    @State var query: String
    @State var scopeIndex: Int
    var fetcher: ComicFetcher

    
    func createPredicate() -> NSPredicate {
        return NSPredicate(format: "title CONTAINS[cd] %@", "$searchText.wrappedValue")
    }
    
    var body: some View {
        VStack {
            ListTitleView(presentationMode: presentationMode)
            
            Spacer()
            
            SearchBar(query: $query, scopeIndex: $scopeIndex)
            
            Spacer()
            
            ComicListView(query: query, scopeIndex: scopeIndex, action: selectComic(num:))
        }
    }
    
    func selectComic(num: Int32) {
        fetcher.loadComic(num: num)
        presentationMode.wrappedValue.dismiss()
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(query: "",
                 scopeIndex: 0,
                 fetcher: ComicFetcher())
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
    @Binding var query: String
    @Binding var scopeIndex: Int
    
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var query: String
        @Binding var scopeIndex: Int
        
        init(query: Binding<String>, scopeIndex: Binding<Int>) {
            _query = query
            _scopeIndex = scopeIndex
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            query = searchText
        }
        
        func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
            scopeIndex = selectedScope
        }
    }
    
    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(query: $query, scopeIndex: $scopeIndex)
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
//        uiView.text = text
    }
}

struct ComicListView: View {
    var fetchRequest: FetchRequest<Comic>
    var action: (Int32) -> Void
    
    init(query: String, scopeIndex: Int, action: @escaping (Int32) -> Void) {
        self.action = action
        
        var predicate: NSPredicate?
        // TODO: Handle comic.num
        if query.count == 1 {
            predicate = NSPredicate(format: "num BEGINSWITH[cd] %@ OR title BEGINSWITH[cd] %@ OR alt BEGINSWITH[cd] %@", query, query, query)
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
        
        fetchRequest = FetchRequest<Comic>(entity: Comic.entity(),
                                           sortDescriptors: [NSSortDescriptor(key: "num", ascending: false)],
                                           predicate: predicate)
    }
    
    var body: some View {
        HStack {
            List(fetchRequest.wrappedValue) { comic in
                ComicRow(num: comic.num,
                         title: comic.title ?? "",
                         action: self.action)
                    .onTapGesture { self.action(comic.num) }
            }
                .resignKeyboardOnDragGesture()
        }
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

