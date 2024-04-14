//
//  ComicToolbarView.swift
//  dckx
//
//  Created by Vito Royeca on 4/14/24.
//  Copyright © 2024 Vito Royeca. All rights reserved.
//

import SwiftUI

struct ComicToolbarView: View {
    @EnvironmentObject var viewModel: ComicViewModel
    @State private var showingBrowser = false
    @State private var showingShare = false
    
    var body: some View {
        HStack {
            Button(action: {
                viewModel.toggle(isFavoriteEnabled: viewModel.currentComic?.isFavorite ?? false)
            }) {
                Image(systemName: viewModel.currentComic?.isFavorite ?? false ? "bookmark.fill" : "bookmark")
                    .imageScale(.large)
            }
                .disabled(viewModel.isBusy)
            Spacer()
            
            if UserDefaults.standard.bool(forKey: SettingsKey.comicsExplanationUseSafariBrowser) {
                Button(action: {
                    self.showingBrowser.toggle()
                }) {
                    Image(systemName: "questionmark.circle")
                        .imageScale(.large)
                }
                    .disabled(viewModel.isBusy)
                    // comment out if running in XCTests
//                    .safariView(isPresented: $showingBrowser) {
//                        SafariView(
//                            url: URL(string: XkcdAPI.sharedInstance.explainURL(of: self.fetcher.currentComic!))!,
//                            configuration: SafariView.Configuration(
//                                entersReaderIfAvailable: true,
//                                barCollapsingEnabled: true
//                            )
//                        )
//                        .preferredBarAccentColor(.clear)
//                        .preferredControlAccentColor(.dckxBlue)
//                        .dismissButtonStyle(.close)
//                    }
            } else {
                Button(action: {
                    self.showingBrowser.toggle()
                }) {
                    Image(systemName: "questionmark.circle")
                        .imageScale(.large)
                }
                    .disabled(viewModel.isBusy)
                    .sheet(isPresented: $showingBrowser, content: {
                        viewModel.currentComic.map({
                            BrowserView(title: "Explanation",
                                        link: $0.explainURL,
                                        baseURL: nil/*URL(string: "https://xkcd.com/")*/)
                        })
                    })
            }
            Spacer()
            
            Button(action: {
                self.showingShare.toggle()
            }) {
                Image(systemName: "square.and.arrow.up")
                    .imageScale(.large)
            }
                .disabled(viewModel.isBusy)
                .sheet(isPresented: $showingShare) {
                    ShareSheetView(activityItems: self.activityItems(),
                                   applicationActivities: [])
                }
        }
    }
    
    func activityItems() -> [Any] {
        let item = ComicItemSource(comic: viewModel.currentComic)
        
        return [item, "\(item.title())\n\(item.author())"]
    }
}

