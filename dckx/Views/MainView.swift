//
//  MainView.swift
//  dckx
//
//  Created by Vito Royeca on 2/28/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @StateObject var settings = Settings()
    
    var body: some View {
//        TabView{
//            ComicView()
//                .tabItem({
//                    Image(systemName: "photo.on.rectangle.angled")
//                })
//            WhatIfView()
//                .tabItem({
//                    Image(systemName: "questionmark.diamond")
//                })
//            SettingsView()
//                .tabItem({
//                    Image(systemName: "gear")
//                })
//        }
//        .environmentObject(settings)
        HamburgerView()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
