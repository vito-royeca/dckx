//
//  Constants.swift
//  dckx
//
//  Created by Vito Royeca on 2/22/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI
import CoreData

extension UIFont {
    static let dckxLargeTitleText = UIFont(name: "xkcd-Script-Regular",
                                           size: 28)!
    static let dckxTitleText      = UIFont(name: "xkcd-Script-Regular",
                                           size: 22)!
    static let dckxRegularText    = UIFont(name: "xkcd-Script-Regular",
                                           size: 17)!
    static let dckxSmallText    = UIFont(name: "xkcd-Script-Regular",
                                           size: 15)!
}

extension Font {
    static let dckxLargeTitleText = Font.custom("xkcd-Script-Regular",
                                                size: 28)
    static let dckxTitleText      = Font.custom("xkcd-Script-Regular",
                                                size: 22)
    static let dckxRegularText    = Font.custom("xkcd-Script-Regular",
                                                size: 17)
    static let dckxSmallText      = Font.custom("xkcd-Script-Regular",
                                                size: 15)
}

extension Color {
    static let buttonColor     = Color("ButtonColor")
    static let backgroundColor = Color("BackgroundColor")
    static let dckxBlue        = Color(red: 0.59, green: 0.66, blue: 0.78) // RGB: 150,168,200
}

struct ButtonModifier: ViewModifier {
    var isDisabled = true
    
    func body(content: Content) -> some View {
        content
            .padding(4)
            .font(.custom("xkcd-Script-Regular", size: 15))
            .foregroundColor(isDisabled ? Color.gray : .white)
            .background(RoundedRectangle(cornerRadius: 4, style:   .circular).foregroundColor(.buttonColor))
    }
}

extension View {
    func customButton(isDisabled: Bool) -> ModifiedContent<Self, ButtonModifier> {
        return modifier(ButtonModifier(isDisabled: isDisabled))
    }
}

struct SensitiveData {
    let sensitiveWords = ["corona",
                          "covid",
                          "immune",
                          "immunity",
                          "mask",
                          "pandemic",
                          "smallpox",
                          "spike",
                          "vaccine",
                          "virus",
                          "viral"]
    let showSensitiveContent = UserDefaults.standard.bool(forKey: SettingsKey.showSensitiveContent)
    
    func createComicsPredicate(basePredicate: NSPredicate?) -> NSPredicate? {
        if !showSensitiveContent {
            var predicates = [NSPredicate]()
            for word in sensitiveWords {
                let predicate = NSPredicate(format: "NOT (title CONTAINS[cd] %@) AND NOT (alt CONTAINS[cd] %@)", word, word)
                predicates.append(predicate)
            }
            
            let newPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            
            if basePredicate != nil {
                return NSCompoundPredicate(andPredicateWithSubpredicates: [basePredicate!, newPredicate])
            } else {
                return newPredicate
            }
        } else {
            return basePredicate
        }
    }
    
    func createWhatIfPredicate(basePredicate: NSPredicate?) -> NSPredicate? {
        if !showSensitiveContent {
            var predicates = [NSPredicate]()
            for word in sensitiveWords {
                let predicate = NSPredicate(format: "NOT (title CONTAINS[cd] %@) AND NOT (question CONTAINS[cd] %@) AND NOT (answer CONTAINS[cd] %@)", word, word, word)
                predicates.append(predicate)
            }
            
            let newPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            
            if basePredicate != nil {
                return NSCompoundPredicate(andPredicateWithSubpredicates: [basePredicate!, newPredicate])
            } else {
                return newPredicate
            }
        } else {
            return basePredicate
        }
    }
    
    func comicContainsSensitiveData(_ comics: Comic) -> Bool {
        var result = false
        
        guard let title = comics.title,
              let alt = comics.alt else {
            return result
        }
        
        for word in sensitiveWords {
            result = title.lowercased().contains(word) ||
                     alt.lowercased().contains(word)
            
            if result {
                break
            }
        }
        return result
    }
    
    func whatIfContainsSensitiveData(_ whatIf: WhatIf) -> Bool {
        var result = false
        
        guard let title = whatIf.title,
              let question = whatIf.question,
              let answer = whatIf.answer else {
            return result
        }
        
        for word in sensitiveWords {
            result = title.lowercased().contains(word) ||
                     question.lowercased().contains(word) ||
                     answer.lowercased().contains(word)
            
            if result {
                break
            }
        }
        return result
    }
}
