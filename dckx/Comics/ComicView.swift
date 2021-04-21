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
    @Binding var showingMenu: Bool
    @State private var showingSearch = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                if !fetcher.isBusy {
                    WebView(link: nil,
                            html: fetcher.composeHTML(),
                            baseURL: nil)
                        .gesture(DragGesture(minimumDistance: 30, coordinateSpace: .local)
                            .onEnded({ value in
                                if value.translation.width < 0 {
                                    if fetcher.canDoNext {
                                        fetcher.loadNext()
                                    }
                                }

                                if value.translation.width > 0 {
                                    if fetcher.canDoPrevious {
                                        fetcher.loadPrevious()
                                    }
                                }
                            }))
                } else {
                    ActivityIndicatorView(shouldAnimate: $fetcher.isBusy)
                }
            }
            .navigationBarTitle(Text((fetcher.isBusy ? "" : (fetcher.currentComic?.title ?? "")).uppercased()),
                                displayMode: .large)
                .navigationBarItems( leading: menuButton,
                                     trailing: ComicToolBarView())
                .toolbar() {
                    NavigationToolbar(loadFirst: fetcher.loadFirst,
                                      loadPrevious: fetcher.loadPrevious,
                                      loadRandom: fetcher.loadRandom,
                                      search: {
                                          self.showingSearch.toggle()
                                      },
                                      loadNext: fetcher.loadNext,
                                      loadLast: fetcher.loadLast,
                                      canDoPrevious: fetcher.canDoPrevious,
                                      canDoNext: fetcher.canDoNext,
                                      isBusy: fetcher.isBusy)
                }
                .sheet(isPresented: $showingSearch) {
                    ComicListView()
                }
        }
            .environmentObject(fetcher)
    }
    
    var menuButton: some View {
        Button(action: {
            withAnimation {
                self.showingMenu.toggle()
            }
        }) {
            Image(systemName: "line.horizontal.3")
                .imageScale(.large)
        }
            .disabled(fetcher.isBusy)
    }
}

struct ComicView_Previews: PreviewProvider {
    @State static private var showingMenu = false
    
    static var previews: some View {
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) { deviceName in
            ComicView(showingMenu: $showingMenu)
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
                .disabled(fetcher.isBusy)
            Spacer()
            
            if UserDefaults.standard.bool(forKey: SettingsKey.comicsExplanationUseSafariBrowser) {
                Button(action: {
                    self.showingBrowser.toggle()
                }) {
                    Image(systemName: "questionmark.circle")
                        .imageScale(.large)
                }
                    .disabled(fetcher.isBusy)
                    // comment out if running in XCTests
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
                    .disabled(fetcher.isBusy)
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
                .disabled(fetcher.isBusy)
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
