//
//  ComicViewModel.swift
//  dckx
//
//  Created by Vito Royeca on 2/14/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftData
import SDWebImage

@Observable
class ComicViewModel {
    var modelContext: ModelContext
    var currentComic: ComicModel?
    private var lastComic: ComicModel?
    var isBusy = false
    var isError = false
    var canDoPrevious = false
    var canDoNext = false
    var comicImageURL: URL?

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
        guard let currentComic = currentComic else {
            return
        }
        
        do {
            currentComic.isFavorite = isFavoriteEnabled
            try modelContext.save()
        } catch {
            print(error)
        }
    }
    
    // MARK: - Helper variables
    
    var comicTitle: String {
        get {
            guard !isBusy,
                let currentComic = currentComic else {
                return ""
            }
            
            let sensitiveData = SensitiveData()
            let title = sensitiveData.showSensitiveContent ? currentComic.safeTitle : currentComic.title
            return title.uppercased()
        }
    }

    // MARK: - Helper methods
    
    func reloadComic() {
        guard let currentComic = currentComic else {
            return
        }
        
        Task {
            do {
                isError = false
                try await load(num: currentComic.num)
            } catch {
                print(error)
                isError = true
            }
        }
    }
    
    private func loadImage() {
        fetchImage(callback: fetchImageCallback)
    }
    
    private func fetchImage(callback: @escaping SDImageLoaderCompletedBlock) {
        comicImageURL = nil
        
        guard let currentComic = currentComic,
            let url = URL(string: currentComic.img) else {
            return
        }
        
        toggle(isNavigationEnabled: true)
        if let cachePath = SDImageCache.shared.cachePath(forKey: currentComic.img),
           FileManager.default.fileExists(atPath: cachePath) {
            comicImageURL = URL(filePath: cachePath)
        } else {
            SDWebImageManager.shared.imageLoader.requestImage(with: url,
                                                              options: .highPriority,
                                                              context: nil,
                                                              progress: nil,
                                                              completed: callback)
        }
    }
    
    private func fetchImageCallback(image: UIImage?, data: Data?, error: Error?, finished: Bool) {
        guard let currentComic = currentComic,
              let image = image,
              let data = data else {
            return
        }

        SDWebImageManager.shared.imageCache.store(image,
                                                  imageData: data,
                                                  forKey: currentComic.img,
                                                  cacheType: .disk)
        
        guard let cachePath = SDImageCache.shared.cachePath(forKey: currentComic.img) else {
            return
        }
        
        comicImageURL = URL(filePath: cachePath)
    }
}

// MARK: - NavigationBarViewDelegate

extension ComicViewModel: NavigationToolbarDelegate {
    func loadFirst() async throws {
        try await load(num: 1)
    }
    
    func loadPrevious() async throws {
        guard let currentComic = currentComic else {
            return
        }
        
        try await load(num: currentComic.num - 1)
    }
    
    func loadRandom() async throws {
        guard let lastComic = lastComic else {
            return
        }

        let random = Int.random(in: 1 ... lastComic.num)
        let descriptor = FetchDescriptor<ComicModel>(predicate: #Predicate { comic in
            comic.num == random
        })
        var comicModel: ComicModel?
        
        do {
            toggle(isNavigationEnabled: false)
            
            if let comic = try modelContext.fetch(descriptor).first {
               comicModel = comic
            } else {
                let model = try await XkcdAPI.sharedInstance.fetchComic(num: random)
                modelContext.insert(model)
                comicModel = try modelContext.fetch(descriptor).first
            }
            toggle(isNavigationEnabled: true)

            guard let comicModel = comicModel else {
                return
            }

            let sensitiveData = SensitiveData()
            if !sensitiveData.showSensitiveContent &&
                sensitiveData.containsSensitiveData(comicModel) {
                try await loadRandom()
            } else {
                currentComic = comicModel
            }

            loadImage()
        } catch {
            print(error)
            toggle(isNavigationEnabled: true)
        }
    }
    
    func loadNext() async throws {
        guard let currentComic = currentComic else {
            return
        }

        try await load(num: currentComic.num + 1)
    }
    
    func loadLast() async throws {
        var descriptor = FetchDescriptor<ComicModel>(sortBy: [SortDescriptor(\.num, order: .reverse)])
        descriptor.fetchLimit = 1
        var comicModel: ComicModel?
        
        do {
            toggle(isNavigationEnabled: false)

            if let comic = try modelContext.fetch(descriptor).first {
                comicModel = comic
            } else {
                let model = try await XkcdAPI.sharedInstance.fetchLastComic()
                modelContext.insert(model)
                comicModel = try modelContext.fetch(descriptor).first
            }
            toggle(isNavigationEnabled: true)
            
            guard let comicModel = comicModel else {
                return
            }
            
            let sensitiveData = SensitiveData()
            if !sensitiveData.showSensitiveContent &&
                sensitiveData.containsSensitiveData(comicModel) {
                let newNum = comicModel.num - 1
                try await load(num: newNum)
            } else {
                currentComic = comicModel
                lastComic = comicModel
            }

            loadImage()
        } catch {
            print(error)
            toggle(isNavigationEnabled: true)
        }
    }
    
    func load(num: Int) async throws {
        let descriptor = FetchDescriptor<ComicModel>(predicate: #Predicate { comic in
            comic.num == num
        })
        var comicModel: ComicModel?
        
        do {
            toggle(isNavigationEnabled: false)

            if let comic = try modelContext.fetch(descriptor).first {
                comicModel = comic
            } else {
                let model = try await XkcdAPI.sharedInstance.fetchComic(num: num)
                modelContext.insert(model)
                comicModel = try modelContext.fetch(descriptor).first
            }
            toggle(isNavigationEnabled: true)

            guard let comicModel = comicModel else {
                return
            }

            let sensitiveData = SensitiveData()
            if !sensitiveData.showSensitiveContent &&
                sensitiveData.containsSensitiveData(comicModel) {
                let newNum = (num > comicModel.num) ? num + 1 : num - 1
                try await load(num: newNum)
            } else {
                currentComic = comicModel
            }

            loadImage()
        } catch {
            print(error)
            toggle(isNavigationEnabled: true)
        }
    }

    private func toggle(isNavigationEnabled: Bool) {
        if isNavigationEnabled {
            canDoPrevious = currentComic?.num ?? 0 > 1
            
            if let currentComic = currentComic,
                let lastComic = lastComic {
                canDoNext = currentComic.num < lastComic.num
            } else {
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
