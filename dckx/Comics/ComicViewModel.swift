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
    
    // MARK: - Initializer
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        Task {
            do {
                try await loadLast()
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: - Toolbar methods
    
    func toggle(isFavorite: Bool) {
        guard let currentComic = currentComic else {
            return
        }
        
        do {
            currentComic.isFavorite = isFavorite
            try modelContext.save()
        } catch {
            print(error)
        }
    }
    
    func toggle(isRead: Bool) {
        guard let currentComic = currentComic else {
            return
        }

        do {
            currentComic.isRead = isRead
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

    // MARK: - Helper methods
    
    func load(num: Int) async throws {
        isBusy = true
        
        let descriptor = FetchDescriptor<ComicModel>(predicate: #Predicate { comic in
            comic.num == num
        })

        do {
            var comicModel: ComicModel?
            if let comic = try modelContext.fetch(descriptor).first {
                comicModel = comic
            } else {
                do {
                    let comicJson = try await XkcdAPI.sharedInstance.fetchComic(num: num)
                    let model = ComicModel(from: comicJson)
                    modelContext.insert(model)
                    comicModel = try modelContext.fetch(descriptor).first
                } catch {
                    print(error)
                    isBusy = false
                }
            }
            
            guard let comicModel = comicModel else {
                isBusy = false
                return
            }

            let sensitiveData = SensitiveData()
            if !sensitiveData.showSensitiveContent &&
                sensitiveData.containsSensitiveData(comicModel) {
                let newNum = (num > comicModel.num) ? num + 1 : num - 1
                try await load(num: newNum)
            } else {
                currentComic = comicModel
                toggle(isRead: true)
            }

            try await fetchImage(comic: comicModel)
            isBusy = false
        } catch {
            print(error)
            isBusy = false
        }
    }
    
    func fetchImage(comic: ComicModel) async throws {
            guard let url = URL(string: comic.img) else {
                fatalError("Malformed URL")
            }
            
            if let _ = SDImageCache.shared.imageFromCache(forKey: comic.img) {
                return
            } else {

                
//                let callback = { (image: UIImage?, data: Data?, error: Error?, finished: Bool) in
//                    if error != nil {
//                        SDWebImageManager.shared.imageCache.store(image,
//                                                                  imageData: data,
//                                                                  forKey: comic.img,
//                                                                  cacheType: .disk)
//                    }
//                }
//                SDWebImageManager.shared.imageLoader.requestImage(with: url,
//                                                                  options: .highPriority,
//                                                                  context: nil,
//                                                                  progress: nil,
//                                                                  completed: callback)
                let callback = try await SDWebImageManager.shared.imageLoader.requestImage(with: url,
                                                                                           options: .highPriority,
                                                                                           context: nil,
                                                                                           progress: nil)
//                callback(<#UIImage?#>, <#Data?#>, <#(any Error)?#>, <#Bool#>)
            }
    }
    
    func testAsync(param1: String, param2: Int, completion: @escaping (String, String) -> Void) {
        print("test")
        completion("1", "2")
    }
    
    func fetchData(_ completionHandler: @escaping (Result<Data, Error>) -> Void) {
        print("test 2")
    }
}

// MARK: - SDImageLoader
//requestImageWithURL:(nullable NSURL *)url
//                                                options:(SDWebImageOptions)options
//                                                context:(nullable SDWebImageContext *)context
//                                               progress:(nullable SDImageLoaderProgressBlock)progressBlock
//                                              completed:(nullable SDImageLoaderCompletedBlock)completedBlock;
extension SDImageLoader {
    func requestImage(with url: URL?, options: SDWebImageOptions, context: [SDWebImageContextOption: Any]?, progress: SDImageLoaderProgressBlock?) async throws -> SDImageLoaderCompletedBlock? {
        return await withCheckedContinuation { continuation in
            requestImage(with: url,
                         options: options,
                         context: context,
                         progress: progress) { (image,data,error,finished) in
                continuation.resume(returning: { image,data,error,finished in
                    print("we are here...")
                })
            }
        }
    }
}

// MARK: - NavigationBarViewDelegate

extension ComicViewModel: NavigationToolbarDelegate {
    var canDoPrevious: Bool {
        guard let currentComic = currentComic else {
            return false
        }

        return currentComic.num > 1
    }
    
    var canDoNext: Bool {
        guard let currentComic = currentComic,
            let lastComic = lastComic else {
            return false
        }

        return currentComic.num < lastComic.num
    }
    
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
        isBusy = true
        
        do {
            let comicJson = try await XkcdAPI.sharedInstance.fetchRandomComic()
            let comicModel = ComicModel(from: comicJson)
            modelContext.insert(comicModel)
            
            let sensitiveData = SensitiveData()
            if !sensitiveData.showSensitiveContent &&
                sensitiveData.containsSensitiveData(comicModel) {
                try await loadRandom()
            } else {
                currentComic = comicModel
                toggle(isRead: true)
            }
            
            try await fetchImage(comic: comicModel)
            isBusy = false
        } catch {
            print(error)
            isBusy = false
        }
    }
    
    func loadNext() async throws {
        guard let currentComic = currentComic else {
            return
        }

        try await load(num: currentComic.num + 1)
    }
    
    func loadLast() async throws {
        isBusy = true
        
        var descriptor = FetchDescriptor<ComicModel>(sortBy: [SortDescriptor(\.num, order: .reverse)])
        descriptor.fetchLimit = 1
        
        do {
            var comicModel: ComicModel?
            if let comic = try modelContext.fetch(descriptor).first {
                comicModel = comic
            } else {
                do {
                    let comicJson = try await XkcdAPI.sharedInstance.fetchLastComic()
                    let model = ComicModel(from: comicJson)
                    modelContext.insert(model)
                    comicModel = try modelContext.fetch(descriptor).first
                } catch {
                    print(error)
                    isBusy = false
                }
            }
            
            guard let comicModel = comicModel else {
                isBusy = false
                return
            }
            
            let sensitiveData = SensitiveData()
            if !sensitiveData.showSensitiveContent &&
                sensitiveData.containsSensitiveData(comicModel) {
                let newNum = comicModel.num - 1
                try await load(num: newNum)
            } else {
                currentComic = comicModel
                toggle(isRead: true)
            }
            
            try await fetchImage(comic: comicModel)
            isBusy = false
        } catch {
            print(error)
            isBusy = false
        }
    }
}
