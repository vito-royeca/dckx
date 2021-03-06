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
    @Published var isBusy = false
    
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
        isBusy = true
        
        firstly {
            XkcdAPI.sharedInstance.fetchComic(num: num)
        }.then { comic in
            self.fetchImage(comic: comic)
        }.done { comic in
            let sensitiveData = SensitiveData()
            
            if !sensitiveData.showSensitiveContent && sensitiveData.comicContainsSensitiveData(comic) {
                let newNum = (num > self.currentComic?.num ?? 0) ? num + 1 : num - 1
                self.load(num: newNum)
            } else {
                self.currentComic = comic
                self.toggleIsRead()
                self.isBusy = false
            }
        }.catch { error in
            self.isBusy = false
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
    
    func composeHTML() -> String {
        guard let comic = currentComic,
            let img = comic.img,
            let title = comic.title,
            let cachePath = SDImageCache.shared.cachePath(forKey: img),
            let image = SDImageCache.shared.imageFromCache(forKey: img),
            let data = image.pngData()/*,
            // comment out if running in XCTests
            let splitComics = OpenCVWrapper.splitComics(cachePath, minimumPanelSizeRatio: 1/15)*/ else {
            return ""
        }
        
        var comicsJson = "[{"
        // comment out if running in XCTests
//        for (k,v) in splitComics {
//            comicsJson.append("\"\(k)\": ")
//            if let _ = v as? String {
//                comicsJson.append("\"\(v)\",")
//            } else {
//                comicsJson.append("\(v),")
//            }
//        }
        comicsJson = comicsJson.hasSuffix(",") ? String(comicsJson.dropLast()) : comicsJson
        comicsJson += "}]"
        comicsJson = comicsJson.replacingOccurrences(of: "(", with: "[")
        comicsJson = comicsJson.replacingOccurrences(of: ")", with: "]")
        comicsJson = comicsJson.replacingOccurrences(of: "\n", with: "")

        let css = UserDefaults.standard.bool(forKey: SettingsKey.comicsViewerUseSystemFont) ? "system.css" : "dckx.css"
        var head = "<head><title>\(title)</title>"
        head += "<meta charset='utf-8'>"
        head += "<meta name='viewport' content='width=device-width, initial-scale=1'>"
        head += "<script type='text/javascript' src='jquery-3.2.1.min.js'></script>"
        head += "<script type='text/javascript' src='reader.js'></script>"
        head += "<link rel='stylesheet' media='all' href='\(css)' />"
        head += "<style type='text/css'> "
        head += " .sidebyside { display: flex; justify-content: space-around; }"
        head += " .sidebyside > div { width: 45%; }"
        head += " .version { text-align: center; }"
        head += " .kumiko-reader { height: 90vh; }"
        head += " .kumiko-reader.fullpage { height: 100%; width: 100%; }"
        head += "</style></head>"

        let altText = "\(comic.alt ?? "")".replacingOccurrences(of: "'", with: "\\x27").replacingOccurrences(of: "\"", with: "\\x22")
        var reader = "<div id='reader' class='kumiko-reader fullpage'></div>"
        reader += "<script type='text/javascript'>"
        reader += " var reader = new Reader({"
        reader += "  container: $('#reader'),"
        reader += "  comicsJson: \(comicsJson),"
        reader += "  imageSrc: 'data:image/png;base64, \(data.base64EncodedString())',"
        reader += "  controls: true,"
        reader += "  num: '#\(comic.num)',"
        reader += "  date: '\(dateToString(date: comic.date))&nbsp;',"
        reader += "  altText: '\(altText)'"
        reader += " });"
        reader += " reader.start();"
        reader += "</script>"

        var html = "<!DOCTYPE html><html>\(head)<body>"

        html += "\(reader)"
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
        isBusy = true
        
        firstly {
            XkcdAPI.sharedInstance.fetchRandomComic()
        }.then { comic in
            self.fetchImage(comic: comic)
        }.done { comic in
            let sensitiveData = SensitiveData()
            
            if !sensitiveData.showSensitiveContent && sensitiveData.comicContainsSensitiveData(comic) {
                self.loadRandom()
            } else {
                self.currentComic = comic
                self.toggleIsRead()
                self.isBusy = false
            }
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
        isBusy = true
        
        firstly {
            XkcdAPI.sharedInstance.fetchLastComic()
        }.then { comic in
            self.fetchImage(comic: comic)
        }.done { comic in
            let sensitiveData = SensitiveData()
            
            if !sensitiveData.showSensitiveContent && sensitiveData.comicContainsSensitiveData(comic) {
                let newNum = comic.num - 1
                self.load(num: newNum)
            } else {
                self.currentComic = comic
                self.lastComic = comic
                self.toggleIsRead()
                self.isBusy = false
            }
        }.catch { error in
            print(error)
            self.isBusy = false
        }
    }
}
