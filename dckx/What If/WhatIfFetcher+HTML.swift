//
//  WhatIfFetcher+HTML.swift
//  dckx
//
//  Created by Vito Royeca on 4/20/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

import Foundation

extension WhatIfFetcher {
    func composeHTML() -> String {
        guard let whatIf = currentWhatIf,
              let title = whatIf.title,
            let question = whatIf.question,
            let questioner = whatIf.questioner,
            let answer = whatIf.answer else {
            return ""
        }
        let css = UserDefaults.standard.bool(forKey: SettingsKey.whatIfViewerUseSystemFont) ? "system.css" : "dckx.css"
        var head = "<head><title>\(title)</title>"
        head += "<script type='text/javascript' src='jquery-3.2.1.min.js'></script>"
        head += "<link href='\(css)' rel='stylesheet'>"
        head += "<link href='whatif.css' rel='stylesheet'></head>"
        
        var html = "<html>\(head)<body><table width='100%'>"
        html += "<tr><td width='50%' class='numdate'><p align='left'>#\(whatIf.num)</p></td><td width='50%' class='numdate'><p align='right'>\(dateToString(date: whatIf.date))</p></td></tr>"
        html += "<tr><td width='100%' colspan='2' class='question'>\(question)</td></tr>"
        html += "<tr><td width='100%' colspan='2' class='questioner'><p align='right'>- \(questioner)</p></td></tr>"
        html += "<tr><td width='100%' colspan='2'><p/> &nbsp;</td></tr>"
        html += "<tr><td width='100%' colspan='2' class='answer'>\(answer)</td></tr>"
        html += "</table>"
        html += """
            <script>
                jQuery.noConflict();
                jQuery(function() {
                  jQuery(".refbody").hide();
                  jQuery(".refnum").click(function(event) {
                    jQuery(this.nextSibling).toggle();
                    event.stopPropagation();
                  });
                  jQuery("body").click(function(event) {
                    jQuery(".refbody").hide();
                  });
                });
            </script>
            """
        html += "</body></html>"
        
        return html
    }
}
