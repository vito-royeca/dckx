//
//  WhatIfView.swift
//  dckx
//
//  Created by Vito Royeca on 2/28/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI
import WebKit

struct WhatIfView: View {
    @ObservedObject var fetcher = WhatIfFetcher()
    
    var body: some View {
        VStack {
            Text(fetcher.currentWhatIf?.title ?? "Title")
                .font(.custom("xkcd-Script-Regular", size: 30))
            Text(fetcher.currentWhatIf?.question ?? "Question")
                .font(.custom("xkcd-Script-Regular", size: 15))
            
            Text(fetcher.currentWhatIf?.questioner ?? "Questioner")
                .font(.custom("xkcd-Script-Regular", size: 15))
            
            Spacer()
            
            WebView(link: nil,
                    html: fetcher.currentWhatIf?.answer,
                    baseURL: URL(string: "https://what-if.xkcd.com"))
            
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
