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


@Model class WhatIfModel {
    var answer: String
    var date: Date
    var isFavorite: Bool
    var isRead: Bool
    var link: String
    @Attribute(.unique) var num: Int
    var question: String
    var questioner: String
    var thumbnail: String
    var title: String

    init(answer: String,
         date: Date,
         isFavorite: Bool,
         isRead: Bool,
         link: String,
         num: Int,
         question: String,
         questioner: String,
         thumbnail: String,
         title: String) {
        self.answer = answer
        self.date = date
        self.isFavorite = isFavorite
        self.isRead = isRead
        self.link = link
        self.num = num
        self.question = question
        self.questioner = questioner
        self.thumbnail = thumbnail
        self.title = title
    }
}
