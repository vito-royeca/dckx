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


@Model class ComicModel {
    var alt: String
    var date: Date
    var img: String
    var isFavorite: Bool
    var isRead: Bool
    var link: String
    var news: String
    @Attribute(.unique) var num: Int
    var safeTitle: String
    var title: String
    var transcript: String

    init(alt: String,
         date: Date,
         img: String,
         isFavorite: Bool,
         isRead: Bool,
         link: String,
         news: String,
         num: Int,
         safeTitle: String,
         title: String,
         transcript: String) {
        self.alt = alt
        self.date = date
        self.img = img
        self.isFavorite = isFavorite
        self.isRead = isRead
        self.link = link
        self.news = news
        self.num = num
        self.safeTitle = safeTitle
        self.title = title
        self.transcript = transcript
    }
    
    init(from json: ComicJSON) {
        alt = json.alt
        date = json.date()
        img = json.img
        isFavorite = false
        isRead = false
        link = json.link
        news = json.news
        num = json.num
        safeTitle = json.safeTitle
        title = json.title
        transcript = json.transcript
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
}
