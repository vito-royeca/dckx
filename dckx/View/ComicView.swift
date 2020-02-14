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
    @State private var showingText = false
    
    var body: some View {
        NavigationView {
            VStack {
                WebImage(url: URL(string: fetcher.currentComic?.img ?? ""))
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
                    }.disabled(!fetcher.canDoPrevious())
                    
                    Button(action: {
                        self.fetcher.loadPreviousComic()
                    }) {
                        Text("<Prev")
                    }.disabled(!fetcher.canDoPrevious())
                    
                    Button(action: {
                        self.fetcher.loadRandomComic()
                    }) {
                        Text("Random")
                    }
                    
                    Button(action: {
                        self.fetcher.loadNextComic()
                    }) {
                        Text("Next>")
                    }.disabled(!fetcher.canDoNext())
                    
                    Button(action: {
                        self.fetcher.loadLastComic()
                    }) {
                        Text(">|")
                    }.disabled(!fetcher.canDoNext())
                    
                }
            }.padding()
            .navigationBarTitle(fetcher.currentComic?.title ?? "")
            .navigationBarItems(trailing:
                Button(action: {
                    self.showingText = true
                }) {
                    Text("Alt Text")
                }
                .alert(isPresented: $showingText) {
                    Alert(title: Text("Alt Text"),
                          message: Text(fetcher.currentComic?.alt ?? "No Alt Text"),
                          dismissButton: .default(Text("Close")))
                }
            )
            
        }
    }
}

struct ComicView_Previews: PreviewProvider {
    static var previews: some View {
        ComicView()
    }
}
