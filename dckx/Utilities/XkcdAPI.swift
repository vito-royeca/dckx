//
//  XkcdAPI.swift
//  dckx
//
//  Created by Vito Royeca on 2/13/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import Foundation
import PromiseKit

class XkcdAPI {
    // MArk: Variables
    private var coreData: CoreData!
    
    // MARK: Singleton
    static let sharedInstance = XkcdAPI(coreData: CoreData.sharedInstance)
    static let mockInstance = XkcdAPI(coreData: CoreData.mockInstance)
    private init(coreData: CoreData) {
        self.coreData = coreData
    }
    
    // MARK: API methods
    func fetchLastComic() -> Promise<Comic> {
        return Promise { seal in
            let url = "http://xkcd.com/info.0.json"
            
            firstly {
                fetchData(urlString: url)
            }.compactMap { (data, result) in
                try JSONSerialization.jsonObject(with: data) as? [String: Any]
            }.then { data in
                self.coreData.saveComics(data: [data])
            }.then {
                self.coreData.loadLastComic()
            }.done { comic in
                seal.fulfill(comic)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func fetchComic(num: Int16) -> Promise<Comic> {
        return Promise { seal in
            firstly {
                self.coreData.loadComic(num: num)
            }.done { comic in
                seal.fulfill(comic)
            }.catch { error in
                // comic not found locally, should fetch remotely
                let url = "http://xkcd.com/\(num)/info.0.json"
                
                firstly {
                    self.fetchData(urlString: url)
                }.compactMap { (data, result) in
                    try JSONSerialization.jsonObject(with: data) as? [String: Any]
                }.then { data in
                    self.coreData.saveComics(data: [data])
                }.then {
                    self.coreData.loadComic(num: num)
                }.done { comic in
                    seal.fulfill(comic)
                }.catch { error in
                    seal.reject(error)
                }
            }
        }
    }
    
    func fetchRandomComic() -> Promise<Comic> {
        return Promise { seal in
            firstly {
                fetchLastComic()
            }.then { comic in
                self.generateRandomNumber(max: Int(comic.num))
            }.then { random in
                self.fetchComic(num: Int16(random))
            }.done { comic in
                seal.fulfill(comic)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    // MARK: Helper methods
    private func fetchData(urlString: String) -> Promise<(data: Data, response: URLResponse)> {
        guard let cleanURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: cleanURL) else {
            fatalError("Malformed url")
        }
           
        let rq = URLRequest(url: url)
           
        return URLSession.shared.dataTask(.promise, with: rq)
    }
    
    private func generateRandomNumber(max: Int) -> Promise<Int> {
        return Promise { seal in
            let random = Int.random(in: 0 ... max)
            seal.fulfill(random)
        }
    }
}
