//
//  XkcdAPI.swift
//  dckx
//
//  Created by Vito Royeca on 2/13/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import Foundation
import CoreData
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
    
    // MARK: Comic API methods
    func fetchLastComic() -> Promise<Comic> {
        return Promise { seal in
            let url = "http://xkcd.com/info.0.json"
            
            firstly {
                fetchData(urlString: url)
            }.compactMap { (data, result) in
                try JSONSerialization.jsonObject(with: data) as? [String: Any]
            }.then { data in
                self.coreData.saveComic(data: data)
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
                    self.coreData.saveComic(data: data)
                }.then {
                    self.coreData.loadComic(num: num)
                }.done { comic in
                    print("Done fetching Comic #\(comic.num)")
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
    
    // MARK: Whatif API methods
    func fetchLastWhatIf() -> Promise<WhatIf> {
        return Promise { seal in
            let url = "https://what-if.xkcd.com"
            
            firstly {
                createScrapeWhatIfPromise(link: url)
            }.then { data in
                self.generateNewWhatIf(data: data)
            }.then {  data in
                self.coreData.saveWhatIf(data: data)
            }.then {
                self.coreData.loadLastWhatIf()
            }.done { whatIf in
                seal.fulfill(whatIf)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    private func createScrapeWhatIfPromise(link: String) -> Promise<[String: Any]> {
        return Promise { seal in
            seal.fulfill(Database.sharedInstance.scrapeWhatIf(link: link))
        }
    }
    
    private func generateNewWhatIf(data: [String: Any]) -> Promise<[String: Any]> {
        return Promise { seal in
            
            firstly {
                // trigger dataStack init
                self.coreData.loadWhatIf(num: Int32(1))
            }.then {  _ in
                self.coreData.loadLastWhatIf()
            }.done { whatIf in
                var newData = [String: Any]()
                
                for (k,v) in data {
                    newData[k] = v
                }
                
                if whatIf.title == data["title"] as? String {
                    newData["num"] = whatIf.num
                } else {
                    newData["num"] = Int32(whatIf.num + 1)
                }
                
                seal.fulfill(newData)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func fetchWhatIf(num: Int32) -> Promise<WhatIf> {
        return Promise { seal in
            firstly {
                self.coreData.loadWhatIf(num: num)
            }.done { whatIf in
                seal.fulfill(whatIf)
            }.catch { error in
                seal.reject(error)
//                // comic not found locally, should fetch remotely
//                let url = "http://xkcd.com/\(num)/info.0.json"
//
//                firstly {
//                    self.fetchData(urlString: url)
//                }.compactMap { (data, result) in
//                    try JSONSerialization.jsonObject(with: data) as? [String: Any]
//                }.then { data in
//                    self.coreData.saveComic(data: data)
//                }.then {
//                    self.coreData.loadComic(num: num)
//                }.done { comic in
//                    print("Done fetching Comic #\(comic.num))")
//                    seal.fulfill(comic)
//                }.catch { error in
//                    seal.reject(error)
//                }
            }
        }
    }
    
    func fetchRandomWhatIf() -> Promise<WhatIf> {
        return Promise { seal in
            firstly {
                fetchLastWhatIf()
            }.then { whatIf in
                self.generateRandomNumber(max: Int(whatIf.num))
            }.then { random in
                self.fetchWhatIf(num: Int32(random))
            }.done { whatIf in
                seal.fulfill(whatIf)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    // MARK: Helper methods
    func explainURL(of comic: Comic) -> String {
        let baseUrl = "https://www.explainxkcd.com/wiki/index.php"
        let comicUrl = "\(comic.num):_\((comic.title ?? "").components(separatedBy: " ").joined(separator: "_"))"
        return "\(baseUrl)/\(comicUrl)"
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
