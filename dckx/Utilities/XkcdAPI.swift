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
    // MARK: Singleton
    static let sharedInstance = XkcdAPI()
    private init() {
        
    }
    
    // MARK: Utility methods
    func fetchData(urlString: String) -> Promise<(data: Data, response: URLResponse)> {
        guard let cleanURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: cleanURL) else {
            fatalError("Malformed url")
        }
        
        let rq = URLRequest(url: url)
        
        return URLSession.shared.dataTask(.promise, with: rq)
    }
    
    // MARK: API methods
    func fetchCurrentComic() -> Promise<Comic> {
        return Promise { seal in
            let url = "http://xkcd.com/info.0.json"
            
            firstly {
                fetchData(urlString: url)
            }.compactMap { (data, result) in
                try JSONSerialization.jsonObject(with: data) as? [String: Any]
            }.then { data in
                CoreData.sharedInstance.saveComics(data: [data])
            }.then {
                CoreData.sharedInstance.loadCurrentComic()
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
                CoreData.sharedInstance.loadComic(num: num)
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
                    CoreData.sharedInstance.saveComics(data: [data])
                }.then {
                    CoreData.sharedInstance.loadComic(num: num)
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
                fetchCurrentComic()
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
    
    private func generateRandomNumber(max: Int) -> Promise<Int> {
        return Promise { seal in
            let random = Int.random(in: 0 ... max)
            seal.fulfill(random)
        }
    }
}
