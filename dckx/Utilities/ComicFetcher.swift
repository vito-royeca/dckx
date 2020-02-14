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
    @Published var comic: Comic?
    
    init() {
        loadCurrentComic()
    }

    func loadCurrentComic() {
        firstly {
            XkcdAPI.sharedInstance.fetchCurrentComic()
        }.done { comic in
            self.comic = comic
        }.catch { error in
            print(error)
        }
    }
    
    func loadFirstComic() {
        firstly {
            XkcdAPI.sharedInstance.fetchComic(num: 1)
        }.done { comic in
            self.comic = comic
        }.catch { error in
            print(error)
        }
    }
    
    func loadPreviousComic() {
        guard let comic = comic else {
            return
        }
        
        firstly {
            XkcdAPI.sharedInstance.fetchComic(num: Int16(comic.num - 1))
        }.done { comic in
            self.comic = comic
        }.catch { error in
            print(error)
        }
    }
    
    func loadRandomComic() {
        firstly {
            XkcdAPI.sharedInstance.fetchRandomComic()
        }.done { comic in
            self.comic = comic
        }.catch { error in
            print(error)
        }
    }
    
    func loadNextComic() {
        guard let comic = comic else {
            return
        }
        
        firstly {
            XkcdAPI.sharedInstance.fetchComic(num: Int16(comic.num + 1))
        }.done { comic in
            self.comic = comic
        }.catch { error in
            print(error)
        }
    }
    
    func loadLastComic() {
        loadCurrentComic()
    }
}
