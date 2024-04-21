//
//  ComicPanelsModel.swift
//  dckx
//
//  Created by Vito Royeca on 4/20/24.
//  Copyright © 2024 Vito Royeca. All rights reserved.
//

import Foundation

class ComicPanelsModel: Codable, Identifiable {
    var filename: String
    var numbering: String
    var width: Int
    var height: Int
    var panels: [PanelModel]
    
    init() {
        filename = ""
        numbering = ""
        width = 0
        height = 0
        panels = []
    }
    
    init(using dictionary: [AnyHashable: Any]) {
        if let filename = dictionary["filename"] as? String {
            self.filename = filename
        } else {
            filename = ""
        }
        
        if let numbering = dictionary["numbering"] as? String {
            self.numbering = numbering
        } else {
            numbering = ""
        }
        
        if let size = dictionary["size"] as? [Int],
           let width = size.first,
           let height = size.last {
            self.width = width
            self.height = height
        } else {
            width = 0
            height = 0
        }
        
        panels = []
        if let array = dictionary["panels"] as? [[AnyHashable: Any]] {
            for dict in array {
                if let rect = dict["rect"] as? [Int],
                   let filename = dict["filename"] as? String {
                    let panel = PanelModel(rect: rect,
                                           filename: filename)
                    panels.append(panel)
                }
                
            }
        }
    }
    
    var id: String {
        get {
            filename
        }
    }

    var filenameLastPath: String {
        get {
            filename.components(separatedBy: "/").last ?? ""
        }
    }
}

class PanelModel: Codable, Identifiable {
    var rect: [Int]
    var filename: String
    
    init(rect: [Int],
         filename: String) {
        self.rect = rect
        self.filename = filename
    }
    
    var id: String {
        get {
            filename
        }
    }
}
