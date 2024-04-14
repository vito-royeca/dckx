//
//  ComicModel.swift
//  dckx
//
//  Created by Vito Royeca on 4/13/24.
//  Copyright © 2024 Vito Royeca. All rights reserved.
//
//

import Foundation
import SwiftData

@Model class ComicModel: Codable {
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
    
    @Transient var month = ""
    @Transient var day = ""
    @Transient var year = ""
    
    var alt: String
    var img: String
    var link: String
    var news: String
    @Attribute(.unique) var num: Int
    var safeTitle: String
    var title: String
    var transcript: String
    
    var date: Date
    var isFavorite: Bool
    var isRead: Bool
    
    init(alt: String,
         img: String,
         link: String,
         news: String,
         num: Int,
         safeTitle: String,
         title: String,
         transcript: String,
         date: Date,
         isFavorite: Bool,
         isRead: Bool) {
        self.alt = alt
        self.img = img
        self.link = link
        self.news = news
        self.num = num
        self.safeTitle = safeTitle
        self.title = title
        self.transcript = transcript
        
        self.date = date
        self.isFavorite = isFavorite
        self.isRead = isRead
    }
    
    required init(from decoder : Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        month = try container.decode(String.self, forKey: .month)
        day = try container.decode(String.self, forKey: .day)
        year = try container.decode(String.self, forKey: .year)
        
        alt = try container.decode(String.self, forKey: .alt)
        img = try container.decode(String.self, forKey: .img)
        link = try container.decode(String.self, forKey: .link)
        news = try container.decode(String.self, forKey: .news)
        num = try container.decode(Int.self, forKey: .num)
        safeTitle = try container.decode(String.self, forKey: .safeTitle)
        title = try container.decode(String.self, forKey: .title)
        transcript = try container.decode(String.self, forKey: .transcript)
        
        date = Date()
        isFavorite = false
        isRead = false
        computeDate()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(month, forKey: .month)
        try container.encode(day, forKey: .day)
        try container.encode(year, forKey: .year)
        
        try container.encode(alt, forKey: .alt)
        try container.encode(img, forKey: .img)
        try container.encode(link, forKey: .link)
        try container.encode(news, forKey: .news)
        try container.encode(num, forKey: .num)
        try container.encode(safeTitle, forKey: .safeTitle)
        try container.encode(title, forKey: .title)
        try container.encode(transcript, forKey: .transcript)
    }

    var explainURL: String {
        get {
            let baseUrl = "https://www.explainxkcd.com/wiki/index.php"
            let comicUrl = "\(num):_\((title).components(separatedBy: " ").joined(separator: "_"))"
            return "\(baseUrl)/\(comicUrl)"
        }
    }
    
    var description: String {
        get {
            """
                alt: \(alt)
                date: \(date)
                img: \(img)
                isFavorite: \(isFavorite)
                isRead: \(isRead)
                link: \(link)
                news: \(news)
                num: \(num)
                safeTitle: \(safeTitle)
                title: \(title)
                transcript: \(transcript)
            """
        }
    }
    
    func computeDate() {
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
            self.date = date
        }
    }
}
