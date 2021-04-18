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
    @Binding var showingMenu: Bool
    @State private var showingList = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .center) {
                WebView(link: nil,
                        html: fetcher.composeHTML(),
                        baseURL: nil)
                ActivityIndicatorView(shouldAnimate: $fetcher.isBusy)
            }
                .navigationBarTitle(Text(fetcher.currentWhatIf?.title ?? ""), displayMode: .large)
                .navigationBarItems(
                    leading: menuButton,
                    trailing: WhatIfToolBarView(fetcher: fetcher))
                .toolbar {
                    NavigationToolbar(loadFirst: fetcher.loadFirst,
                                      loadPrevious: fetcher.loadPrevious,
                                      loadRandom: fetcher.loadRandom,
                                      search: {
                                          self.showingList.toggle()
                                      },
                                      loadNext: fetcher.loadNext,
                                      loadLast: fetcher.loadLast,
                                      canDoPrevious: fetcher.canDoPrevious,
                                      canDoNext: fetcher.canDoNext,
                                      isBusy: fetcher.isBusy)
                }
                .fullScreenCover(isPresented: $showingList, content: {
                    WhatIfListView()
                })
        }
            .environmentObject(fetcher)
    }
    
    var menuButton: some View {
        Button(action: {
//            self.showingList.toggle()
            withAnimation {
                self.showingMenu.toggle()
            }
        }) {
            Image(systemName: "line.horizontal.3")
                .imageScale(.large)
        }
//            .disabled(fetcher.isBusy)
//            .fullScreenCover(isPresented: $showingList, content: {
//                WhatIfListView()
//            })
    }
}

struct WhatIfView_Previews: PreviewProvider {
    @State static private var showingMenu = false
    
    static var previews: some View {
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) { deviceName in
            WhatIfView(showingMenu: $showingMenu)
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
            }
                .disabled(fetcher.isBusy)
            Spacer()
            
            Button(action: {
                self.showingShare.toggle()
            }) {
                Image(systemName: "square.and.arrow.up")
                    .imageScale(.large)
            }
                .disabled(fetcher.isBusy)
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
