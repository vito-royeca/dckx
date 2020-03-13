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

class ComicFetcher: NavigationBarViewNavigator, ObservableObject {
    @Published var currentComic: Comic?
    @Published var lastComic: Comic?
    
    // MARK: Toolbar actions
    func toggleIsFavorite() {
        guard let currentComic = currentComic else {
            return
        }
        currentComic.isFavorite = !currentComic.isFavorite
        
        let data = ["num": currentComic.num,
                    "isFavorite": currentComic.isFavorite] as [String : Any]
        
        firstly {
            CoreData.sharedInstance.saveComic(data: data)
        }.done { comic in
            self.load(num: currentComic.num)
        }.catch { error in
            print(error)
        }
    }
    
    func toggleIsRead() {
        guard let currentComic = currentComic else {
            return
        }
        
        if !currentComic.isRead {
            let data = ["num": currentComic.num,
                        "isRead": true] as [String : Any]
            firstly {
                CoreData.sharedInstance.saveComic(data: data)
            }.done {
                
            }.catch { error in
                print(error)
            }
        }
    }
    
    // MARK: NavigationBarViewDelegate
    override func loadFirst() {
        load(num: 1)
    }
    
    override func canDoPrevious() -> Bool {
        guard let currentComic = currentComic else {
            return false
        }
        return currentComic.num > 1
    }
    
    override func loadPrevious() {
        guard let currentComic = currentComic else {
            return
        }
        load(num: currentComic.num - 1)
    }
    
    override func loadRandom() {
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
    
    override func loadNext() {
        guard let currentComic = currentComic else {
            return
        }
        load(num: currentComic.num + 1)
    }
    
    override func canDoNext() -> Bool {
        guard let currentComic = currentComic,
            let lastComic = lastComic else {
            return false
        }
        return currentComic.num < lastComic.num
    }
    
    override func loadLast() {
        firstly {
            XkcdAPI.sharedInstance.fetchLastComic()
        }.then { comic in
            self.fetchImage(comic: comic)
        }.done { comic in
            self.currentComic = comic
            self.lastComic = comic
            self.toggleIsRead()
        }.catch { error in
            print(error)
        }
    }
    
    // MARK: Helper methods
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
        let head =
        """
            <head>
                <link href='xkcd.css' rel='stylesheet'>
            </head>
        """
        guard let comic = currentComic,
            let img = comic.img,
            let title = comic.title,
            let image = SDImageCache.shared.imageFromCache(forKey: img),
            let data = image.pngData() else {
            return ""
        }
        let style = image.size.width > image.size.height ? "width:100%; height:auto;" :
            "width:auto; height:100%;"
        
        var html = "<html>\(head)<body>"
        html += "<table id='wrapper'>"
        html += "<tr><td><p class='altText'>\(showingAltText ? comic.alt ?? "&nbsp;" : "&nbsp;")</p></td></tr>"
        html += "<tr><td><img src='data:image/png;base64, \(data.base64EncodedString())' alt='\(title)' style='\(style)'/></td></tr>"
        html += "<tr><td>&nbsp;</td></tr>"
        html += "</table>"
        html += "</body></html>"
        
        return html
    }
    
    func dateToString(date: Date?) -> String {
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
        
            return formatter.string(from: date)
        } else {
            return "2020-01-02"
        }
    }
}

