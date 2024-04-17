//
//  WhatIfViewModel.swift
//  dckx
//
//  Created by Vito Royeca on 2/29/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI
import SwiftData

@Observable
class WhatIfViewModel {
    var modelContext: ModelContext
    var currentWhatIf: WhatIfModel?
    private var lastWhatIf: WhatIfModel?
    var isBusy = false
    var isError = false
    var canDoPrevious = false
    var canDoNext = false
    
    // MARK: - Initializer
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        Task {
            do {
                try await loadLast()
                canDoPrevious = true
            } catch {
                print(error)
            }
        }
    }

    // MARK: - Toolbar methods
    
    func toggle(isFavoriteEnabled: Bool) {
        guard let currentWhatIf = currentWhatIf else {
            return
        }

        isError = false

        do {
            currentWhatIf.isFavorite = isFavoriteEnabled
            try modelContext.save()
        } catch {
            print(error)
            isError = true
        }
    }
    
    // MARK: - Helper methods
    
    func reloadWhatIf() {
        guard let currentWhatIf = currentWhatIf else {
            return
        }
        
        Task {
            do {
                isError = false
                try await load(num: currentWhatIf.num)
            } catch {
                print(error)
                isError = true
            }
        }
    }
}

// MARK: - NavigationBarViewDelegate

extension WhatIfViewModel: NavigationToolbarDelegate {
    func loadFirst() async throws {
        try await load(num: 1)
    }
    
    func loadPrevious() async throws {
        guard let currentWhatIf = currentWhatIf else {
            return
        }
        
        try await load(num: currentWhatIf.num - 1)
    }
    
    func loadRandom() async throws {
        guard let lastWhatIf = lastWhatIf else {
            return
        }

        let random = Int.random(in: 1 ... lastWhatIf.num)
        let descriptor = FetchDescriptor<WhatIfModel>(predicate: #Predicate { whatIf in
            whatIf.num == random
        })
        var whatIfModel: WhatIfModel?
        
        do {
            toggle(isNavigationEnabled: false)
            
            if let whatIf = try modelContext.fetch(descriptor).first {
               whatIfModel = whatIf
            } else {
                let model = try await XkcdAPI.sharedInstance.fetchWhatIf(num: random)
                modelContext.insert(model)
                whatIfModel = try modelContext.fetch(descriptor).first
            }

            currentWhatIf = whatIfModel
            toggle(isNavigationEnabled: true)
        } catch {
            print(error)
            toggle(isNavigationEnabled: true)
        }
    }
    
    func loadNext() async throws {
        guard let currentWhatIf = currentWhatIf else {
            return
        }

        try await load(num: currentWhatIf.num + 1)
    }
    
    func loadLast() async throws {
        var descriptor = FetchDescriptor<WhatIfModel>(sortBy: [SortDescriptor(\.num, order: .reverse)])
        descriptor.fetchLimit = 1
        var whatIfModel: WhatIfModel?
        
        do {
            toggle(isNavigationEnabled: false)

            if let whatIf = try modelContext.fetch(descriptor).first {
                whatIfModel = whatIf
            } else {
                let model = try await XkcdAPI.sharedInstance.fetchLastWhatIf()
                modelContext.insert(model)
                whatIfModel = try modelContext.fetch(descriptor).first
            }
            
            currentWhatIf = whatIfModel
            lastWhatIf = whatIfModel
            toggle(isNavigationEnabled: true)
        } catch {
            print(error)
            toggle(isNavigationEnabled: true)
        }
    }
    
    func load(num: Int) async throws {
        let descriptor = FetchDescriptor<WhatIfModel>(predicate: #Predicate { whatIf in
            whatIf.num == num
        })
        var whatIfModel: WhatIfModel?
        
        do {
            toggle(isNavigationEnabled: false)

            if let whatIf = try modelContext.fetch(descriptor).first {
                whatIfModel = whatIf
            } else {
                let model = try await XkcdAPI.sharedInstance.fetchWhatIf(num: num)
                modelContext.insert(model)
                whatIfModel = try modelContext.fetch(descriptor).first
            }

            currentWhatIf = whatIfModel
            toggle(isNavigationEnabled: true)
        } catch {
            print(error)
            toggle(isNavigationEnabled: true)
        }
    }

    private func toggle(isNavigationEnabled: Bool) {
        if isNavigationEnabled {
            if let currentWhatIf = currentWhatIf {
                canDoPrevious = currentWhatIf.num > 1
                
                if let lastWhatIf = lastWhatIf {
                    canDoNext = currentWhatIf.num < lastWhatIf.num
                }
            } else {
                canDoPrevious = false
                canDoNext = false
            }

            isBusy = false
        } else {
            canDoPrevious = false
            canDoNext = false
            isBusy = true
        }
    }
}
