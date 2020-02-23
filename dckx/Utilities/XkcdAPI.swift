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
    
    func fetchComic(num: Int32) -> Promise<Comic> {
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
                self.fetchComic(num: Int32(random))
            }.done { comic in
                seal.fulfill(comic)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func fetchAllComics() {
        print("docsPath = \(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])")
        print("Start fetching all Comics. \(Date())")
        
        firstly {
            fetchLastComic()
        }.done { comic in
            let completion = {
                print("Done fetching all Comics. \(Date())")
            }
            var promises = [()->Promise<Comic>]()
            
            for i in stride(from: comic.num, to: 1, by: -1) {
                promises.append({
                    return self.fetchComic(num: i)
                    
                })
            }
            self.execInSequence(promises: promises, completion: completion)
        }.catch { error in
            print(error)
        }
    }
    
    // MARK: Helper methods
    func explainURL(of comic: Comic) -> String {
        let baseUrl = "https://www.explainxkcd.com/wiki/index.php"
        let comicUrl = "\(comic.num):_\((comic.title ?? "").components(separatedBy: " ").joined(separator: "_"))"
        return "\(baseUrl)/\(comicUrl)"
    }
    
    func execInSequence(promises: [()->Promise<Comic>], completion: @escaping () -> Void) {
        var promise = promises.first!()

        for next in promises {
            promise = promise.then { n -> Promise<Comic> in
                print("\(n.num): \(n.title ?? "")")
                return next()
            }
        }
        promise.done {_ in
            completion()
        }.catch { error in
            print(error)
        }
    }
    
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
