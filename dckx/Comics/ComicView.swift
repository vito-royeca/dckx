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
    @State var lastScaleValue: CGFloat = 1.0
    @State var scale: CGFloat = 1.0
    @State var showingAltText = false
    
    var body: some View {
        VStack {
            // Title
            ComicTitleView(title: fetcher.currentComic?.title ?? "Title")

            // Metadata
            ComicMetaDataView(num: fetcher.currentComic?.num ?? 1,
                              date: fetcher.currentComic?.date)

            // Toolbar
            Divider()
            ComicToolBarView(fetcher: fetcher,
                             showingAltText: $showingAltText)

            Spacer()

            // Image
//            ComicImageView(url: fetcher.currentComic?.img ?? "",
//                           lastScaleValue: $lastScaleValue,
//                           scale: $scale)
            WebView(link: nil,
                    html: composeHTML(),
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
    
    func composeHTML() -> String {
        let head =
        """
            <head>
                <link href="xkcd.css" rel="stylesheet">
            </head>
        """
        guard let comic = fetcher.currentComic,
            let img = comic.img,
            let imageUrl = SDImageCache.shared.cachePath(forKey: img) else {
            return ""
        }
        
        var html = "<html>\(head)<body>"
        html += "<table id='wrapper'>"
        html += "<tr><td>"
        if showingAltText {
            html += "<p class='altText'>\(comic.alt ?? "&nbsp;")</p>"
        }
        html += "<img src='\(imageUrl)' />"
        html += "</td></tr>"
        html += "</table>"
        html += "</body></html>"
        
        return html
    }
    
    func image() -> UIImage {
        if let comic = fetcher.currentComic,
            let img = comic.img,
            let image = SDImageCache.shared.imageFromCache(forKey: img) {
            return image
        }
        
        return UIImage(named: "logo")!
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

struct ComicTitleView: View {
    var title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.custom("xkcd-Script-Regular", size: 30))
        }
            .padding(5)
    }
}

struct ComicMetaDataView: View {
    var num: Int32
    var date: Date?
    
    var body: some View {
        HStack {
            Text("#\(String(num))")
                .font(.custom("xkcd-Script-Regular", size: 15))
            Spacer()
            Text(dateString())
                .font(.custom("xkcd-Script-Regular", size: 15))
        }
    }
    
    func dateString() -> String {
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
        
            return formatter.string(from: date)
        } else {
            return "2020-01-02"
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
                Text("Bookmark \(fetcher.currentComic?.isFavorite ?? false ? "-" : "+")")
                    .customButton(isDisabled: false)
            }
            Spacer()
            
            Button(action: {
                self.showingBrowser.toggle()
            }) {
                Text("Explain")
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
                Text("Alt Text")
                    .customButton(isDisabled: false)
            }
            Spacer()
            
            Button(action: {
                self.showingShare.toggle()
            }) {
                Text("Share")
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
                Text("List")
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

struct ComicImageView: View {
    var url: String
    @Binding var lastScaleValue: CGFloat
    @Binding var scale: CGFloat
    
    var body: some View {
        VStack {
            zoomView()
        }
    }
    
    func zoomView() -> some View {
        return contentView()
            .scaleEffect(self.scale)
            .gesture(MagnificationGesture(minimumScaleDelta: 0.1)
                .onChanged { value in
                    let delta = value / self.lastScaleValue
                    self.lastScaleValue = value
                    let newScale = self.scale * delta
                    self.scale = min(max(newScale, 0.5), 2)
                }.onEnded { value in
                    self.lastScaleValue = 1.0
                })
    }
    
    func contentView() -> some View {
        HStack {
            WebImage(url: URL(string: url), options: [.progressiveLoad])
                .resizable()
                .indicator(.progress)
                .scaledToFit()
        }
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
                Text("<Prev")
                    .customButton(isDisabled: !fetcher.canDoPrevious())
            }
            .disabled(!fetcher.canDoPrevious())
            Spacer()
            
            Button(action: {
                self.fetcher.loadRandom()
                self.resetAction()
            }) {
                Text("Random")
                    .customButton(isDisabled: false)
            }
            Spacer()
            
            Button(action: {
                self.fetcher.loadNext()
                self.resetAction()
            }) {
                Text("Next>")
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
