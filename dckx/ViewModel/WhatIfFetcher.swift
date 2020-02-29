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

class WhatIfFetcher: ObservableObject {
    @Published var currentWhatIf: WhatIf?
    @Published var lastWhatIf: WhatIf?
    
    // MARK: Initializer
    init() {
        loadLastWhatIf()
    }

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
            self.loadWhatIf(num: currentWhatIf.num)
        }.catch { error in
            print(error)
        }
    }
    
    private func toggleIsRead() {
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
    func loadFirstWhatIf() {
        loadWhatIf(num: 1)
    }
    
    func loadPreviousWhatIf() {
        guard let currentWhatIf = currentWhatIf else {
            return
        }
        loadWhatIf(num: currentWhatIf.num - 1)
    }
    
    func loadRandomWhatIf() {
        firstly {
            XkcdAPI.sharedInstance.fetchRandomWhatIf()
        }.done { whatIf in
            self.currentWhatIf = whatIf
            self.toggleIsRead()
        }.catch { error in
            print(error)
        }
    }
    
    func loadNextWhatIf() {
        guard let currentWhatIf = currentWhatIf else {
            return
        }
        loadWhatIf(num: currentWhatIf.num + 1)
    }
    
    func loadLastWhatIf() {
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
    
    // MARK: Button states
    func canDoPrevious() -> Bool {
        guard let currentWhatIf = currentWhatIf else {
            return false
        }
        return currentWhatIf.num > 1
    }
    
    func canDoNext() -> Bool {
        guard let currentWhatIf = currentWhatIf,
            let lastWhatIf = lastWhatIf else {
            return false
        }
        return currentWhatIf.num < lastWhatIf.num
    }
    
    // MARK: Helper methods
    func loadWhatIf(num: Int32) {
        firstly {
            XkcdAPI.sharedInstance.fetchWhatIf(num: num)
        }.done { whatIf in
            self.currentWhatIf = whatIf
            self.toggleIsRead()
        }.catch { error in
            print(error)
        }
    }
}
