//
//  ComicView.swift
//  dckx
//
//  Created by Vito Royeca on 2/13/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI
import SwiftData
import BetterSafariView

struct ComicView: View {
    @State var viewModel: ComicViewModel
    @Binding var showingMenu: Bool
    
    @AppStorage(SettingsKey.useSystemFont) private var useSystemFont = false
    @State private var showingSearch = false
    
    init(modelContext: ModelContext, showingMenu: Binding<Bool>) {
        let model = ComicViewModel(modelContext: modelContext)
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
                    ComicToolbarView()
                }
                
                NavigationToolbar(delegate: viewModel)
            }
            .sheet(isPresented: $showingSearch) {
                NavigationView {
                    ComicListView(selectComicAction: select(comic:))
                }
            }
        }
            .environmentObject(viewModel)
    }
    
    var displayView: some View {
        VStack {
            let largeFont = useSystemFont ?
                Font.largeTitle : Font.dckxLargeTitleText
            let regularFont = useSystemFont ?
                Font.system(.body) : Font.dckxRegularText
            
            Text("\(viewModel.comicTitle)")
                .font(largeFont)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Text("#\(viewModel.currentComic?.num ?? 0)")
                    .font(regularFont)
                Spacer()
                Text(viewModel.currentComic?.displayDate ?? "")
                    .font(regularFont)
            }
            
            Spacer()
            
            InteractiveImageView(url: viewModel.currentComic?.imageURL,
                                 reloadAction: viewModel.reloadComic)
            
            Spacer()
            
            Text(viewModel.currentComic?.alt ?? "")
                .font(regularFont)
                .fixedSize(horizontal: false, vertical: true)
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

extension ComicView {
    func select(comic: ComicModel) {
        Task {
            do {
                try await viewModel.load(num: comic.num)
            } catch {
                print(error)
            }
        }
    }
}

// MARK: - Previews

struct ComicView_Previews: PreviewProvider {
    @State static private var showingMenu = false
    
    static var previews: some View {
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) { deviceName in
            ComicView(modelContext: try! ModelContainer(for: ComicModel.self).mainContext,
                      showingMenu: $showingMenu)
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
    }
}

