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
    @State private var searchText = ""
    var fetcher: ComicFetcher

    @FetchRequest(
        entity: Comic.entity(),
        sortDescriptors: [NSSortDescriptor(key: "num", ascending: false)],
        predicate: nil
    ) var allComics: FetchedResults<Comic>
    
    var body: some View {
        VStack {
            HStack {
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
            
            Spacer()
            
            SearchBar(text: $searchText)
            
            Spacer()
            
            List {
                ForEach(allComics) { comic in
                    ComicRow(num: comic.num,
                             title: comic.title ?? "",
                             action: {self.selectComic(num: comic.num)})
                        .onTapGesture { self.selectComic(num: comic.num) }
                }
            }
        }
    }
    
    func selectComic(num: Int32) {
        print("\(num)")
        fetcher.loadComic(num: num)
        presentationMode.wrappedValue.dismiss()
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(fetcher: ComicFetcher()).environment(\.managedObjectContext, CoreData.sharedInstance.dataStack.viewContext)
    }
}

struct SearchBar: UIViewRepresentable {
    @Binding var text: String

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }
    
    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text)
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
        uiView.text = text
    }
}

struct ComicRow: View {
    var num: Int32
    var title: String
    var action: () -> Void
    
    var body: some View {
        HStack {
            Text("#\(String(num)): \(title)")
                .font(.custom("xkcd-Script-Regular", size: 15))
            Spacer()
            Button(action: {
                
            }) {
                Text(">")
                    .font(.custom("xkcd-Script-Regular", size: 15))
            }
        }
    }
}

