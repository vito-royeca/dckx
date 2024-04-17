//
//  WhatIfViewModel+HTML.swift
//  dckx
//
//  Created by Vito Royeca on 4/20/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

import Foundation

extension WhatIfViewModel {
    func composeHTML() -> String {
        guard let whatIf = currentWhatIf else {
            return ""
        }

        let css = UserDefaults.standard.bool(forKey: SettingsKey.whatIfViewerUseSystemFont) ? "system.css" : "dckx.css"
        var head = "<head><title>\(whatIf.title)</title>"
        head += "<script type='text/javascript' src='jquery-3.2.1.min.js'></script>"
        head += "<link href='\(css)' rel='stylesheet'>"
        head += "<link href='whatif.css' rel='stylesheet'></head>"
        
        var html = "<html>\(head)<body><table width='100%'>"
        html += "<tr><td width='100%' colspan='2' class='title'>\(whatIf.title)</td></tr>"
        html += "<tr><td width='50%' class='numdate'><p align='left'>#\(whatIf.num)</p></td><td width='50%' class='numdate'><p align='right'>\(whatIf.displayDate)</p></td></tr>"
        html += "<tr><td width='100%' colspan='2' class='question'>\(whatIf.question)</td></tr>"
        html += "<tr><td width='100%' colspan='2' class='questioner'><p>- \(whatIf.questioner)</p></td></tr>"
        html += "<tr><td width='100%' colspan='2' class='answer'>\(whatIf.answer)</td></tr>"
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
