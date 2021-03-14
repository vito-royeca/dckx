//
//  WhatIfView.swift
//  dckx
//
//  Created by Vito Royeca on 2/28/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI
import Combine
import MessageUI
import WebKit

struct WhatIfView: View {
    @ObservedObject var fetcher = WhatIfFetcher()
    @State private var showingList = false
    
    var body: some View {
        NavigationView {
            VStack {
                // WebView
                WebView(link: nil,
                        html: fetcher.composeHTML(),
                        baseURL: nil)
                
                // Navigation
                NavigationBarView(navigator: fetcher)
            }
            .padding()
            .navigationBarTitle(fetcher.currentWhatIf?.title ?? "")
            .navigationBarItems(
                leading: Button(action: {
                    self.showingList.toggle()
                }) {
                    Image(systemName: "list.dash")
                        .imageScale(.large)
                        .foregroundColor(.buttonColor)
                }
                    .sheet(isPresented: $showingList, content: {
                        WhatIfListView(fetcher: self.fetcher)
                    }),
                
                trailing:
                WhatIfToolBarView(fetcher: fetcher)
            )
        }
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
    
    var body: some View {
        HStack {
            Button(action: {
                self.fetcher.toggleIsFavorite()
            }) {
                Image(systemName: fetcher.currentWhatIf?.isFavorite ?? false ? "bookmark.fill" : "bookmark")
                    .imageScale(.large)
                    .foregroundColor(.buttonColor)
            }
            Spacer()
            
            Button(action: {
                self.showingMail.toggle()
            }) {
                Image(systemName: "mail")
                    .imageScale(.large)
                    .foregroundColor(.buttonColor)
            }
                .sheet(isPresented: $showingMail, content: {
                    MailView(result: self.$mailResult)
                })
            Spacer()
            
            Button(action: {
                self.showingShare.toggle()
            }) {
                Image(systemName: "square.and.arrow.up")
                    .imageScale(.large)
                    .foregroundColor(.buttonColor)
            }
                .sheet(isPresented: $showingShare) {
                    ShareSheetView(activityItems: self.activityItems(),
                                   applicationActivities: nil)
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
