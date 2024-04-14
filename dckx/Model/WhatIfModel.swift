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
    enum CodingKeys: String, CodingKey {
        case answer
        case link
        case num
        case question
        case questioner
        case thumbnail
        case title
    }
    
    var answer: String
    var link: String
    @Attribute(.unique) var num: Int
    var question: String
    var questioner: String
    var thumbnail: String
    var title: String

    var isFavorite: Bool
    var isRead: Bool
    
    required init(from decoder : Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        answer = try container.decode(String.self, forKey: .answer)
        link = try container.decode(String.self, forKey: .link)
        num = try container.decode(Int.self, forKey: .num)
        question = try container.decode(String.self, forKey: .question)
        questioner = try container.decode(String.self, forKey: .questioner)
        thumbnail = try container.decode(String.self, forKey: .thumbnail)
        title = try container.decode(String.self, forKey: .title)
        
        isFavorite = false
        isRead = false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(answer, forKey: .answer)
        try container.encode(link, forKey: .link)
        try container.encode(num, forKey: .num)
        try container.encode(question, forKey: .question)
        try container.encode(questioner, forKey: .questioner)
        try container.encode(thumbnail, forKey: .thumbnail)
        try container.encode(title, forKey: .title)
    }

    init(answer: String,
         link: String,
         num: Int,
         question: String,
         questioner: String,
         thumbnail: String,
         title: String) {
        self.answer = answer
        self.link = link
        self.num = num
        self.question = question
        self.questioner = questioner
        self.thumbnail = thumbnail
        self.title = title
        
        isFavorite = false
        isRead = false
    }
}
