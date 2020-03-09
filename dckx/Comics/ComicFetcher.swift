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

class ComicFetcher: ObservableObject {
    @Published var currentComic: Comic?
    @Published var lastComic: Comic?
    
    // MARK: Initializer
    init() {
        loadLast()
    }

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
    
    private func toggleIsRead() {
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
    
    // MARK: Navigation actions
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
        }.done { comic in
            self.currentComic = comic
            self.lastComic = comic
            self.toggleIsRead()
        }.catch { error in
            print(error)
        }
    }
    
    // MARK: Button states
    func canDoPrevious() -> Bool {
        guard let currentComic = currentComic else {
            return false
        }
        return currentComic.num > 1
    }
    
    func canDoNext() -> Bool {
        guard let currentComic = currentComic,
            let lastComic = lastComic else {
            return false
        }
        return currentComic.num < lastComic.num
    }
    
    // MARK: Helper methods
    func load(num: Int32) {
        firstly {
            XkcdAPI.sharedInstance.fetchComic(num: num)
        }.done { comic in
            self.currentComic = comic
            self.toggleIsRead()
        }.catch { error in
            print(error)
        }
    }
}
