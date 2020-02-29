//
//  MainView.swift
//  dckx
//
//  Created by Vito Royeca on 2/28/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView{
            ComicView()
                .tabItem({
                    Text("Comics")
                })
            WhatIfView()
                .tabItem({
                    Text("What If?")
                })
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
