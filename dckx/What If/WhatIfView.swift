//
//  WhatIfView.swift
//  dckx
//
//  Created by Vito Royeca on 2/28/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI
import Combine
import WebKit

struct WhatIfView: View {
    @ObservedObject var fetcher = WhatIfFetcher()
    @State private var showingList = false
    
    var body: some View {
        NavigationView {
            if #available(iOS 14.0, *) {
                WebView(link: nil,
                        html: fetcher.composeHTML(),
                        baseURL: nil)
                .navigationBarTitle(Text(fetcher.currentWhatIf?.title ?? ""), displayMode: .automatic)
                .navigationBarItems(
                    leading: listButton,
                    trailing:
                        WhatIfToolBarView(fetcher: fetcher)
                )
                .toolbar {
                    NavigationToolbar(loadFirst: fetcher.loadFirst,
                                      loadPrevious: fetcher.loadPrevious,
                                      loadRandom: fetcher.loadRandom,
                                      loadNext: fetcher.loadNext,
                                      loadLast: fetcher.loadLast,
                                      canDoPrevious: fetcher.canDoPrevious,
                                      canDoNext: fetcher.canDoNext)
                }
            } else {
                Text("Unsupported iOS version")
            }
        }
    }
    
    var listButton: some View {
        Button(action: {
            self.showingList.toggle()
        }) {
            Image(systemName: "list.dash")
                .imageScale(.large)
//                .foregroundColor(.dckxBlue)
        }
        .sheet(isPresented: $showingList, content: {
            WhatIfListView(fetcher: self.fetcher)
        })
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
    @State private var showingShare = false
    
    var body: some View {
        HStack {
            Button(action: {
                self.fetcher.toggleIsFavorite()
            }) {
                Image(systemName: fetcher.currentWhatIf?.isFavorite ?? false ? "bookmark.fill" : "bookmark")
                    .imageScale(.large)
//                    .foregroundColor(.dckxBlue)
            }
            Spacer()
            
            Button(action: {
                self.showingShare.toggle()
            }) {
                Image(systemName: "square.and.arrow.up")
                    .imageScale(.large)
//                    .foregroundColor(.dckxBlue)
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
