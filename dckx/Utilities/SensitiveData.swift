//
//  SensitiveData.swift
//  dckx
//
//  Created by Vito Royeca on 4/20/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

import Foundation

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
