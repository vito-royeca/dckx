//
//  WhatIfView.swift
//  dckx
//
//  Created by Vito Royeca on 2/28/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI
import MessageUI
import WebKit

struct WhatIfView: View {
    @ObservedObject var fetcher = WhatIfFetcher()
    
    var body: some View {
        VStack {
            // Title
            ComicTitleView(title: fetcher.currentWhatIf?.title ?? "Title")
            
            // Metadata
            WhatIfMetaDataView(num: fetcher.currentWhatIf?.num ?? 1,
                               date: fetcher.currentWhatIf?.date)

            // Toolbar
            Divider()
            WhatIfToolBarView(fetcher: fetcher)
            
            Spacer()
            
            // WebView
            WebView(link: nil,
                    html: composeHTML(),
                    baseURL: baseURL()/*URL(string: "https://what-if.xkcd.com")*/)
            
            
            Spacer()
            
            // Navigation
            WhatIfNavigationBarView(fetcher: fetcher)
        }
            .padding()
    }
    
    func composeHTML() -> String {
        let head =
        """
            <head>
                <link href="xkcd.css" rel="stylesheet">
            </head>
        """

        var html = "<html>\(head)"
        html += "<p class='question'>\(fetcher.currentWhatIf?.question ?? "")"
        html += "<p class='questioner' align='right'>- \(fetcher.currentWhatIf?.questioner ?? "")"
        html += "<p/> &nbsp;"
        html += "\(fetcher.currentWhatIf?.answer ?? "")"
        html += "</html>"
        
        return html
    }
    
    func baseURL() -> URL? {
        let bundlePath = Bundle.main.bundlePath
        let url = URL(fileURLWithPath: bundlePath)
        return url
    }
}

struct WhatIfView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) { deviceName in
            WhatIfView()
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
    }
}


struct WhatIfTitleView: View {
    var title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.custom("xkcd-Script-Regular", size: 30))
        }
            .padding(5)
    }
}

struct WhatIfMetaDataView: View {
    var num: Int32
    var date: Date?
    
    var body: some View {
        HStack {
            Text("#\(String(num))")
                .font(.custom("xkcd-Script-Regular", size: 15))
            Spacer()
            Text(dateString())
                .font(.custom("xkcd-Script-Regular", size: 15))
        }
    }
    
    func dateString() -> String {
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
        
            return formatter.string(from: date)
        } else {
            return "2020-01-02"
        }
    }
}

struct WhatIfToolBarView: View {
    @ObservedObject var fetcher: WhatIfFetcher
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil
    @State private var showingMail = false
    @State private var showingShare = false
    @State private var showingList = false
    
    var body: some View {
        HStack {
            Button(action: {
                self.fetcher.toggleIsFavorite()
            }) {
                Text("Bookmark \(fetcher.currentWhatIf?.isFavorite ?? false ? "-" : "+")")
                    .customButton(isDisabled: false)
            }
            Spacer()
            
            Button(action: {
                self.showingMail.toggle()
            }) {
                Text("Ask")
                    .customButton(isDisabled: false)
            }
                .sheet(isPresented: $showingMail, content: {
                    MailView(result: self.$mailResult)
                })
            Spacer()
            
            Button(action: {
                self.fetcher.toggleIsFavorite()
            }) {
                Text("Share")
                    .customButton(isDisabled: false)
            }
            Spacer()
            
            Button(action: {
                self.fetcher.toggleIsFavorite()
            }) {
                Text("List")
                    .customButton(isDisabled: false)
            }
        }
    }
}

struct WhatIfNavigationBarView: View {
    @ObservedObject var fetcher: WhatIfFetcher

    var body: some View {
        HStack {
            Button(action: {
                self.fetcher.loadFirstWhatIf()
            }) {
                Text("|<")
                    .customButton(isDisabled: !fetcher.canDoPrevious())
            }
            .disabled(!fetcher.canDoPrevious())
            Spacer()
            
            Button(action: {
                self.fetcher.loadPreviousWhatIf()
            }) {
                Text("<Prev")
                    .customButton(isDisabled: !fetcher.canDoPrevious())
            }
            .disabled(!fetcher.canDoPrevious())
            Spacer()
            
            Button(action: {
                self.fetcher.loadRandomWhatIf()
            }) {
                Text("Random")
                    .customButton(isDisabled: false)
            }
            Spacer()
            
            Button(action: {
                self.fetcher.loadNextWhatIf()
            }) {
                Text("Next>")
                    .customButton(isDisabled: !fetcher.canDoNext())
            }
            .disabled(!fetcher.canDoNext())
            Spacer()
            
            Button(action: {
                self.fetcher.loadLastWhatIf()
            }) {
                Text(">|")
                    .customButton(isDisabled: !fetcher.canDoNext())
            }
            .disabled(!fetcher.canDoNext())
            
        }
    }
}
