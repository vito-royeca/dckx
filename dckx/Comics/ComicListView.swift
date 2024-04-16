//
//  ComicListView.swift
//  dckx
//
//  Created by Vito Royeca on 2/21/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI
import SwiftData

// MARK: - ComicListView

struct  ComicListView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var selectComicAction: (ComicModel) -> Void
    
    @State private var predicate: Predicate<ComicModel>?
    @State private var numSorter = SortDescriptor(\ComicModel.num, order: .reverse)
    @State private var searchText = ""
    
    init(selectComicAction: @escaping (ComicModel) -> Void) {
        self.selectComicAction = selectComicAction
    }

    var body: some View {
        ComicListDisplayView(predicate: predicate,
                             sorter: [numSorter],
                             selectComicAction: selectComicAction)
        .listStyle(.plain)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                closeButton
            }
        }
        .navigationTitle(Text("xkcd"))
        .searchable(text: $searchText,
                    prompt: "Search")
        .onSubmit(of: .search) {
            doSearch()
        }
        .onChange(of: searchText) {
            doSearch()
        }
    }
    
    var closeButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "xmark.circle")
                .imageScale(.large)
        }
    }
    
    func doSearch() {
        predicate = nil

        if searchText.count == 1 {
            predicate = #Predicate { comic in
                comic.title.starts(with: searchText)
            }
        } else if searchText.count > 1 {
            predicate = #Predicate { comic in
                comic.title.localizedStandardContains(searchText)
            }
        }
    }
}

struct ComicListDisplayView: View {
    @Environment(\.presentationMode) var presentationMode
    @Query private var comics: [ComicModel]

    var selectComicAction: (ComicModel) -> Void
    
    init(predicate: Predicate<ComicModel>?,
         sorter: [SortDescriptor<ComicModel>],
         selectComicAction: @escaping (ComicModel) -> Void) {
        var descriptor = FetchDescriptor<ComicModel>(predicate: predicate,
                                                     sortBy: sorter)
        descriptor.propertiesToFetch = [\.num,
                                        \.title,
                                        \.year,
                                        \.month,
                                        \.day,
                                        \.img,
                                        \.isFavorite]
        
        _comics = Query(FetchDescriptor<ComicModel>(predicate: predicate,
                                                    sortBy: [SortDescriptor(\.num, order: .reverse)]))
        self.selectComicAction = selectComicAction
        
    }
    
    var body: some View {
        List {
            ForEach(comics, id: \.num) { comic in
                ListRowView(num: comic.num,
                            thumbnail: comic.img,
                            title: comic.title,
                            isFavorite: comic.isFavorite,
                            date: comic.displayDate)
                    .listRowSeparator(.hidden)
                    .onTapGesture {
                        select(comic: comic)
                    }
            }
        }
        .listStyle(.plain)
    }
    
    func select(comic: ComicModel) {
        selectComicAction(comic)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - ListView_Previews

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ComicModel.self,
                                           configurations: config)
        return ComicListView(selectComicAction: { comic in } )
            .modelContainer(container)
    } catch {
        return EmptyView()
    }
}

