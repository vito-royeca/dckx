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
                    html: fetcher.composeHTML(),
                    baseURL: nil)
            
            Spacer()
            
            // Navigation
            WhatIfNavigationBarView(fetcher: fetcher)
        }
            .padding()
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
                Text("BOOKMARK \(fetcher.currentWhatIf?.isFavorite ?? false ? "-" : "+")")
                    .customButton(isDisabled: false)
            }
            Spacer()
            
            Button(action: {
                self.showingMail.toggle()
            }) {
                Text("ASK")
                    .customButton(isDisabled: false)
            }
                .sheet(isPresented: $showingMail, content: {
                    MailView(result: self.$mailResult)
                })
            Spacer()
            
            Button(action: {
                self.showingShare.toggle()
            }) {
                Text("SHARE")
                    .customButton(isDisabled: false)
            }
                .sheet(isPresented: $showingShare) {
                    ShareSheetView(activityItems: self.activityItems(),
                                   applicationActivities: nil)
                }
            Spacer()
            
            Button(action: {
                self.fetcher.toggleIsFavorite()
            }) {
                Text("LIST")
                    .customButton(isDisabled: false)
            }
        }
    }
    
    func activityItems() -> [Any] {
        var items = [Any]()
        
        if let whatIf = fetcher.currentWhatIf,
            let link = whatIf.link,
            let url = URL(string: link) {
            items.append(url)
        }
        
        return items
    }
}

struct WhatIfNavigationBarView: View {
    @ObservedObject var fetcher: WhatIfFetcher

    var body: some View {
        HStack {
            Button(action: {
                self.fetcher.loadFirst()
            }) {
                Text("|<")
                    .customButton(isDisabled: !fetcher.canDoPrevious())
            }
            .disabled(!fetcher.canDoPrevious())
            Spacer()
            
            Button(action: {
                self.fetcher.loadPrevious()
            }) {
                Text("<PREV")
                    .customButton(isDisabled: !fetcher.canDoPrevious())
            }
            .disabled(!fetcher.canDoPrevious())
            Spacer()
            
            Button(action: {
                self.fetcher.loadRandom()
            }) {
                Text("RANDOM")
                    .customButton(isDisabled: false)
            }
            Spacer()
            
            Button(action: {
                self.fetcher.loadNext()
            }) {
                Text("NEXT>")
                    .customButton(isDisabled: !fetcher.canDoNext())
            }
            .disabled(!fetcher.canDoNext())
            Spacer()
            
            Button(action: {
                self.fetcher.loadLast()
            }) {
                Text(">|")
                    .customButton(isDisabled: !fetcher.canDoNext())
            }
            .disabled(!fetcher.canDoNext())
            
        }
    }
}
