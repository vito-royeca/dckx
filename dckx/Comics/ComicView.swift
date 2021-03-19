//
//  ComicView.swift
//  dckx
//
//  Created by Vito Royeca on 2/13/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI
import Combine
import SDWebImage

struct ComicView: View {
    @ObservedObject var fetcher = ComicFetcher()
    @State private var showingList = false
    
    @State var lastScaleValue: CGFloat = 1.0
    @State var scale: CGFloat = 1.0
    @State var showingAltText = false
    
    
    var body: some View {
        NavigationView {
            if #available(iOS 14.0, *) {
                WebView(link: nil,
                        html: fetcher.composeHTML(showingAltText: showingAltText),
                        baseURL: nil)
                .navigationBarTitle(Text(fetcher.currentComic?.title ?? ""), displayMode: .automatic)
                .navigationBarItems(
                    leading: listButton,
                    trailing:
                        ComicToolBarView(fetcher: fetcher,
                                         showingAltText: $showingAltText)
                )
                .toolbar() {
                    NavigationToolbar(loadFirst: fetcher.loadFirst,
                                      loadPrevious: fetcher.loadPrevious,
                                      loadRandom: fetcher.loadRandom,
                                      loadNext: fetcher.loadNext,
                                      loadLast: fetcher.loadLast,
                                      canDoPrevious: fetcher.canDoPrevious,
                                      canDoNext: fetcher.canDoNext)
                        
                    
                }
            } else {
                Text("Unsupported iOS version")
            }
        }
    }
    
    var listButton: some View {
        Button(action: {
            self.showingList.toggle()
        }) {
            Image(systemName: "list.dash")
                .imageScale(.large)
//                .foregroundColor(.dckxBlue)
        }
        .sheet(isPresented: $showingList, content: {
            ComicListView(fetcher: self.fetcher)
        })
    }
    
    func resetImageScale() {
        lastScaleValue = 1.0
        scale = 1.0
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
    @ObservedObject var fetcher: ComicFetcher
    @Binding var showingAltText: Bool
    @State private var showingBrowser = false
    @State private var showingShare = false
    
    var body: some View {
        HStack {
            Button(action: {
                self.fetcher.toggleIsFavorite()
            }) {
                Image(systemName: fetcher.currentComic?.isFavorite ?? false ? "bookmark.fill" : "bookmark")
                    .imageScale(.large)
//                    .foregroundColor(.dckxBlue)
            }
            Spacer()
            
            Button(action: {
                self.showingAltText.toggle()
            }) {
                Image(systemName: showingAltText ? "doc.text.fill" : "doc.text" )
                    .imageScale(.large)
//                    .foregroundColor(.dckxBlue)
            }
            Spacer()
            
            Button(action: {
                self.showingBrowser.toggle()
            }) {
                Image(systemName: "questionmark.circle")
                    .imageScale(.large)
//                    .foregroundColor(.dckxBlue)
            }
                .sheet(isPresented: $showingBrowser, content: {
                    self.fetcher.currentComic.map({
                        BrowserView(title: $0.title ?? "",
                                    link: XkcdAPI.sharedInstance.explainURL(of: $0),
                                    baseURL: URL(string: "https://xkcd.com/"))
                    })
                })
            Spacer()
            
            Button(action: {
                self.showingShare.toggle()
            }) {
                Image(systemName: "square.and.arrow.up")
                    .imageScale(.large)
//                    .foregroundColor(.dckxBlue)
            }
                .sheet(isPresented: $showingShare) {
                    ShareSheetView(activityItems: self.activityItems(),
                                   applicationActivities: nil)
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
        return "via @dckx - xkcd comics reader"
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
