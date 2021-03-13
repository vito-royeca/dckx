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
            TitleView(title: fetcher.currentWhatIf?.title ?? "",
                      leftTitle: "\(fetcher.currentWhatIf?.num ?? 1)",
                      rightTitle: fetcher.dateToString(date: fetcher.currentWhatIf?.date))

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
            NavigationBarView(navigator: fetcher,
                              resetAction: nil)
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
                self.showingList.toggle()
            }) {
                Text("LIST")
                    .customButton(isDisabled: false)
            }
                .sheet(isPresented: $showingList, content: {
                    WhatIfListView(fetcher: self.fetcher)
                })
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
