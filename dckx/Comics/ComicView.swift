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
    @State var lastScaleValue: CGFloat = 1.0
    @State var scale: CGFloat = 1.0
    @State var showingAltText = false
    
    var body: some View {
        VStack {
            // Title
            TitleView(title: fetcher.currentComic?.title ?? "Title")

            // Metadata
            MetaDataView(leftTitle: "\(fetcher.currentComic?.num ?? 1)",
                         rightTitle: fetcher.dateToString(date: fetcher.currentComic?.date))

            // Toolbar
            Divider()
            ComicToolBarView(fetcher: fetcher,
                             showingAltText: $showingAltText)

            Spacer()

            WebView(link: nil,
                    html: fetcher.composeHTML(showingAltText: showingAltText),
                    baseURL: nil)
            
            Spacer()
            
            // Navigation
            ComicNavigationBarView(fetcher: fetcher,
                                   resetAction: resetImageScale)
        }
            .padding()
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
    @State private var showingList = false
    
    var body: some View {
        HStack {
            Button(action: {
                self.fetcher.toggleIsFavorite()
            }) {
                Text("BOOKMARK \(fetcher.currentComic?.isFavorite ?? false ? "-" : "+")")
                    .customButton(isDisabled: false)
            }
            Spacer()
            
            Button(action: {
                self.showingBrowser.toggle()
            }) {
                Text("EXPLAIN")
                    .customButton(isDisabled: false)
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
                self.showingAltText.toggle()
            }) {
                Text("ALT TEXT")
                    .customButton(isDisabled: false)
            }
            Spacer()
            
            Button(action: {
                self.showingShare.toggle()
            }) {
                Text("SHARE")
                    .customButton(isDisabled: false)
            }
                .sheet(isPresented: $showingShare) {
                    ShareSheetView(activityItems: self.activityItems(),
                                   applicationActivities: nil)
                }
            Spacer()
            
            Button(action: {
                self.showingList.toggle()
            }) {
                Text("LIST")
                    .customButton(isDisabled: false)
            }
                .sheet(isPresented: $showingList, content: {
                    ComicListView(fetcher: self.fetcher)
                })
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

struct ComicNavigationBarView: View {
    @ObservedObject var fetcher: ComicFetcher
    var resetAction: () -> Void

    var body: some View {
        HStack {
            Button(action: {
                self.fetcher.loadFirst()
                self.resetAction()
            }) {
                Text("|<")
                    .customButton(isDisabled: !fetcher.canDoPrevious())
            }
            .disabled(!fetcher.canDoPrevious())
            Spacer()
            
            Button(action: {
                self.fetcher.loadPrevious()
                self.resetAction()
            }) {
                Text("<PREV")
                    .customButton(isDisabled: !fetcher.canDoPrevious())
            }
            .disabled(!fetcher.canDoPrevious())
            Spacer()
            
            Button(action: {
                self.fetcher.loadRandom()
                self.resetAction()
            }) {
                Text("RANDOM")
                    .customButton(isDisabled: false)
            }
            Spacer()
            
            Button(action: {
                self.fetcher.loadNext()
                self.resetAction()
            }) {
                Text("NEXT>")
                    .customButton(isDisabled: !fetcher.canDoNext())
            }
            .disabled(!fetcher.canDoNext())
            Spacer()
            
            Button(action: {
                self.fetcher.loadLast()
                self.resetAction()
            }) {
                Text(">|")
                    .customButton(isDisabled: !fetcher.canDoNext())
            }
            .disabled(!fetcher.canDoNext())
        }
    }
}
