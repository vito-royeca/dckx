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
    
    @AppStorage(SettingsKey.useSystemFont) private var useSystemFont = false
    @State private var showingSearch = false
    
    init(modelContext: ModelContext, showingMenu: Binding<Bool>) {
        let model = WhatIfViewModel(modelContext: modelContext)
        _viewModel = State(initialValue: model)
        _showingMenu = showingMenu
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                if !viewModel.isBusy {
                    displayView
                        .padding()
                } else {
                    ActivityIndicatorView(shouldAnimate: $viewModel.isBusy)
                }
            }
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
                NavigationView {
                    WhatIfListView(selectWhatIfAction: select(whatIf:))
                }
            }
        }
            .environmentObject(viewModel)
    }
    
    var displayView: some View {
        WebView(link: nil,
                html: viewModel.composeHTML(useSystemFont: useSystemFont),
                baseURL: nil)
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

extension WhatIfView {
    func select(whatIf: WhatIfModel) {
        Task {
            do {
                try await viewModel.load(num: whatIf.num)
            } catch {
                print(error)
            }
        }
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

