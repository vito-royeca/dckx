//
//  ComicJSON.swift
//  dckx
//
//  Created by Vito Royeca on 4/13/24.
//  Copyright © 2024 Vito Royeca. All rights reserved.
//

import Foundation

final class ComicJSON: Codable {
    enum CodingKeys: String, CodingKey {
        case month
        case day
        case year
        
        case num
        case link
        case news
        case safeTitle = "safe_title"
        case transcript
        case alt
        case img
        case title
    }

    var month: String
    var day: String
    var year: String
    var num: Int
    var link: String
    var news: String
    var safeTitle: String
    var transcript: String
    var alt: String
    var img: String
    var title: String
    
    init(from decoder : Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        month = try container.decode(String.self, forKey: .month)
        day = try container.decode(String.self, forKey: .day)
        year = try container.decode(String.self, forKey: .year)
        
        num = try container.decode(Int.self, forKey: .num)
        link = try container.decode(String.self, forKey: .link)
        news = try container.decode(String.self, forKey: .news)
        safeTitle = try container.decode(String.self, forKey: .safeTitle)
        transcript = try container.decode(String.self, forKey: .transcript)
        alt = try container.decode(String.self, forKey: .alt)
        img = try container.decode(String.self, forKey: .img)
        title = try container.decode(String.self, forKey: .title)
    }
    
    func date() -> Date {
        let year = self.year
        var month = self.month
        var day = self.day
        
        if let num = Int(month) {
            month = num < 10 ? "0\(num)" : "\(num)"
        }
        if let num = Int(day) {
            day = num < 10 ? "0\(num)" : "\(num)"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if !year.isEmpty && !month.isEmpty && !day.isEmpty,
           let date = formatter.date(from: "\(year)-\(month)-\(day)") {
            return date
        } else {
            return Date()
        }
    }
}