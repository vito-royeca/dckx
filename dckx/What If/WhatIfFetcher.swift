//
//  WhatIfFetcher.swift
//  dckx
//
//  Created by Vito Royeca on 2/29/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
//import PromiseKit
//import SDWebImage

class WhatIfFetcher: ObservableObject {
    @Published var currentWhatIf: WhatIf?
    @Published var lastWhatIf: WhatIf?
    @Published var isBusy = false
    
    // MARK: - Initializer
    
    init() {
        loadLast()
    }

    // MARK: - Toolbar methods
    
    func toggleIsFavorite() {
        guard let currentWhatIf = currentWhatIf else {
            return
        }
        
        do {
            currentWhatIf.isFavorite = !currentWhatIf.isFavorite
            
//            try CoreData.sharedInstance.dataStack.mainContext.save()
            self.load(num: currentWhatIf.num)
        } catch {
            print(error)
        }
    }
    
    func toggleIsRead() {
        guard let currentWhatIf = currentWhatIf else {
            return
        }
        
        if !currentWhatIf.isRead {
            currentWhatIf.isRead = true
            
            do {
//                try CoreData.sharedInstance.dataStack.mainContext.save()
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: - Helper methods
    
    func load(num: Int32) {
        isBusy = true
        
//        firstly {
//            XkcdAPI.sharedInstance.fetchWhatIf(num: num)
//        }.done { whatIf in
//            let sensitiveData = SensitiveData()
//            
//            if !sensitiveData.showSensitiveContent && sensitiveData.whatIfContainsSensitiveData(whatIf) {
//                let newNum = (num > self.currentWhatIf?.num ?? 0) ? num + 1 : num - 1
//                self.load(num: newNum)
//            } else {
//                self.currentWhatIf = whatIf
//                self.toggleIsRead()
//                self.isBusy = false
//            }
//        }.catch { error in
//            self.isBusy = false
//            print(error)
//        }
    }
    
//    func fetchThumbnail(whatIf: WhatIf) -> Promise<WhatIf> {
//        return Promise { seal in
//            guard let urlString = whatIf.thumbnail,
//                let url = URL(string: urlString) else {
//                fatalError("Malformed URL")
//            }
//
//            if let _ = SDImageCache.shared.imageFromCache(forKey: urlString) {
//                seal.fulfill(whatIf)
//            } else {
//                let callback = { (image: UIImage?, data: Data?, error: Error?, finished: Bool) in
//                    if let error = error {
//                        seal.reject(error)
//                    } else {
//                        SDWebImageManager.shared.imageCache.store(image,
//                                                                  imageData: data,
//                                                                  forKey: urlString,
//                                                                  cacheType: .disk,
//                                                                  completion: {
//                                                                    seal.fulfill(whatIf)
//                        })
//                    }
//                }
//                SDWebImageManager.shared.imageLoader.requestImage(with: url,
//                                                                  options: .highPriority,
//                                                                  context: nil,
//                                                                  progress: nil,
//                                                                  completed: callback)
//            }
//        }
//    }
}

// MARK: - NavigationBarViewNavigator

extension WhatIfFetcher: NavigationToolbarDelegate {
    var canDoPrevious: Bool {
        guard let currentWhatIf = currentWhatIf else {
            return false
        }
        return currentWhatIf.num > 1
    }
    
    var canDoNext: Bool {
        guard let currentWhatIf = currentWhatIf,
            let lastWhatIf = lastWhatIf else {
            return false
        }
        return currentWhatIf.num < lastWhatIf.num
    }
    
    func loadFirst() {
        load(num: 1)
    }
    
    func loadPrevious() {
        guard let currentWhatIf = currentWhatIf else {
            return
        }
        load(num: currentWhatIf.num - 1)
    }
    
    func loadRandom() {
        isBusy = true
        
//        firstly {
//            XkcdAPI.sharedInstance.fetchRandomWhatIf()
//        }.done { whatIf in
//            let sensitiveData = SensitiveData()
//            
//            if !sensitiveData.showSensitiveContent && sensitiveData.whatIfContainsSensitiveData(whatIf) {
//                self.loadRandom()
//            } else {
//                self.currentWhatIf = whatIf
//                self.toggleIsRead()
//                self.isBusy = false
//            }
//        }.catch { error in
//            self.isBusy = false
//            print(error)
//        }
    }
    
    func loadNext() {
        guard let currentWhatIf = currentWhatIf else {
            return
        }
        load(num: currentWhatIf.num + 1)
    }
    
    func loadLast() {
        isBusy = true
        
//        firstly {
//            XkcdAPI.sharedInstance.fetchLastWhatIf()
//        }.done { whatIf in
//            let sensitiveData = SensitiveData()
//            
//            if !sensitiveData.showSensitiveContent && sensitiveData.whatIfContainsSensitiveData(whatIf) {
//                let newNum = whatIf.num - 1
//                self.load(num: newNum)
//            } else {
//                self.currentWhatIf = whatIf
//                self.lastWhatIf = whatIf
//                self.toggleIsRead()
//                self.isBusy = false
//            }
//        }.catch { error in
//            self.isBusy = false
//            print(error)
//        }
    }
}
