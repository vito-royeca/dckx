//
//  ComicListViewModel.swift
//  dckx
//
//  Created by Vito Royeca on 4/13/24.
//  Copyright © 2024 Vito Royeca. All rights reserved.
//

import SwiftUI
import SwiftData

@Observable
class ComicListViewModel {
    var modelContext: ModelContext
    var searchText = ""
    var comics = [ComicModel]()
    var groupedComics = [String: [ComicModel]]()
    
    // MARK: - Initializer

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        Task {
            do {
                try await loadComics()
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: - Custom methods

    func loadComics() async throws {
        do {
            var predicate: Predicate<ComicModel>?
            
            if searchText.count == 1 {
                predicate = #Predicate { comic in
                    comic.title.starts(with: searchText)
                }
            } else if searchText.count > 1 {
                predicate = #Predicate { comic in
                    comic.title.contains(searchText) ||
                    comic.alt.contains(searchText)
                }
            }
            let descriptor = FetchDescriptor<ComicModel>(predicate: predicate,
                                                         sortBy: [SortDescriptor(\.num, order: .reverse)])
            
            
            comics = try modelContext.fetch(descriptor)
            groupedComics = Dictionary(grouping: comics) { (element) -> String in
                return element.year
            }
        } catch {
            print("Fetch failed")
        }
    }
}
