//
//  XkcdAPI.swift
//  dckx
//
//  Created by Vito Royeca on 2/13/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import Foundation
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

    func fetchLastComic() async throws -> ComicModel {
        do {
            let urlString = "http://xkcd.com/info.0.json"
            
            guard let url = URL(string: urlString) else {
                throw XkcdAPIError.invalidURL
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode(ComicModel.self,
                                                  from: data)
            return result
        } catch {
            throw XkcdAPIError.httpError
        }
    }
    
    func fetchComic(num: Int) async throws -> ComicModel {
        do {
            let urlString = "http://xkcd.com/\(num)/info.0.json"
            
            guard let url = URL(string: urlString) else {
                throw XkcdAPIError.invalidURL
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode(ComicModel.self,
                                                  from: data)
            return result
        } catch {
            throw XkcdAPIError.httpError
        }
    }
    
    // MARK: - Whatif API methods
    
    func fetchLastWhatIf() async throws -> WhatIfModel {
        do {
            let url = "https://what-if.xkcd.com"
            let result = try await scrapeWhatIf(link: url)
            return result
        } catch {
            throw XkcdAPIError.unknownError
        }
    }

    func fetchWhatIf(num: Int) async throws -> WhatIfModel {
        do {
            let url = "https://what-if.xkcd.com/\(num)"
            let result = try await scrapeWhatIf(link: url)
            return result
        } catch {
            throw XkcdAPIError.httpError
        }
    }

    private func scrapeWhatIf(link: String) async throws -> WhatIfModel {
        do {
            guard let url = URL(string: link) else {
                throw XkcdAPIError.invalidURL
            }

            let document = try HTML(url: url, encoding: .utf8)
            var dict = [String: Any]()

            for _ in document.xpath("//section[@id='entry-wrapper']") {
                for nav in document.xpath("//nav[@class='main-nav']") {
                    var previous = ""
                    var next = ""
                    var current = 0
                
                    for link in nav.xpath("a") {
                        if let href = link["href"],
                           let number = href.components(separatedBy: "/").last {
                            
                            if previous == "" {
                                previous = number
                            } else {
                                next = number
                            }
                        }
                    }
                    
                    if previous == "#" {
                        current = 1
                    } else if next == "#" {
                        current = (Int(previous) ?? 0)  + 1
                    } else {
                        current = (Int(next) ?? 0) - 1
                    }

                    dict["num"] = current
                }

                for article in document.xpath("//h2[@id='title']") {
                    if let title = article.xpath("a").first,
                       let titleContent = title.content {
                        dict["title"] = titleContent
                    }
                }

                for article in document.xpath("//article[@id='entry']") {
                    if let question = article.xpath("p[@id='question']").first,
                       let questionContent = question.content,
                       let questioner = article.xpath("p[@id='attribute']").first,
                       let questionerContent = questioner.content {
                        
                        article.removeChild(question)
                        article.removeChild(questioner)
                        
                        var cleanQuestionerContent = questionerContent
                        if cleanQuestionerContent.hasPrefix("— ") || cleanQuestionerContent.hasPrefix("- "){
                            cleanQuestionerContent = String(cleanQuestionerContent.dropFirst(2))
                        }
                        if cleanQuestionerContent.hasPrefix("—") || cleanQuestionerContent.hasPrefix("-"){
                            cleanQuestionerContent = String(cleanQuestionerContent.dropFirst(1))
                        }
                        
                        dict["question"] = questionContent
                        dict["questioner"] = cleanQuestionerContent
                        
                        if let innerHTML = article.innerHTML {
                            let answer = innerHTML
                                .replacingOccurrences(of: "\n", with: "")
                                .replacingOccurrences(of: "/imgs", with: "https://what-if.xkcd.com/imgs")
                                .trimmingCharacters(in: CharacterSet.whitespaces)
                            dict["answer"] = answer
                        }
                    }
                }
            }
            
            return WhatIfModel(answer: dict["answer"] as? String ?? "",
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
