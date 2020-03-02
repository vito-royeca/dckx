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
    var title: String
    var link: String
    var baseURL: URL?

    var body: some View {
        VStack {
            BrowserTitleView(title: title)
            Spacer()
            WebView(link: link,
                    html: nil,
                    baseURL: baseURL)
        }
    }
}

struct BrowserView_Previews: PreviewProvider {
    static var previews: some View {
        BrowserView(title: "Main Page",
                    link:  "https://www.explainxkcd.com/wiki/index.php/Main_Page")
    }
}

struct BrowserTitleView: View {
    @Environment(\.presentationMode) var presentationMode
    var title: String

    var body: some View {
        HStack {
            Spacer()
            Text(title)
                .font(.custom("xkcd-Script-Regular", size: 20))
            Spacer()
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("X")
                    .customButton(isDisabled: false)
            }
        }
            .padding(5)
    }
}
