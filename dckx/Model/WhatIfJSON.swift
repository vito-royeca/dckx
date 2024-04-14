//
//  WhatIfJSON.swift
//  dckx
//
//  Created by Vito Royeca on 4/13/24.
//  Copyright © 2024 Vito Royeca. All rights reserved.
//

import Foundation

final class WhatIfJSON: Codable {
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
    var num: Int
    var question: String
    var questioner: String
    var thumbnail: String
    var title: String
    
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
    }

    init(from decoder : Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.answer = try container.decode(String.self, forKey: .answer)
        self.link = try container.decode(String.self, forKey: .link)
        self.num = try container.decode(Int.self, forKey: .num)
        self.question = try container.decode(String.self, forKey: .question)
        self.questioner = try container.decode(String.self, forKey: .questioner)
        self.thumbnail = try container.decode(String.self, forKey: .thumbnail)
        self.title = try container.decode(String.self, forKey: .title)
    }
}
