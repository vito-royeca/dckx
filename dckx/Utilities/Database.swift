//
//  Database.swift
//  dckx
//
//  Created by Vito Royeca on 2/29/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import Foundation
import Kanna
//import PromiseKit

class Database {
    
    // MARK: Singleton
    static let sharedInstance = Database()
    private init() {
        
    }
    
    // MARK: Custom methods
    func copyDatabase() {
        guard let sourceUrl = Bundle.main.url(forResource: "dckx",
                                              withExtension: "sqlite"),
            let docsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                               .userDomainMask,
                                                               true).first else {
            return
        }
        
        print("docsPath = \(docsPath)")
        let targetURL = URL(fileURLWithPath: "\(docsPath)/dckx.sqlite")

        if !FileManager.default.fileExists(atPath: "\(docsPath)/dckx.sqlite") {
            do {
                try FileManager.default.copyItem(at: sourceUrl, to: targetURL)
            } catch {
                print(error)
            }
        }
    }
    
    func createDatabase() {
        let dateStart = Date()
        print("Start fetching data. \(dateStart)")
        
//        firstly {
//            scrapeWhatIfs()
//        }.then { data in
//            self.saveAllWhatIfs(data: data)
//        }.then {
//            XkcdAPI.sharedInstance.fetchLastComic()
//        }.then { comic in
//            self.fetchAllComics(from: comic.num)
//        }.done {
//            let dateEnd = Date()
//            let timeDifference = dateEnd.timeIntervalSince(dateStart)
//            
//            print("Total Time Elapsed on: \(dateStart) - \(dateEnd) = \(self.format(timeDifference))")
//        }
//        .catch { error in
//            print(error)
//        }
    }
    
    // MARK: Helper methods
//    func scrapeWhatIf(link: String) -> [String: Any] {
//        do {
//            guard let url = URL(string: link) else {
//                fatalError("Malformed url")
//            }
//            
//            var data = [String: Any]()
////            let document = try HTML(url: url, encoding: .utf8)
////            
////            for div in document.xpath("//article[@class='entry']") {
////                if let title = div.xpath("a").first,
////                    let titleContent = title.content,
////                    let question = div.xpath("p[@id='question']").first,
////                    let questionContent = question.content,
////                    let questioner = div.xpath("p[@id='attribute']").first,
////                    let questionerContent = questioner.content {
////                    
////                    div.removeChild(title)
////                    div.removeChild(question)
////                    div.removeChild(questioner)
////                    
////                    data["title"] = titleContent
////                    data["question"] = questionContent
////                    data["questioner"] = questionerContent.replacingOccurrences(of: "—", with: "").trimmingCharacters(in: CharacterSet.whitespaces)
////                    
////                    if let innerHTML = div.innerHTML {
////                        let answer = innerHTML.replacingOccurrences(of: "\n", with: "")
////                                           .replacingOccurrences(of: "/imgs", with: "https://what-if.xkcd.com/imgs")
////                                           .trimmingCharacters(in: CharacterSet.whitespaces)
////                        data["answer"] = answer
////                    }
////                }
////            }
//            
//            return data
//        } catch {
//            fatalError(error.localizedDescription)
//        }
//    }

//    private func fetchAllComics(from num: Int32) -> Promise<Void> {
//        return Promise { seal in
//            let completion = {
//                print("Done fetching all Comics. \(Date())")
//                seal.fulfill(())
//            }
//            var promises = [()->Promise<Comic>]()
//            
//            for i in stride(from: num, to: 0, by: -1) {
//                // comic #404 is not found!
//                if i == 404 {
//                    continue
//                }
//                promises.append({
//                    return XkcdAPI.sharedInstance.fetchComic(num: i)
//                    
//                })
//            }
//            self.execComicInSequence(promises: promises, completion: completion)
//        }
//    }
    
//    private func scrapeWhatIfs() -> Promise<[[String: Any]]> {
//        return Promise { seal in
//            guard let urlString = "https://what-if.xkcd.com/archive/".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
//                let url = URL(string: urlString) else {
//                fatalError("Malformed url")
//            }
//            
//            var whatifs = [[String: Any]]()
//            
//            do {
//                let document = try HTML(url: url, encoding: .utf8)
//                let formatter = DateFormatter()
//                
//                formatter.dateFormat = "MMM, dd, yyyy"
//                
//                for div in document.xpath("//div[@id='archive-wrapper']") {
//                    for entry in div.xpath("//div[@class='archive-entry']") {
//                        var whatif = [String: Any]()
//                        
//                        if let link = entry.xpath("a").first?["href"],
//                            let thumbnail = entry.xpath("a").first?.xpath("img").first?["src"],
//                            let title = entry.xpath("h1[@class='archive-title']").first?.text,
//                            let date = entry.xpath("h2[@class='archive-date']").first?.text,
//                            let dateObject = formatter.date(from: date) {
//                            
//                            let components = link.components(separatedBy: "/")
//                            let website = components[components.count-3]
//                            let num = components[components.count-2]
//                            let actualLink = "https://\(website)/\(num)"
//                            whatif["num"] = Int32(num) ?? 0
//                            whatif["link"] = actualLink
//                            whatif["thumbnail"] = "https://\(website)\(thumbnail)"
//                            whatif["title"] = title
//                            whatif["date"] = dateObject
//                            
//                            // scrape the actual contents
//                            let data = scrapeWhatIf(link: actualLink)
//                            
//                            for (k,v) in data {
//                                whatif[k] = v
//                            }
//                            print("Done fetching Whatif #\(num)")
//                            whatifs.append(whatif)
//                        }
//                    }
//                }
//                seal.fulfill(whatifs)
//            } catch {
//                seal.reject(error)
//            }
//        }
//    }
//    
//    private func saveAllWhatIfs(data: [[String: Any]]) -> Promise<Void> {
//        return Promise { seal in
//            let completion = {
//                print("Done saving all WhatIfs. \(Date())")
//                seal.fulfill(())
//            }
//            var promises = [()->Promise<Void>]()
//
//            for dict in data {
//                promises.append({
//                    return CoreData.sharedInstance.saveWhatIf(data: dict)
//
//                })
//            }
//            self.execWhatIfInSequence(promises: promises, completion: completion)
//        }
//    }
//    
//    private func execComicInSequence(promises: [()->Promise<Comic>], completion: @escaping () -> Void) {
//        var promise = promises.first!()
//
//        for next in promises {
//            promise = promise.then { n -> Promise<Comic> in
//                return next()
//            }
//        }
//        promise.done {_ in
//            completion()
//        }.catch { error in
//            print(error)
//        }
//    }
//    
//    private func execWhatIfInSequence(promises: [()->Promise<Void>], completion: @escaping () -> Void) {
//        var promise = promises.first!()
//
//        for next in promises {
//            promise = promise.then { n -> Promise<Void> in
//                return next()
//            }
//        }
//        promise.done {_ in
//            completion()
//        }.catch { error in
//            print(error)
//        }
//    }
    
    private func format(_ interval: TimeInterval) -> String {
        if interval == 0 {
            return "HH:mm:ss"
        }
        
        let seconds = interval.truncatingRemainder(dividingBy: 60)
        let minutes = (interval / 60).truncatingRemainder(dividingBy: 60)
        let hours = (interval / 3600)
        return String(format: "%.2d:%.2d:%.2d", Int(hours), Int(minutes), Int(seconds))
    }
}
