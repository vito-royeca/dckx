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
    @State var searchString = ""
    
    let dataArray = ["John", "Paul", "George", "Ringo"]
    
    // Search action. Called when search key pressed on keyboard
    func search() {
    }
    
    // Cancel action. Called when cancel button of search bar pressed
    func cancel() {
    }
    
    var body: some View {
        // Search Navigation. Can be used like a normal SwiftUI NavigationView.
//        NavigationView {
            SearchNavigation(text: $searchString, search: search, cancel: cancel) {
                // Example SwiftUI View
                List {
                    ForEach(dataArray.filter{$0.hasPrefix(searchString) || searchString == ""}, id:\.self) { data in
                        Text(data)
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
