//
//  XkcdAPI.swift
//  dckx
//
//  Created by Vito Royeca on 2/13/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import Foundation
import CoreData
import Kanna

enum XkcdAPIError: Error {
    case invalidURL
    case httpError
    case unknownError
}

class XkcdAPI {
    // MARK: - Singleton

    static let sharedInstance = XkcdAPI()
    
    // MARK: - Comic API methods

    func fetchLastComic() async throws -> ComicJSON {
        do {
            let urlString = "http://xkcd.com/info.0.json"
            
            guard let url = URL(string: urlString) else {
                throw XkcdAPIError.invalidURL
            }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                throw XkcdAPIError.httpError
            }
            
            let result = try JSONDecoder().decode(ComicJSON.self,
                                                  from: data)
            return result
        } catch {
            throw XkcdAPIError.unknownError
        }
    }
    
    func fetchComic(num: Int) async throws -> ComicJSON {
        do {
            let urlString = "http://xkcd.com/\(num)/info.0.json"
            
            guard let url = URL(string: urlString) else {
                throw XkcdAPIError.invalidURL
            }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                throw XkcdAPIError.httpError
            }
            
            let result = try JSONDecoder().decode(ComicJSON.self,
                                                  from: data)
            return result
        } catch {
            throw XkcdAPIError.unknownError
        }
    }
    
    func fetchRandomComic() async throws -> ComicJSON {
        do {
            var comicJson = try await fetchLastComic()
            let random = Int.random(in: 1 ... comicJson.num)
            
            if random != comicJson.num {
                comicJson = try await fetchComic(num: random)
            }
            return comicJson
        } catch {
            throw XkcdAPIError.unknownError
        }
    }
    
    // MARK: - Whatif API methods

    func scrapeWhatIf(link: String) -> WhatIfJSON {
        do {
            guard let url = URL(string: link) else {
                fatalError("Malformed url")
            }
            
            
            let document = try HTML(url: url, encoding: .utf8)
            var dict = [String: Any]()

            for div in document.xpath("//section[@id='entry-wrapper']") {
                for div in document.xpath("//nav[@class='main-nav']") {
                    // get num here
                }

                for div in document.xpath("//article[@id='entry']") {
                    if let title = div.xpath("a").first,
                       let titleContent = title.content,
                       let question = div.xpath("p[@id='question']").first,
                       let questionContent = question.content,
                       let questioner = div.xpath("p[@id='attribute']").first,
                       let questionerContent = questioner.content {
                        
                        div.removeChild(title)
                        div.removeChild(question)
                        div.removeChild(questioner)
                        
                        dict["title"] = titleContent
                        dict["question"] = questionContent
                        dict["questioner"] = questionerContent
                            .replacingOccurrences(of: "—", with: "")
                            .trimmingCharacters(in: CharacterSet.whitespaces)
                        
                        if let innerHTML = div.innerHTML {
                            let answer = innerHTML
                                .replacingOccurrences(of: "\n", with: "")
                                .replacingOccurrences(of: "/imgs", with: "https://what-if.xkcd.com/imgs")
                                .trimmingCharacters(in: CharacterSet.whitespaces)
                            dict["answer"] = answer
                        }
                    }
                }
            }
            
            return WhatIfJSON(answer: dict["answer"] as? String ?? "",
                              link: link,
                              num: dict["num"] as? Int ?? 0,
                              question: dict["question"] as? String ?? "",
                              questioner: dict["questioner"] as? String ?? "",
                              thumbnail: dict["thumbnail"] as? String ?? "",
                              title: dict["title"] as? String ?? "")
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
//    func fetchLastWhatIf() -> Promise<WhatIf> {
//        return Promise { seal in
//            let url = "https://what-if.xkcd.com"
//            
//            firstly {
//                createScrapeWhatIfPromise(link: url)
//            }.then { data in
//                self.generateNewWhatIf(data: data)
//            }.then {  data in
//                self.coreData.saveWhatIf(data: data)
//            }.then {
//                self.coreData.loadLastWhatIf()
//            }.done { whatIf in
//                seal.fulfill(whatIf)
//            }.catch { error in
//                seal.reject(error)
//            }
//        }
//    }
    
//    private func createScrapeWhatIfPromise(link: String) -> Promise<[String: Any]> {
//        return Promise { seal in
//            seal.fulfill(Database.sharedInstance.scrapeWhatIf(link: link))
//        }
//    }
//    
//    private func generateNewWhatIf(data: [String: Any]) -> Promise<[String: Any]> {
//        return Promise { seal in
//            
//            firstly {
//                // trigger dataStack init
//                self.coreData.loadWhatIf(num: Int32(1))
//            }.then {  _ in
//                self.coreData.loadLastWhatIf()
//            }.done { whatIf in
//                var newData = [String: Any]()
//                
//                for (k,v) in data {
//                    newData[k] = v
//                }
//                
//                if whatIf.title == data["title"] as? String {
//                    newData["num"] = whatIf.num
//                } else {
//                    newData["num"] = Int32(whatIf.num + 1)
//                }
//                
//                seal.fulfill(newData)
//            }.catch { error in
//                seal.reject(error)
//            }
//        }
//    }
    
//    func fetchWhatIf(num: Int32) -> Promise<WhatIf> {
//        return Promise { seal in
//            firstly {
//                self.coreData.loadWhatIf(num: num)
//            }.done { whatIf in
//                seal.fulfill(whatIf)
//            }.catch { error in
//                seal.reject(error)
////                // comic not found locally, should fetch remotely
////                let url = "http://xkcd.com/\(num)/info.0.json"
////
////                firstly {
////                    self.fetchData(urlString: url)
////                }.compactMap { (data, result) in
////                    try JSONSerialization.jsonObject(with: data) as? [String: Any]
////                }.then { data in
////                    self.coreData.saveComic(data: data)
////                }.then {
////                    self.coreData.loadComic(num: num)
////                }.done { comic in
////                    print("Done fetching Comic #\(comic.num))")
////                    seal.fulfill(comic)
////                }.catch { error in
////                    seal.reject(error)
////                }
//            }
//        }
//    }
    
//    func fetchRandomWhatIf() -> Promise<WhatIf> {
//        return Promise { seal in
//            firstly {
//                fetchLastWhatIf()
//            }.then { whatIf in
//                self.generateRandomNumber(max: Int(whatIf.num))
//            }.then { random in
//                self.fetchWhatIf(num: Int32(random))
//            }.done { whatIf in
//                seal.fulfill(whatIf)
//            }.catch { error in
//                seal.reject(error)
//            }
//        }
//    }
    
    // MARK: - Helper methods

//    private func generateRandomNumber(max: Int) -> Promise<Int> {
//        return Promise { seal in
//            let random = Int.random(in: 0 ... max)
//            seal.fulfill(random)
//        }
//    }
}
