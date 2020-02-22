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
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    fetcher.currentComic.map({
                        Text("\($0.title ?? "")")
                            .font(.custom("xkcd-Script-Regular", size: 30))
                    })
                }
                .padding()
                
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
                HStack {
                    Button(action: {
                        self.fetcher.toggleIsFavorite()
                    }) {
                        Text("Bookmark \(fetcher.currentComic?.isFavorite ?? true ? "-" : "+")")
                            .font(.custom("xkcd-Script-Regular", size: 20))
                    }
                    Spacer()
                    
                    Button(action: {
                        
                    }) {
                        Text("Explain")
                            .font(.custom("xkcd-Script-Regular", size: 20))
                    }
                    Spacer()
                    
                    Button(action: {
                        self.showingAltText = true
                    }) {
                        Text("Alt Text")
                            .font(.custom("xkcd-Script-Regular", size: 20))
                    }
                    .alert(isPresented: $showingAltText) {
                        Alert(title: Text("Alt Text"),
                              message: Text(fetcher.currentComic?.alt ?? "No Alt Text"),
                              dismissButton: .default(Text("Close")))
                    }
                }
                
                Spacer()

                WebImage(url: URL(string: fetcher.currentComic?.img ?? ""))
                    .onSuccess { image, cacheType in
                        // Success
                    }
                    .resizable()
                    .placeholder {
                        Rectangle().foregroundColor(.gray)
                    }
                    .indicator(.activity) // Activity Indicator
                    .animation(.easeInOut(duration: 0.5))
                    .transition(.fade)
                    .scaledToFit()
//                  .frame(width: 300, height: 300, alignment: .center)
                
                Spacer()
                
                HStack {
                    Button(action: {
                        self.fetcher.loadFirstComic()
                    }) {
                        Text("|<")
                            .font(.custom("xkcd-Script-Regular", size: 20))
                    }
                    //.background(.buttonColor)
                    .disabled(!fetcher.canDoPrevious())
                    Spacer()
                    
                    Button(action: {
                        self.fetcher.loadPreviousComic()
                    }) {
                        Text("<Prev")
                            .font(.custom("xkcd-Script-Regular", size: 20))
                    }
                        .disabled(!fetcher.canDoPrevious())
                    Spacer()
                    
                    Button(action: {
                        self.fetcher.loadRandomComic()
                    }) {
                        Text("Random")
                            .font(.custom("xkcd-Script-Regular", size: 20))
                    }
                    Spacer()
                    
                    Button(action: {
                        self.fetcher.loadNextComic()
                    }) {
                        Text("Next>")
                            .font(.custom("xkcd-Script-Regular", size: 20))
                    }
                        .disabled(!fetcher.canDoNext())
                    Spacer()
                    
                    Button(action: {
                        self.fetcher.loadLastComic()
                    }) {
                        Text(">|")
                            .font(.custom("xkcd-Script-Regular", size: 20))
                    }
                        .disabled(!fetcher.canDoNext())
                    
                }
            }
                .padding()
            /*.navigationBarTitle(fetcher.currentComic?.title ?? "")
            .navigationBarItems(trailing:
                Button(action: {
                    self.showingAltText = true
                }) {
                    Text("Alt Text")
                }
                .alert(isPresented: $showingText) {
                    Alert(title: Text("Alt Text"),
                          message: Text(fetcher.currentComic?.alt ?? "No Alt Text"),
                          dismissButton: .default(Text("Close")))
                }
            )*/
            
        }
    }
}

struct ComicView_Previews: PreviewProvider {
    static var previews: some View {
        ComicView()
    }
}
