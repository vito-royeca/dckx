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
            let sensitiveData = SensitiveData()
            
            if !sensitiveData.showSensitiveContent && sensitiveData.whatIfContainsSensitiveData(whatIf) {
                let newNum = (num > self.currentWhatIf?.num ?? 0) ? num + 1 : num - 1
                self.load(num: newNum)
            } else {
                self.currentWhatIf = whatIf
                self.toggleIsRead()
            }
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
              let title = whatIf.title,
            let question = whatIf.question,
            let questioner = whatIf.questioner,
            let answer = whatIf.answer else {
            return ""
        }
        let css = UserDefaults.standard.bool(forKey: SettingsKey.whatIfViewerUseSystemFont) ? "system.css" : "dckx.css"
        var head = "<head><title>\(title)</title>"
        head += "<script type='text/javascript' src='jquery-3.2.1.min.js'></script>"
        head += "<link href='\(css)' rel='stylesheet'>"
        head += "<link href='whatif.css' rel='stylesheet'></head>"
        
        var html = "<html>\(head)<body><table width='100%'>"
        html += "<tr><td width='50%' class='numdate'><p align='left'>#\(whatIf.num)</p></td><td width='50%' class='numdate'><p align='right'>\(dateToString(date: whatIf.date))</p></td></tr>"
        html += "<tr><td width='100%' colspan='2' class='question'>\(question)</td></tr>"
        html += "<tr><td width='100%' colspan='2' class='questioner'><p align='right'>- \(questioner)</p></td></tr>"
        html += "<tr><td width='100%' colspan='2'><p/> &nbsp;</td></tr>"
        html += "<tr><td width='100%' colspan='2' class='answer'>\(answer)</td></tr>"
        html += "</table>"
        html += """
            <script>
                jQuery.noConflict();
                jQuery(function() {
                  jQuery(".refbody").hide();
                  jQuery(".refnum").click(function(event) {
                    jQuery(this.nextSibling).toggle();
                    event.stopPropagation();
                  });
                  jQuery("body").click(function(event) {
                    jQuery(".refbody").hide();
                  });
                });
            </script>
            """
        html += "</body></html>"
        
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
            let sensitiveData = SensitiveData()
            
            if !sensitiveData.showSensitiveContent && sensitiveData.whatIfContainsSensitiveData(whatIf) {
                self.loadRandom()
            } else {
                self.currentWhatIf = whatIf
                self.toggleIsRead()
            }
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
            let sensitiveData = SensitiveData()
            
            if !sensitiveData.showSensitiveContent && sensitiveData.whatIfContainsSensitiveData(whatIf) {
                let newNum = whatIf.num - 1
                self.load(num: newNum)
            } else {
                self.currentWhatIf = whatIf
                self.lastWhatIf = whatIf
                self.toggleIsRead()
                print("WhatIfFetcher loadLast")
            }
        }.catch { error in
            print(error)
        }
    }
}
