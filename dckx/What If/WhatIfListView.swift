//
//  WhatIfListView.swift
//  dckx
//
//  Created by Vito Royeca on 3/10/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI
import SwiftData

// MARK: - WhatIfListView

struct WhatIfListView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var selectWhatIfAction: (WhatIfModel) -> Void
    
    @State private var predicate: Predicate<WhatIfModel>?
    @State private var numSorter = SortDescriptor(\WhatIfModel.num, order: .reverse)
    @State private var searchText = ""
    @State private var searchScope = SearchScope.all
    
    init(selectWhatIfAction: @escaping (WhatIfModel) -> Void) {
        self.selectWhatIfAction = selectWhatIfAction
    }
    
    var body: some View {
        WhatIfListDisplayView(predicate: predicate,
                              sorter: [numSorter],
                              selectWhatIfAction: select(whatIf:))
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

extension WhatIfListView {
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
    
    func select(whatIf: WhatIfModel) {
        presentationMode.wrappedValue.dismiss()
        selectWhatIfAction(whatIf)
    }
}

// MARK: - Previews

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: WhatIfModel.self,
                                           configurations: config)
        return WhatIfListView(selectWhatIfAction: { whatIf in } )
            .modelContainer(container)
    } catch {
        return EmptyView()
    }
}

// MARK: - WhatIfListDisplayView

struct WhatIfListDisplayView: View {
    var selectWhatIfAction: (WhatIfModel) -> Void
    
    @Query private var whatIfs: [WhatIfModel]

    init(predicate: Predicate<WhatIfModel>?,
         sorter: [SortDescriptor<WhatIfModel>],
         selectWhatIfAction: @escaping (WhatIfModel) -> Void) {
        var descriptor = FetchDescriptor<WhatIfModel>(predicate: predicate,
                                                      sortBy: sorter)
        descriptor.propertiesToFetch = [\.num,
                                        \.title,
                                        \.year,
                                        \.month,
                                        \.day,
                                        \.question,
                                        \.questioner,
                                        \.answer,
                                        \.isFavorite]
        
        _whatIfs = Query(FetchDescriptor<WhatIfModel>(predicate: predicate,
                                                      sortBy: [SortDescriptor(\.num, order: .reverse)]))
        self.selectWhatIfAction = selectWhatIfAction
    }
    
    var body: some View {
        List {
            ForEach(whatIfs, id: \.num) { whatIf in
                ListRowView(num: whatIf.num,
                            thumbnail: whatIf.imageURL,
                            title: whatIf.title,
                            isFavorite: whatIf.isFavorite,
                            date: whatIf.displayDate)
                .listRowSeparator(.hidden)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectWhatIfAction(whatIf)
                }
            }
        }
        .listStyle(.plain)
    }
}
