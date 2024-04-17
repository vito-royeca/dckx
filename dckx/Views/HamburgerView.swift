//
//  HamburgerView.swift
//  dckx
//
//  Created by Vito Royeca on 4/18/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

import SwiftUI
import SwiftData
//import SwiftRater

enum HMainView {
    case comics, whatIfs, settings
}

struct HamburgerView: View {
    @State var mainView: HMainView = .comics
    @State var showingMenu = false
    var modelContext: ModelContext
    
    var body: some View {
        contentView
    }
    
    var contentView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                switch mainView {
                case .comics:
                    ComicView(modelContext: modelContext,
                              showingMenu: $showingMenu)
                case .whatIfs:
                    WhatIfView(modelContext: modelContext,
                               showingMenu: $showingMenu)
                case .settings:
                    SettingsView(showingMenu: $showingMenu)
                }
                
                if self.showingMenu {
                    HMenuView(mainView: $mainView,
                              showingMenu: $showingMenu)
                    .frame(width: geometry.size.width - geometry.size.width/3)
                    .transition(.move(edge: .leading))
                }
            }
        }
    }

}

#Preview {
    HamburgerView(modelContext: try! ModelContainer(for: ComicModel.self).mainContext)
}

// MARK: - HMenuView

struct HMenuView: View {
    @Binding var mainView: HMainView
    @Binding var showingMenu: Bool
    
    @AppStorage(SettingsKey.useSystemFont) private var useSystemFont = false
    
    var body: some View {
        VStack(alignment: .leading) {
            let regularFont = useSystemFont ? Font.system(.body) : Font.dckxRegularText
            
            HStack {
                Spacer()
                Image(uiImage: UIImage(named: "logo")!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70, height: 70)
                Spacer()
            }
                .padding(.top, 30)
            
            HStack {
                Button(action: {
                    withAnimation {
                        self.mainView = .comics
                        self.showingMenu.toggle()
                    }
                }) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .foregroundColor(.white)
                        .imageScale(.large)
                    Text("xkcd")
                        .foregroundColor(.white)
                        .font(regularFont)
                    }
                }
                    .padding(.top, 30)
            
            HStack {
                Button(action: {
                    withAnimation {
                        self.mainView = .whatIfs
                        self.showingMenu.toggle()
                    }
                }) {
                    Image(systemName: "questionmark.diamond")
                        .foregroundColor(.white)
                        .imageScale(.large)
                    Text("What If?")
                        .foregroundColor(.white)
                        .font(regularFont)
                }
            }
                .padding(.top, 30)
            
            HStack {
                Button(action: {
                    withAnimation {
                        self.mainView = .settings
                        self.showingMenu.toggle()
                    }
                }) {
                    Image(systemName: "gear")
                        .foregroundColor(.white)
                        .imageScale(.large)
                    Text("Settings")
                        .foregroundColor(.white)
                        .font(regularFont)
                }
            }
                .padding(.top, 30)
            
            Spacer()
        }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.backgroundColor)
            .edgesIgnoringSafeArea(.all)
            .gesture(DragGesture(minimumDistance: 30, coordinateSpace: .local)
                .onEnded({ value in
                    showingMenu.toggle()
                }))
        .onAppear {
//            SwiftRater.check()
        }
    }
}
