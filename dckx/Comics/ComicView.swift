//
//  ComicView.swift
//  dckx
//
//  Created by Vito Royeca on 2/13/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI
import Combine
import BetterSafariView
import SDWebImage

struct ComicView: View {
    @StateObject var fetcher = ComicFetcher()
    @State private var showingList = false
    
    var body: some View {
        NavigationView {
            WebView(link: nil,
                    html: fetcher.composeHTML(),
                    baseURL: nil)
                .navigationBarTitle(Text((fetcher.currentComic?.title ?? "").uppercased()), displayMode: .automatic)
                .navigationBarItems(
                    leading: listButton,
                    trailing: ComicToolBarView())
                .toolbar() {
                    NavigationToolbar(loadFirst: fetcher.loadFirst,
                                      loadPrevious: fetcher.loadPrevious,
                                      loadRandom: fetcher.loadRandom,
                                      loadNext: fetcher.loadNext,
                                      loadLast: fetcher.loadLast,
                                      canDoPrevious: fetcher.canDoPrevious,
                                      canDoNext: fetcher.canDoNext)
                }
        }
            .environmentObject(fetcher)
    }
    
    var listButton: some View {
        Button(action: {
            self.showingList.toggle()
        }) {
            Image(systemName: "list.dash")
                .imageScale(.large)
        }
            .fullScreenCover(isPresented: $showingList, content: {
                ComicListView()
            })
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

struct ComicToolBarView: View {
    @EnvironmentObject var fetcher: ComicFetcher
    @State private var showingBrowser = false
    @State private var showingShare = false
    
    var body: some View {
        HStack {
            Button(action: {
                self.fetcher.toggleIsFavorite()
            }) {
                Image(systemName: fetcher.currentComic?.isFavorite ?? false ? "bookmark.fill" : "bookmark")
                    .imageScale(.large)
            }
            Spacer()
            
            if UserDefaults.standard.bool(forKey: "comicsExplanationUseSafariBrowser") {
                Button(action: {
                    self.showingBrowser.toggle()
                }) {
                    Image(systemName: "questionmark.circle")
                        .imageScale(.large)
                }
                    .safariView(isPresented: $showingBrowser) {
                        SafariView(
                            url: URL(string: XkcdAPI.sharedInstance.explainURL(of: self.fetcher.currentComic!))!,
                            configuration: SafariView.Configuration(
                                entersReaderIfAvailable: true,
                                barCollapsingEnabled: true
                            )
                        )
                        .preferredBarAccentColor(.clear)
                        .preferredControlAccentColor(.dckxBlue)
                        .dismissButtonStyle(.close)
                    }
            } else {
                Button(action: {
                    self.showingBrowser.toggle()
                }) {
                    Image(systemName: "questionmark.circle")
                        .imageScale(.large)
                }
                    .sheet(isPresented: $showingBrowser, content: {
                        self.fetcher.currentComic.map({
                            BrowserView(title: "Explanation",
                                        link: XkcdAPI.sharedInstance.explainURL(of: $0),
                                        baseURL: nil/*URL(string: "https://xkcd.com/")*/)
                        })
                    })
            }
            Spacer()
            
            Button(action: {
                self.showingShare.toggle()
            }) {
                Image(systemName: "square.and.arrow.up")
                    .imageScale(.large)
            }
                .sheet(isPresented: $showingShare) {
                    ShareSheetView(activityItems: self.activityItems(),
                                   applicationActivities: [])
                }
        }
    }
    
    func activityItems() -> [Any] {
        let item = ComicItemSource(comic: fetcher.currentComic)
        
        return [item, "\(item.title())\n\(item.author())"]
    }
}

class ComicItemSource: NSObject,  UIActivityItemSource {
    var comic: Comic?
    
    init(comic: Comic?) {
        self.comic = comic
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return "\(title())\n\(author())"
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return image()
    }

    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return title()
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: UIActivity.ActivityType?, suggestedSize size: CGSize) -> UIImage? {
        return image()
    }
    
    func title() -> String {
        if let comic = comic {
            return "#\(comic.num): \(comic.title ?? "")"
        } else {
            return author()
        }
    }
    
    func author() -> String {
        return "via @dckx - an xkcd comics reader app"
    }
    
    func image() -> UIImage? {
        if let comic = comic,
            let img = comic.img,
            let image = SDImageCache.shared.imageFromCache(forKey: img) {
            return image
        }
        
        return nil
    }
}
