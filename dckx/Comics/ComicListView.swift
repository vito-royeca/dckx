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
    @State var viewModel: ComicListViewModel
    var selectComicAction: (ComicModel) -> Void
    
    init(modelContext: ModelContext, selectComicAction: @escaping (ComicModel) -> Void) {
        let model = ComicListViewModel(modelContext: modelContext)
        _viewModel = State(initialValue: model)
        self.selectComicAction = selectComicAction
    }

    var body: some View {
        List {
            ForEach(viewModel.groupedComics.sorted(by: { $0.key > $1.key }), id: \.key) { group in
                Section(header: Text(group.key)) {
                    ForEach(group.value, id: \.num) { comic in
                        ListRowView(num: comic.num,
                                    thumbnail: comic.img,
                                    title: comic.title,
                                    isFavorite: comic.isFavorite,
                                    date: comic.displayDate)
                            .onTapGesture {
                                select(comic: comic)
                            }
                    }
                }
            }
        }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    closeButton
                }
            }
            .navigationTitle(Text("xkcd"))
            .searchable(text: $viewModel.searchText,
                        prompt: "Search")
            .onSubmit(of: .search) {
                doSearch()
            }
            .onChange(of: viewModel.searchText) {
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
    
    func select(comic: ComicModel) {
        selectComicAction(comic)
//        viewModel.setRead(comic: comic)
        presentationMode.wrappedValue.dismiss()
    }
    
    func doSearch() {
        Task {
            do {
                try await viewModel.loadComics()
            } catch {
                print(error)
            }
        }
    }
}

// MARK: - ListView_Previews

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ComicModel.self,
                                           configurations: config)
        return ComicListView(modelContext: container.mainContext,
                             selectComicAction: { comic in } )
    } catch {
        return EmptyView()
    }
}

