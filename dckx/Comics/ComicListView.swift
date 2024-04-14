//
//  ComicListView.swift
//  dckx
//
//  Created by Vito Royeca on 2/21/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI
import Combine

// MARK: - ComicListView

struct  ComicListView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var fetcher: ComicFetcher
    @State var query: String?
    @State var scopeSelection: Int = 0
    
    @State var viewModel: ComicListViewModel = ComicListViewModel(query: nil,
                                                                  scopeIndex: 0)
    @State var shouldAnimate: Bool = false
    
    var body: some View {
        SearchNavigation(query: $query,
                         scopeSelection: $scopeSelection,
                         delegate: self) {
            ZStack(alignment: .center) {
                if viewModel.comics.isEmpty {
                    Text("No results found.")
                        .font(Font.dckxRegularText)
                } else {
                    ComicTextListView(viewModel: $viewModel,
                                      action: selectComic(num:))
                }
                ActivityIndicatorView(shouldAnimate: $shouldAnimate)
            }
                .navigationBarTitle(Text("Comics"), displayMode: .automatic)
                .navigationBarItems(
                    leading: closeButton
                )
        }
            .edgesIgnoringSafeArea(.top)
    }
    
    var closeButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "xmark.circle.fill")
                .imageScale(.large)
        }
    }
    
    func selectComic(num: Int32) {
        fetcher.load(num: num)
        presentationMode.wrappedValue.dismiss()
    }
    
}

// MARK: - ListView_Previews

struct ComicListView_Previews: PreviewProvider {
    static var previews: some View {
        ComicListView().environmentObject(ComicFetcher())
    }
}

// MARK: - SearchNavigation

extension ComicListView: SearchNavigationDelegate {
    var options: [SearchNavigationOptionKey : Any]? {
        return [
            .automaticallyShowsSearchBar: true,
            .obscuresBackgroundDuringPresentation: true,
            .hidesNavigationBarDuringPresentation: true,
            .hidesSearchBarWhenScrolling: false,
            .placeholder: "Search",
            .showsBookmarkButton: false,
            .scopeButtonTitles: ["All", "Bookmarked", "Seen"],
            .scopeBarButtonTitleTextAttributes: [NSAttributedString.Key.font: UIFont.dckxRegularText],
            .searchTextFieldFont: UIFont.dckxRegularText
         ]
    }
    
    func search() {
        DispatchQueue.global(qos: .background).async {
            self.shouldAnimate = true
            self.viewModel = ComicListViewModel(query: self.query,
                                                scopeIndex: self.scopeSelection)
            DispatchQueue.main.async {
                self.shouldAnimate = false
            }
        }
    }
    
    func scope() {
        search()
    }
    
    func cancel() {
        search()
    }
}

// MARK: - ComicTextListView

struct ComicTextListView: View {
    @Binding var viewModel: ComicListViewModel
    var action: (Int32) -> Void
    
    var body: some View {
        VStack {
            List(viewModel.comics) { comic in
                ListRowView(num: comic.num,
                            thumbnail: comic.img ?? "",
                            title: comic.title ?? "",
                            isFavorite: comic.isFavorite,
                            isSeen: comic.isRead,
                            font: Font.dckxRegularText,
                            action: self.action)
                    .onTapGesture {
                        self.action(comic.num)
                    }
                    .onAppear(perform: {
                        if self.viewModel.shouldLoadMore(comic: comic) {
                            self.viewModel.loadData()
                        }
                    })
            }
                .resignKeyboardOnDragGesture()
        }
    }
}


