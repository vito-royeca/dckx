//
//  ComicFetcher.swift
//  dckx
//
//  Created by Vito Royeca on 2/14/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import PromiseKit
import SDWebImage

class ComicFetcher: ObservableObject {
    @Published var currentComic: Comic?
    @Published var lastComic: Comic?
    
    // MARK: - Initializer
    
    init() {
        loadLast()
    }
    
    // MARK: - Toolbar methods
    
    func toggleIsFavorite() {
        guard let currentComic = currentComic else {
            return
        }
        
        do {
            currentComic.isFavorite = !currentComic.isFavorite
            
            try CoreData.sharedInstance.dataStack.mainContext.save()
            self.load(num: currentComic.num)
        } catch {
            print(error)
        }
    }
    
    func toggleIsRead() {
        guard let currentComic = currentComic else {
            return
        }

        if !currentComic.isRead {
            currentComic.isRead = true
            
            do {
                try CoreData.sharedInstance.dataStack.mainContext.save()
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: - Helper methods
    
    func load(num: Int32) {
        firstly {
            XkcdAPI.sharedInstance.fetchComic(num: num)
        }.then { comic in
            self.fetchImage(comic: comic)
        }.done { comic in
            self.currentComic = comic
            self.toggleIsRead()
        }.catch { error in
            print(error)
        }
    }
    
    func fetchImage(comic: Comic) -> Promise<Comic> {
        return Promise { seal in
            guard let urlString = comic.img,
                let url = URL(string: urlString) else {
                fatalError("Malformed URL")
            }
            
            if let _ = SDImageCache.shared.imageFromCache(forKey: urlString) {
                seal.fulfill(comic)
            } else {
                let callback = { (image: UIImage?, data: Data?, error: Error?, finished: Bool) in
                    if let error = error {
                        seal.reject(error)
                    } else {
                        SDWebImageManager.shared.imageCache.store(image,
                                                                  imageData: data,
                                                                  forKey: urlString,
                                                                  cacheType: .disk,
                                                                  completion: {
                                                                    seal.fulfill(comic)
                        })
                    }
                }
                SDWebImageManager.shared.imageLoader.requestImage(with: url,
                                                                  options: .highPriority,
                                                                  context: nil,
                                                                  progress: nil,
                                                                  completed: callback)
            }
        }
    }
    
    func composeHTML(showingAltText: Bool) -> String {
        guard let comic = currentComic,
            let img = comic.img,
            let title = comic.title,
            let image = SDImageCache.shared.imageFromCache(forKey: img),
            let data = image.pngData() else {
            return ""
        }
        let head = "<head><link href=\"xkcd.css\" rel=\"stylesheet\"></head>"
        let style = image.size.width > image.size.height ? "width:100%; height:auto;" :
            "width:auto; height:100%;"
        
        var html = "<html>\(head)<body>"
        html += "<table id='wrapper' width='100%'>"
        html += "<tr><td width='50%'><p class='subtitle' align='left'>#\(comic.num)</p></td><td width='50%'><p class='subtitle' align='right'>\(dateToString(date: comic.date))</p></td></tr>"
        if showingAltText {
            html += "<tr><td colspan='2'><p class='altText'>\(comic.alt ?? "&nbsp;")</p></td></tr>"
        }
        html += "<tr><td colspan='2'><img src='data:image/png;base64, \(data.base64EncodedString())' alt='\(title)' style='\(style)'/></td></tr>"
        html += "<tr><td>&nbsp;</td></tr>"
        html += "</table>"
        html += "</body></html>"
        
        return html
    }
}

// MARK: - NavigationBarViewDelegate

extension ComicFetcher: NavigationToolbarDelegate {
    var canDoPrevious: Bool {
        guard let currentComic = currentComic else {
            return false
        }
        return currentComic.num > 1
    }
    
    var canDoNext: Bool {
        guard let currentComic = currentComic,
            let lastComic = lastComic else {
            return false
        }
        return currentComic.num < lastComic.num
    }
    
    func loadFirst() {
        load(num: 1)
    }
    
    func loadPrevious() {
        guard let currentComic = currentComic else {
            return
        }
        load(num: currentComic.num - 1)
    }
    
    func loadRandom() {
        firstly {
            XkcdAPI.sharedInstance.fetchRandomComic()
        }.then { comic in
            self.fetchImage(comic: comic)
        }.done { comic in
            self.currentComic = comic
            self.toggleIsRead()
        }.catch { error in
            print(error)
        }
    }
    
    func loadNext() {
        guard let currentComic = currentComic else {
            return
        }
        load(num: currentComic.num + 1)
    }
    
    func loadLast() {
        firstly {
            XkcdAPI.sharedInstance.fetchLastComic()
        }.then { comic in
            self.fetchImage(comic: comic)
        }.done { comic in
            self.currentComic = comic
            self.lastComic = comic
            self.toggleIsRead()
            print("ComicFetcher loadLast")
        }.catch { error in
            print(error)
        }
    }
}
