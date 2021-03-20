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

class WhatIfFetcher: ObservableObject {
    @Published var currentWhatIf: WhatIf?
    @Published var lastWhatIf: WhatIf?
    
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
            
            try CoreData.sharedInstance.dataStack.mainContext.save()
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
                try CoreData.sharedInstance.dataStack.mainContext.save()
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: - Helper methods
    
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
        guard let whatIf = currentWhatIf,
            let question = whatIf.question,
            let questioner = whatIf.questioner,
            let answer = whatIf.answer else {
            return ""
        }
        let head =
        """
            <head>
                <link href="xkcd.css" rel="stylesheet">
            </head>
        """

        var html = "<html>\(head)"
        html += "<table width='100%'><tr><td width='50%'><p class='subtitle' align='left'>#\(whatIf.num)</p></td><td width='50%'><p class='subtitle' align='right'>\(dateToString(date: whatIf.date))</p></td></tr></table>"
        html += "<p class='question'>\(question)"
        html += "<p class='questioner' align='right'>- \(questioner)"
        html += "<p/> &nbsp;"
        html += "\(answer)"
        html += "</html>"
        
        return html
    }
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
        firstly {
            XkcdAPI.sharedInstance.fetchRandomWhatIf()
        }.done { whatIf in
            self.currentWhatIf = whatIf
            self.toggleIsRead()
        }.catch { error in
            print(error)
        }
    }
    
    func loadNext() {
        guard let currentWhatIf = currentWhatIf else {
            return
        }
        load(num: currentWhatIf.num + 1)
    }
    
    func loadLast() {
        firstly {
            XkcdAPI.sharedInstance.fetchLastWhatIf()
        }.done { whatIf in
            self.currentWhatIf = whatIf
            self.lastWhatIf = whatIf
            self.toggleIsRead()
            print("WhatIfFetcher loadLast")
        }.catch { error in
            print(error)
        }
    }
}
