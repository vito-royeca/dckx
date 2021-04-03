//
//  SearchNavigationTestView.swift
//  dckx
//
//  Created by Vito Royeca on 4/1/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

import SwiftUI

struct SearchNavigationTestView: View {
    // Search string to use in the search bar
    @State var searchString: String?
    @State var scopeSelection = 0
    
    let dataArray = ["John", "Paul", "George", "Ringo"]
    
    var body: some View {
//        NavigationView {
            SearchNavigation(query: $searchString,
                             scopeSelection: $scopeSelection,
                             delegate: self) {
                List {
                    ForEach(dataArray, id:\.self) { data in
                        NavigationLink(data, destination: SomeView(text: data, title: data, uiTabarController: nil))
                    }
                }
                .navigationBarTitle("Usage Example")
            }
            .edgesIgnoringSafeArea(.top)
//        }
        
    }
}

struct SearchNavigationTestView_Previews: PreviewProvider {
    static var previews: some View {
        SearchNavigationTestView()
    }
}

extension SearchNavigationTestView: SearchNavigationDelegate {
    var options: [NavigationSearchBarOptionKey : Any]? {
        return [
            .automaticallyShowsSearchBar: true,
            .obscuresBackgroundDuringPresentation: true,
            .hidesNavigationBarDuringPresentation: true,
            .hidesSearchBarWhenScrolling: false,
            .placeholder: "Search",
            .showsBookmarkButton: false,
            .scopeButtonTitles: ["All", "Bookmarked", "Read"],
            .scopeBarButtonTitleTextAttributes: [NSAttributedString.Key.font: UIFont(name: "xkcd Script", size: 15)],
            .searchTextFieldFont: UIFont(name: "xkcd Script", size: 15)!
            
         ]
    }
    
    func search() {
        
    }
    
    func scope() {
        
    }
    
    func cancel() {
        
    }
}
