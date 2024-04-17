//
//  ComicListView.swift
//  dckx
//
//  Created by Vito Royeca on 2/21/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI
import SwiftData

enum SearchScope: String, CaseIterable {
    case all, bookmark
}

// MARK: - ComicListView

struct  ComicListView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var selectComicAction: (ComicModel) -> Void
    
    @State private var predicate: Predicate<ComicModel>?
    @State private var numSorter = SortDescriptor(\ComicModel.num, order: .reverse)
    @State private var searchText = ""
    @State private var searchScope = SearchScope.all
    
    init(selectComicAction: @escaping (ComicModel) -> Void) {
        self.selectComicAction = selectComicAction
    }

    var body: some View {
        ComicListDisplayView(predicate: predicate,
                             sorter: [numSorter],
                             selectComicAction: select(comic:))
        .listStyle(.plain)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                closeButton
            }
        }
        .navigationTitle(Text("xkcd"))
        .searchable(text: $searchText,
                    prompt: "Search")
        .searchScopes($searchScope) {
            ForEach(SearchScope.allCases, id: \.self) { scope in
                Text(scope.rawValue.capitalized)
            }
        }
        .onSubmit(of: .search) {
            doSearch()
        }
        .onChange(of: searchText) {
            doSearch()
        }
        .onChange(of: searchScope) {
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
}

extension ComicListView {
    func doSearch() {
        if searchText.count == 1 {
            let lowerSearchText = searchText.localizedUppercase

            if searchScope == .all {
                predicate = #Predicate { comic in
                    comic.title.starts(with: lowerSearchText)
                }
            } else {
                predicate = #Predicate { comic in
                    comic.isFavorite == true &&
                    comic.title.starts(with: lowerSearchText)
                }
            }
        } else if searchText.count > 1 {
            if searchScope == .all {
                predicate = #Predicate { comic in
                    comic.title.localizedStandardContains(searchText)
                }
            } else {
                predicate = #Predicate { comic in
                    comic.isFavorite == true &&
                    comic.title.localizedStandardContains(searchText)
                }
            }
        } else {
            if searchScope == .all {
                predicate = nil
            } else {
                predicate = #Predicate { comic in
                    comic.isFavorite == true
                }
            }
        }
    }
    
    func select(comic: ComicModel) {
        presentationMode.wrappedValue.dismiss()
        selectComicAction(comic)
    }
}

// MARK: - ComicListDisplayView

struct ComicListDisplayView: View {
    var selectComicAction: (ComicModel) -> Void
    
    @AppStorage(SettingsKey.useSystemFont) private var useSystemFont = false
    @Query private var comics: [ComicModel]

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
                            thumbnail: comic.imageURL,
                            title: comic.title,
                            isFavorite: comic.isFavorite,
                            date: comic.displayDate,
                            useSystemFont: useSystemFont)
                .listRowSeparator(.hidden)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectComicAction(comic)
                }
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - Previews

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

