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
    @StateObject var settings = Settings()
    @State var mainView: HMainView = .comics
    @State var showingMenu = false
    var modelContext: ModelContext
    
    var body: some View {
        contentView
            .environmentObject(settings)
    }
    
    var contentView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                switch mainView {
                case .comics:
                    ComicView(modelContext: modelContext,
                              showingMenu: $showingMenu)
                case .whatIfs:
                    //                    WhatIfView(showingMenu: $showingMenu)
                    Text("What Ifs")
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
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Image(uiImage: UIImage(named: "logo")!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70, height: 70)
                    .cornerRadius(5)
                
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
                        .foregroundColor(.gray)
                        .imageScale(.large)
                    Text("Comics")
                        .foregroundColor(.gray)
                        .font(Font.dckxRegularText)
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
                        .foregroundColor(.gray)
                        .imageScale(.large)
                    Text("What Ifs")
                        .foregroundColor(.gray)
                        .font(Font.dckxRegularText)
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
                        .foregroundColor(.gray)
                        .imageScale(.large)
                    Text("Settings")
                        .foregroundColor(.gray)
                        .font(Font.dckxRegularText)
                }
            }
                .padding(.top, 30)
            
            Spacer()
        }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(red: 32/255, green: 32/255, blue: 32/255))
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
