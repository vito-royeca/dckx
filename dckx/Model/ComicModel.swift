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
//import SDWebImage

@Model class ComicModel: Codable {
    var alt: String
    var day = ""
    var img: String
    var link: String
    var month = ""
    var news: String
    @Attribute(.unique) var num: Int
    var safeTitle: String
    var title: String
    var transcript: String
    var year = ""
    
    var isFavorite: Bool
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case alt
        case day
        case img
        case link
        case month
        case news
        case num
        case safeTitle = "safe_title"
        case title
        case transcript
        case year
    }

    required init(from decoder : Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        alt = try container.decode(String.self, forKey: .alt)
        day = try container.decode(String.self, forKey: .day)
        img = try container.decode(String.self, forKey: .img)
        link = try container.decode(String.self, forKey: .link)
        month = try container.decode(String.self, forKey: .month)
        news = try container.decode(String.self, forKey: .news)
        num = try container.decode(Int.self, forKey: .num)
        safeTitle = try container.decode(String.self, forKey: .safeTitle)
        title = try container.decode(String.self, forKey: .title)
        transcript = try container.decode(String.self, forKey: .transcript)
        year = try container.decode(String.self, forKey: .year)
        
        isFavorite = false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(alt, forKey: .alt)
        try container.encode(day, forKey: .day)
        try container.encode(img, forKey: .img)
        try container.encode(link, forKey: .link)
        try container.encode(month, forKey: .month)
        try container.encode(news, forKey: .news)
        try container.encode(num, forKey: .num)
        try container.encode(safeTitle, forKey: .safeTitle)
        try container.encode(title, forKey: .title)
        try container.encode(transcript, forKey: .transcript)
        try container.encode(year, forKey: .year)
    }
}

extension ComicModel {
    var description: String {
        get {
            """
                alt: \(alt)
                img: \(img)
                isFavorite: \(isFavorite)
                link: \(link)
                news: \(news)
                num: \(num)
                safeTitle: \(safeTitle)
                title: \(title)
                transcript: \(transcript)
            """
        }
    }

    var displayDate: String {
        get {
            if year.isEmpty && month.isEmpty && day.isEmpty {
                ""
            } else {
                "\(year)-\(month)-\(day)"
            }
        }
    }

    var explainURL: String {
        get {
            let baseUrl = "https://www.explainxkcd.com/wiki/index.php"
            let comicUrl = "\(num):_\((title).components(separatedBy: " ").joined(separator: "_"))"
            return "\(baseUrl)/\(comicUrl)"
        }
    }
    
    var imageURL: URL? {
        get {
            URL(string: img)
        }
    }
}
