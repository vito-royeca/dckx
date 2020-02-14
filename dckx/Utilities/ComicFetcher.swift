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
        loadLastComic()
    }

    // MARK: Button actions
    func loadFirstComic() {
        loadComic(num: 1)
    }
    
    func loadPreviousComic() {
        guard let currentComic = currentComic else {
            return
        }
        loadComic(num: Int16(currentComic.num - 1))
    }
    
    func loadRandomComic() {
        firstly {
            XkcdAPI.sharedInstance.fetchRandomComic()
        }.done { comic in
            self.currentComic = comic
        }.catch { error in
            print(error)
        }
    }
    
    func loadNextComic() {
        guard let currentComic = currentComic else {
            return
        }
        loadComic(num: Int16(currentComic.num + 1))
    }
    
    func loadLastComic() {
        firstly {
            XkcdAPI.sharedInstance.fetchLastComic()
        }.done { comic in
            self.currentComic = comic
            self.lastComic = comic
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
    private func loadComic(num: Int16) {
        firstly {
            XkcdAPI.sharedInstance.fetchComic(num: num)
        }.done { comic in
            self.currentComic = comic
        }.catch { error in
            print(error)
        }
    }
}
