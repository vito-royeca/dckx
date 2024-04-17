//
//  WhatIfModel.swift
//  dckx
//
//  Created by Vito Royeca on 4/13/24.
//  Copyright © 2024 Vito Royeca. All rights reserved.
//
//

import Foundation
import SwiftData


@Model class WhatIfModel: Codable {
    var answer: String
    var day = ""
    var link: String
    var month = ""
    @Attribute(.unique) var num: Int
    var question: String
    var questioner: String
    var thumbnail: String
    var title: String
    var year = ""

    var isFavorite: Bool

    init(answer: String,
         day: String,
         link: String,
         month: String,
         num: Int,
         question: String,
         questioner: String,
         thumbnail: String,
         title: String,
         year: String) {
        self.answer = answer
        self.day = day
        self.link = link
        self.month = month
        self.num = num
        self.question = question
        self.questioner = questioner
        self.thumbnail = thumbnail
        self.title = title
        self.year = year
        
        isFavorite = false
    }

    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case answer
        case day
        case link
        case month
        case num
        case question
        case questioner
        case thumbnail
        case title
        case year
    }
    
    required init(from decoder : Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        answer = try container.decode(String.self, forKey: .answer)
        if container.contains(.day) {
            day = try container.decode(String.self, forKey: .day)
        }
        link = try container.decode(String.self, forKey: .link)
        if container.contains(.month) {
            month = try container.decode(String.self, forKey: .month)
        }
        num = try container.decode(Int.self, forKey: .num)
        question = try container.decode(String.self, forKey: .question)
        questioner = try container.decode(String.self, forKey: .questioner)
        thumbnail = try container.decode(String.self, forKey: .thumbnail)
        title = try container.decode(String.self, forKey: .title)
        if container.contains(.year) {
            year = try container.decode(String.self, forKey: .year)
        }
        
        isFavorite = false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(answer, forKey: .answer)
        try container.encode(day, forKey: .day)
        try container.encode(link, forKey: .link)
        try container.encode(month, forKey: .month)
        try container.encode(num, forKey: .num)
        try container.encode(question, forKey: .question)
        try container.encode(questioner, forKey: .questioner)
        try container.encode(thumbnail, forKey: .thumbnail)
        try container.encode(title, forKey: .title)
        try container.encode(year, forKey: .year)
    }
}

extension WhatIfModel {
    var description: String {
        get {
            """
                answer: \(answer)
                link: \(link)
                num: \(num)
                question: \(question)
                questioner: \(questioner)
                thumbnail: \(thumbnail)
                title: \(title)
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
    
    var imageURL: URL? {
        get {
            URL(string: thumbnail)
        }
    }
}
