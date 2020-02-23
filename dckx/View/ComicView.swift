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
    @State private var showingAltText = false
    @State private var showingBrowser = false
    
    var body: some View {
        NavigationView {
            VStack {
                // title
                HStack {
                    fetcher.currentComic.map({
                        Text("\($0.title ?? "")")
                            .font(.custom("xkcd-Script-Regular", size: 30))
                    })
                }
                .padding(5)
                
                // Comic metadata
                HStack {
                    fetcher.currentComic.map({
                        Text("#\(String($0.num))")
                            .font(.custom("xkcd-Script-Regular", size: 15))
                    })
                    fetcher.currentComic.map({_ in
                        Spacer()
                    })
                    fetcher.currentComic.map({
                        Text("\(String($0.year))-\($0.month < 10 ? "0\($0.month)" : "\($0.month)")-\($0.day < 10 ? "0\($0.day)" : "\($0.day)")")
                            .font(.custom("xkcd-Script-Regular", size: 15))
                    })
                }
                
                Divider()
                
                // Toolbar
                HStack {
                    Button(action: {
                        self.fetcher.toggleIsFavorite()
                    }) {
                        Text("Bookmark \(fetcher.currentComic?.isFavorite ?? true ? "-" : "+")")
                            .customButton(isDisabled: false)
                    }
                    Spacer()
                    
                    Button(action: {
                        self.showingBrowser = true
                    }) {
                        Text("Explain")
                            .customButton(isDisabled: false)
                    }
                        .sheet(isPresented: $showingBrowser, content: {
                            self.fetcher.currentComic.map({
                                BrowserView(title: $0.title ?? "",
                                            link: XkcdAPI.sharedInstance.explainURL(of: $0))
                            })
                        })
                    Spacer()
                    
                    Button(action: {
                        self.showingAltText = true
                    }) {
                        Text("Alt Text")
                            .customButton(isDisabled: false)
                    }
                        .alert(isPresented: $showingAltText) {
                            Alert(title: Text("Alt Text"),
                                  message: Text(fetcher.currentComic?.alt ?? "No Alt Text"),
                                  dismissButton: .default(Text("Close")))
                        }
                    Spacer()
                    
                    Button(action: {
                        
                    }) {
                        Text("Share")
                            .customButton(isDisabled: false)
                    }
                }
                
                Spacer()

                // Image
                WebImage(url: URL(string: fetcher.currentComic?.img ?? ""))
                    .onSuccess { image, cacheType in
                        // Success
                    }
                    .resizable()
                    .placeholder {
                        Rectangle().foregroundColor(.backgroundColor)
                    }
                    .indicator(.activity) // Activity Indicator
                    .animation(.easeInOut(duration: 0.5))
                    .transition(.fade)
                    .scaledToFit()
                
                Spacer()
                
                // Navigation
                HStack {
                    Button(action: {
                        self.fetcher.loadFirstComic()
                    }) {
                        Text("|<")
                            .customButton(isDisabled: !fetcher.canDoPrevious())
                    }
                    .disabled(!fetcher.canDoPrevious())
                    Spacer()
                    
                    Button(action: {
                        self.fetcher.loadPreviousComic()
                    }) {
                        Text("<Prev")
                            .customButton(isDisabled: !fetcher.canDoPrevious())
                    }
                        .disabled(!fetcher.canDoPrevious())
                    Spacer()
                    
                    Button(action: {
                        self.fetcher.loadRandomComic()
                    }) {
                        Text("Random")
                            .customButton(isDisabled: false)
                    }
                    Spacer()
                    
                    Button(action: {
                        self.fetcher.loadNextComic()
                    }) {
                        Text("Next>")
                            .customButton(isDisabled: !fetcher.canDoNext())
                    }
                        .disabled(!fetcher.canDoNext())
                    Spacer()
                    
                    Button(action: {
                        self.fetcher.loadLastComic()
                    }) {
                        Text(">|")
                            .customButton(isDisabled: !fetcher.canDoNext())
                    }
                        .disabled(!fetcher.canDoNext())
                    
                }
            }
                .padding()
                .navigationBarTitle(Text(""), displayMode: .inline)
        }
    }
    
    func explain() {
        
    }
}

struct ComicView_Previews: PreviewProvider {
    static var previews: some View {
        ComicView()
    }
}
