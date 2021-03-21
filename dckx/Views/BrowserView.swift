//
//  BrowserView.swift
//  dckx
//
//  Created by Vito Royeca on 2/22/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI
import Combine
import WebKit

struct BrowserView: View {
    @Environment(\.presentationMode) var presentationMode
    var title: String
    var link: String
    var baseURL: URL?

    var body: some View {
        NavigationView {
            WebView(link: link,
                    html: nil,
                    baseURL: baseURL)
            .navigationBarTitle(Text(title), displayMode: .automatic)
            .navigationBarItems(
                trailing: closeButton
            )
        }
    }
    
    var closeButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "xmark")
                .imageScale(.large)
//                            .foregroundColor(.dckxBlue)
        }
    }
}

struct BrowserView_Previews: PreviewProvider {
    static var previews: some View {
        BrowserView(title: "Main Page",
                    link:  "https://www.explainxkcd.com/wiki/index.php/Main_Page")
    }
}
