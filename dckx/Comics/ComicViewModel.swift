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
    var lastComic: ComicModel?
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
    
    func toggle(isReadEnabled: Bool) {
        guard let currentComic = currentComic else {
            return
        }

        do {
            currentComic.isRead = isReadEnabled
            try modelContext.save()
        } catch {
            print(error)
        }
    }

    // MARK: - Helper variables
    
    var comicTitle: String {
        get {
            (isBusy ? "" : (currentComic?.title ?? "")).uppercased()
        }
    }

    var comicImageURL: URL? {
        guard let comic = currentComic,
              let cachePath = SDImageCache.shared.cachePath(forKey: comic.img) else {
            return nil
        }
        
        return URL(filePath: cachePath)
    }
    
    // MARK: - Helper methods
    
    func load(num: Int) async throws {
        toggle(isNavigationEnabled: false)

        let descriptor = FetchDescriptor<ComicModel>(predicate: #Predicate { comic in
            comic.num == num
        })

        do {
            var comicModel: ComicModel?
            if let comic = try modelContext.fetch(descriptor).first {
                comicModel = comic
            } else {
                do {
                    let model = try await XkcdAPI.sharedInstance.fetchComic(num: num)
                    modelContext.insert(model)
                    comicModel = try modelContext.fetch(descriptor).first
                } catch {
                    print(error)
                    toggle(isNavigationEnabled: true)
                }
            }
            
            guard let comicModel = comicModel else {
                toggle(isNavigationEnabled: true)
                return
            }

            let sensitiveData = SensitiveData()
            if !sensitiveData.showSensitiveContent &&
                sensitiveData.containsSensitiveData(comicModel) {
                let newNum = (num > comicModel.num) ? num + 1 : num - 1
                try await load(num: newNum)
            } else {
                currentComic = comicModel
                toggle(isReadEnabled: true)
            }

            fetchImage(comic: comicModel, callback: fetchImageCallback)
        } catch {
            print(error)
            toggle(isNavigationEnabled: true)
        }
    }
    
    func fetchImage(comic: ComicModel, callback: @escaping SDImageLoaderCompletedBlock) {
            
            
            if let _ = SDImageCache.shared.imageFromCache(forKey: comic.img) {
                toggle(isNavigationEnabled: true)
                return
            } else {
                guard let url = URL(string: comic.img) else {
                    fatalError("Malformed URL")
                }
                
                SDWebImageManager.shared.imageLoader.requestImage(with: url,
                                                                  options: .highPriority,
                                                                  context: nil,
                                                                  progress: nil,
                                                                  completed: callback)
            }
    }
    
    private func fetchImageCallback(image: UIImage?, data: Data?, error: Error?, finished: Bool) {
        toggle(isNavigationEnabled: true)
        
        guard let currentComic = currentComic,
              let image = image,
              let data = data else {
            return
        }

        SDWebImageManager.shared.imageCache.store(image,
                                                  imageData: data,
                                                  forKey: currentComic.img,
                                                  cacheType: .disk)
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
        toggle(isNavigationEnabled: false)
        
        do {
            let comicModel = try await XkcdAPI.sharedInstance.fetchRandomComic()
            modelContext.insert(comicModel)
            
            let sensitiveData = SensitiveData()
            if !sensitiveData.showSensitiveContent &&
                sensitiveData.containsSensitiveData(comicModel) {
                try await loadRandom()
            } else {
                currentComic = comicModel
                toggle(isReadEnabled: true)
            }
            
            fetchImage(comic: comicModel, callback: fetchImageCallback)
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
        toggle(isNavigationEnabled: false)
        
        var descriptor = FetchDescriptor<ComicModel>(sortBy: [SortDescriptor(\.num, order: .reverse)])
        descriptor.fetchLimit = 1
        
        do {
            var comicModel: ComicModel?
            if let comic = try modelContext.fetch(descriptor).first {
                comicModel = comic
            } else {
                do {
                    let model = try await XkcdAPI.sharedInstance.fetchLastComic()
                    modelContext.insert(model)
                    comicModel = try modelContext.fetch(descriptor).first
                } catch {
                    print(error)
                    toggle(isNavigationEnabled: true)
                }
            }
            
            guard let comicModel = comicModel else {
                toggle(isNavigationEnabled: true)
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
                toggle(isReadEnabled: true)
            }
            
            fetchImage(comic: comicModel, callback: fetchImageCallback)
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
