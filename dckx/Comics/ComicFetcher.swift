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
