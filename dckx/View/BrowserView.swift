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
    
    var body: some View {
        VStack {
            BrowserTitleView(title: title)
            Spacer()
            WebView(link: link)
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

struct WebView: UIViewRepresentable {
    private let webView = WKWebView()
    var link: String

    init (link: String) {
        self.link = link
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        private var control: WebView

        init(_ control: WebView) {
            self.control = control
        }
    }
    
    func makeUIView(context: UIViewRepresentableContext<WebView>) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        
        if let url = URL(string: link) {
            self.webView.load(URLRequest(url: url))
        }
        return webView
    }
        
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WebView>) {
        
    }
    
    func makeCoordinator() -> WebView.Coordinator {
        Coordinator(self)
    }
}

