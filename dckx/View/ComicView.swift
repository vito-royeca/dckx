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
                // Title
                TitleView(title: fetcher.currentComic?.title ?? "Title")
                
                // Metadata
                MetaDataView(num: fetcher.currentComic?.num ?? 1,
                             year: fetcher.currentComic?.year ?? 2020,
                             month: fetcher.currentComic?.month ?? 1,
                             day: fetcher.currentComic?.day ?? 1)
                
                Divider()
                
                // Tool bar
                ToolBarView(fetcher: fetcher)
                
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
                    .aspectRatio(contentMode: .fit)
                
                Spacer()
                
                // Navigation
                NavigationBarView(fetcher: fetcher)
            }
                .padding()
                .navigationBarTitle(Text("dxcd: xkcd"), displayMode: .inline)
//                .navigationBarItems(leading: LeadingBarItemsView(fetcher: fetcher))
        }
    }
}

struct ComicView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) { deviceName in
            ComicView()
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
    }
}

//struct LeadingBarItemsView: View {
//    @State private var showingList = false
//    var fetcher: ComicFetcher
//
//    var body: some View {
//        Button(action: {
//            self.showingList = true
//        }) {
//            Text("List")
//                .customButton(isDisabled: false)
//        }
//            .sheet(isPresented: $showingList, content: {
//                ListView(fetcher: self.fetcher).environment(\.managedObjectContext, CoreData.sharedInstance.dataStack.viewContext)
//            })
//    }
//}

struct TitleView: View {
    var title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.custom("xkcd-Script-Regular", size: 30))
        }
            .padding(5)
    }
}

struct MetaDataView: View {
    var num: Int32
    var year: Int16
    var month: Int16
    var day: Int16
    
    var body: some View {
        HStack {
            Text("#\(String(num))")
                .font(.custom("xkcd-Script-Regular", size: 15))
            Spacer()
            Text("\(String(year))-\(month < 10 ? "0\(month)" : "\(month)")-\(day < 10 ? "0\(day)" : "\(day)")")
                .font(.custom("xkcd-Script-Regular", size: 15))
        }
    }
}

struct ToolBarView: View {
    @ObservedObject var fetcher: ComicFetcher
    @State private var showingAltText = false
    @State private var showingBrowser = false
    @State private var showingList = false
    
    var body: some View {
        HStack {
            Button(action: {
                self.fetcher.toggleIsFavorite()
            }) {
                Text("Bookmark \(fetcher.currentComic?.isFavorite ?? false ? "-" : "+")")
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
            Spacer()
            
            Button(action: {
                self.showingList = true
            }) {
                Text("List")
                    .customButton(isDisabled: false)
            }
                .sheet(isPresented: $showingList, content: {
                    ListView(fetcher: self.fetcher).environment(\.managedObjectContext, CoreData.sharedInstance.dataStack.viewContext)
                })
        }
    }
}

struct NavigationBarView: View {
    @ObservedObject var fetcher: ComicFetcher
    
    var body: some View {
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
}
