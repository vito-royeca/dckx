//
//  ComicViewModel+HTML.swift
//  dckx
//
//  Created by Vito Royeca on 4/20/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

import Foundation
import SDWebImage

extension ComicViewModel {
    func composeHTML() -> String {
        guard let comic = currentComic,
            let cachePath = SDImageCache.shared.cachePath(forKey: comic.img)
            // comment out if running in XCTests
            /*let splitComics = OpenCVWrapper.splitComics(cachePath, minimumPanelSizeRatio: 1/15)*/ else {
            return "composeHTML failed"
        }
        
        var comicsJson = "[{"
        // comment out if running in XCTests
//        for (k,v) in splitComics {
//            comicsJson.append("\"\(k)\": ")
//            if let _ = v as? String {
//                comicsJson.append("\"\(v)\",")
//            } else {
//                comicsJson.append("\(v),")
//            }
//        }
        comicsJson = comicsJson.hasSuffix(",") ? String(comicsJson.dropLast()) : comicsJson
        comicsJson += "}]"
        comicsJson = comicsJson.replacingOccurrences(of: "(", with: "[")
        comicsJson = comicsJson.replacingOccurrences(of: ")", with: "]")
        comicsJson = comicsJson.replacingOccurrences(of: "\n", with: "")

        let css = UserDefaults.standard.bool(forKey: SettingsKey.comicsViewerUseSystemFont) ?
            "system.css" : "dckx.css"
        var head = "<head><title>\(comic.title)</title>"
        head += "<meta charset='utf-8'>"
        head += "<meta name='viewport' content='width=device-width, initial-scale=1'>"
        head += "<script type='text/javascript' src='jquery-3.2.1.min.js'></script>"
        head += "<script type='text/javascript' src='reader.js'></script>"
        head += "<link rel='stylesheet' media='all' href='\(css)' />"
        head += "<style type='text/css'> "
        head += " .sidebyside { display: flex; justify-content: space-around; }"
        head += " .sidebyside > div { width: 45%; }"
        head += " .version { text-align: center; }"
        head += " .kumiko-reader { height: 90vh; }"
        head += " .kumiko-reader.fullpage { height: 100%; width: 100%; }"
        head += "</style></head>"

        let altText = "\(comic.alt)"
            .replacingOccurrences(of: "'", with: "\\x27")
            .replacingOccurrences(of: "\"", with: "\\x22")
        var reader = "<div id='reader' class='kumiko-reader fullpage'></div>"
        reader += "<script type='text/javascript'>"
        reader += " var reader = new Reader({"
        reader += "  container: $('#reader'),"
        reader += "  comicsJson: \(comicsJson),"
        reader += "  imageSrc: '\(cachePath)',"
        reader += "  controls: true,"
        reader += "  num: '#\(comic.num)',"
        reader += "  date: '\(dateToString(date: comic.date))&nbsp;',"
        reader += "  altText: '\(altText)'"
        reader += " });"
        reader += " reader.start();"
        reader += "</script>"

        var html = "<!DOCTYPE html><html>\(head)<body>"

        html += "\(reader)"
        html += "</body></html>"
        
        return html
    }
}
