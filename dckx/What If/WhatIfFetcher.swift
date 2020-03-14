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
import PromiseKit
import SDWebImage

class WhatIfFetcher: NavigationBarViewNavigator, ObservableObject {
    @Published var currentWhatIf: WhatIf?
    @Published var lastWhatIf: WhatIf?
    
    // MARK: Toolbar actions
    func toggleIsFavorite() {
        guard let currentWhatIf = currentWhatIf else {
            return
        }
        currentWhatIf.isFavorite = !currentWhatIf.isFavorite
        
        let data = ["num": currentWhatIf.num,
                    "isFavorite": currentWhatIf.isFavorite] as [String : Any]
        
        firstly {
            CoreData.sharedInstance.saveWhatIf(data: data)
        }.done { comic in
            self.load(num: currentWhatIf.num)
        }.catch { error in
            print(error)
        }
    }
    
    func toggleIsRead() {
        guard let currentWhatIf = currentWhatIf else {
            return
        }
        
        if !currentWhatIf.isRead {
            let data = ["num": currentWhatIf.num,
                        "isRead": true] as [String : Any]
            firstly {
                CoreData.sharedInstance.saveWhatIf(data: data)
            }.done {
                
            }.catch { error in
                print(error)
            }
        }
    }
    
    // MARK: Navigation actions
    override func loadFirst() {
        load(num: 1)
    }
    
    override func canDoPrevious() -> Bool {
        guard let currentWhatIf = currentWhatIf else {
            return false
        }
        return currentWhatIf.num > 1
    }
    
    override func loadPrevious() {
        guard let currentWhatIf = currentWhatIf else {
            return
        }
        load(num: currentWhatIf.num - 1)
    }
    
    override func loadRandom() {
        firstly {
            XkcdAPI.sharedInstance.fetchRandomWhatIf()
        }.done { whatIf in
            self.currentWhatIf = whatIf
            self.toggleIsRead()
        }.catch { error in
            print(error)
        }
    }
    
    override func loadNext() {
        guard let currentWhatIf = currentWhatIf else {
            return
        }
        load(num: currentWhatIf.num + 1)
    }
    
    override func canDoNext() -> Bool {
        guard let currentWhatIf = currentWhatIf,
            let lastWhatIf = lastWhatIf else {
            return false
        }
        return currentWhatIf.num < lastWhatIf.num
    }
    
    override func loadLast() {
        firstly {
            XkcdAPI.sharedInstance.fetchLastWhatIf()
        }.done { whatIf in
            self.currentWhatIf = whatIf
            self.lastWhatIf = whatIf
            self.toggleIsRead()
        }.catch { error in
            print(error)
        }
    }
    
    // MARK: Helper methods
    func load(num: Int32) {
        firstly {
            XkcdAPI.sharedInstance.fetchWhatIf(num: num)
        }.done { whatIf in
            self.currentWhatIf = whatIf
            self.toggleIsRead()
        }.catch { error in
            print(error)
        }
    }
    
    func fetchThumbnail(whatIf: WhatIf) -> Promise<WhatIf> {
        return Promise { seal in
            guard let urlString = whatIf.thumbnail,
                let url = URL(string: urlString) else {
                fatalError("Malformed URL")
            }

            if let _ = SDImageCache.shared.imageFromCache(forKey: urlString) {
                seal.fulfill(whatIf)
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
                                                                    seal.fulfill(whatIf)
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
        let head =
        """
            <head>
                <link href="xkcd.css" rel="stylesheet">
            </head>
        """

        var html = "<html>\(head)"
        html += "<p class='question'>\(currentWhatIf?.question ?? "")"
        html += "<p class='questioner' align='right'>- \(currentWhatIf?.questioner ?? "")"
        html += "<p/> &nbsp;"
        html += "\(currentWhatIf?.answer ?? "")"
        html += "</html>"
        
        return html
    }
}
