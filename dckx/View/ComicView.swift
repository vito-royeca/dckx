//
//  ComicView.swift
//  dckx
//
//  Created by Vito Royeca on 2/13/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI

struct ComicView: View {
    @ObservedObject var fetcher = ComicFetcher()
    
    var body: some View {
        NavigationView {
            VStack {
                WebImage(url: URL(string: fetcher.comic?.img ?? ""))
                .onSuccess { image, cacheType in
                    // Success
                }
                .resizable() // Resizable like SwiftUI.Image
//                .placeholder(Image("xkcd-logo")) // Placeholder Image
                // Supports ViewBuilder as well
                .placeholder {
                    Rectangle().foregroundColor(.gray)
                }
                .indicator(.activity) // Activity Indicator
                .animation(.easeInOut(duration: 0.5)) // Animation Duration
                .transition(.fade) // Fade Transition
                .scaledToFit()
//                .frame(width: 300, height: 300, alignment: .center)
                
                HStack {
                    Button(action: {
                        self.fetcher.loadFirstComic()
                    }) {
                        Text("|<")
                    }
                    
                    Button(action: {
                        self.fetcher.loadPreviousComic()
                    }) {
                        Text("<Prev")
                    }
                    
                    Button(action: {
                        self.fetcher.loadRandomComic()
                    }) {
                        Text("Random")
                    }
                    
                    Button(action: {
                        self.fetcher.loadNextComic()
                    }) {
                        Text("Next>")
                    }
                    
                    Button(action: {
                        self.fetcher.loadLastComic()
                    }) {
                        Text(">|")
                    }
                    
                }.padding()
            }
            .navigationBarTitle(fetcher.comic?.title ?? "")
            
        }
    }
}

struct ComicView_Previews: PreviewProvider {
    static var previews: some View {
        ComicView()
    }
}
