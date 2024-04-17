//
//  WhatIfView.swift
//  dckx
//
//  Created by Vito Royeca on 2/28/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI
import SwiftData
import WebKit

struct WhatIfView: View {
    @State var viewModel: WhatIfViewModel
    @Binding var showingMenu: Bool
    @State private var showingSearch = false
    
    private let titleFont = UserDefaults.standard.bool(forKey: SettingsKey.comicsViewerUseSystemFont) ?
        Font.system(.largeTitle) : Font.dckxLargeTitleText
    private let textFont = UserDefaults.standard.bool(forKey: SettingsKey.comicsViewerUseSystemFont) ?
        Font.system(.body) : Font.dckxRegularText

    init(modelContext: ModelContext, showingMenu: Binding<Bool>) {
        let model = WhatIfViewModel(modelContext: modelContext)
        _viewModel = State(initialValue: model)
        _showingMenu = showingMenu
    }

    var body: some View {
        NavigationView {
//            VStack(alignment: .center) {
//                if !viewModel.isBusy {
//                    displayView
//                        .padding()
//                } else {
//                    ActivityIndicatorView(shouldAnimate: $viewModel.isBusy)
//                }
//            }
            WebView(link: nil,
                    html: viewModel.composeHTML(),
                    baseURL: nil)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    menuButton
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    searchButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    WhatIfToolbarView()
                }
                
                NavigationToolbar(delegate: viewModel)
            }
            .sheet(isPresented: $showingSearch) {
//                NavigationView {
//                    ComicListView(selectComicAction: select(comic:))
//                }
            }
        }
            .environmentObject(viewModel)
    }
    
    var displayView: some View {
        VStack {
            Text("\(viewModel.currentWhatIf?.title ?? "")")
                .font(titleFont)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Text("#\(viewModel.currentWhatIf?.num ?? 0)")
                    .font(textFont)
                Spacer()
                Text(viewModel.currentWhatIf?.displayDate ?? "")
                    .font(textFont)
            }
            
            Spacer()
            
            WebView(link: nil,
                    html: viewModel.composeHTML(),
                    baseURL: nil)
            
            Spacer()
        }
    }
    
    var menuButton: some View {
        Button(action: {
            withAnimation {
                showingMenu.toggle()
            }
        }) {
            Image(systemName: "line.horizontal.3")
                .imageScale(.large)
        }
            .disabled(viewModel.isBusy)
    }
    
    var searchButton: some View {
        Button(action: {
            withAnimation {
                showingSearch.toggle()
            }
        }) {
            Image(systemName: "magnifyingglass")
                .imageScale(.large)
        }
            .disabled(viewModel.isBusy)
    }
}

// MARK: - Previews

struct WhatIfView_Previews: PreviewProvider {
    @State static private var showingMenu = false
    
    static var previews: some View {
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) { deviceName in
            WhatIfView(modelContext: try! ModelContainer(for: WhatIfModel.self).mainContext,
                       showingMenu: $showingMenu)
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
    }
}

