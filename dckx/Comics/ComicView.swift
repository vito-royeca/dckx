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
            .toolbar() {
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
//                    ComicListView()
            }
        }
            .environmentObject(viewModel)
    }
    
    var webView: some View {
        WebView(link: nil,
                html: viewModel.composeHTML(),
                baseURL: nil)
            .gesture(DragGesture(minimumDistance: 30, coordinateSpace: .local)
                .onEnded({ value in
                    if value.translation.width < 0 {
                        if viewModel.canDoNext {
                            Task {
                                do {
                                    try await viewModel.loadNext()
                                } catch {
                                    print(error)
                                }
                            }
                        }
                    }

                    if value.translation.width > 0 {
                        if viewModel.canDoPrevious {
                            Task {
                                do {
                                    try await viewModel.loadPrevious()
                                } catch {
                                    print(error)
                                }
                            }
                        }
                    }
                }))
    }

    var displayView: some View {
        VStack {
            let titleFont = UserDefaults.standard.bool(forKey: SettingsKey.comicsViewerUseSystemFont) ?
                Font.system(size: 24) : Font.custom("xkcd-Regular", size: 24)
            let textFont = UserDefaults.standard.bool(forKey: SettingsKey.comicsViewerUseSystemFont) ?
                Font.system(size: 16) : Font.custom("xkcd-Regular", size: 16)
            
            Text("\(viewModel.comicTitle)")
                .font(titleFont)
            HStack {
                Text("#\(viewModel.currentComic?.num ?? 0)")
                    .font(textFont)
                Spacer()
                Text(viewModel.currentComic?.displayDate ?? "")
                    .font(textFont)
            }
            Spacer()
            AsyncImage(url: viewModel.comicImageURL) { phase in
                switch phase {
                    case .empty:
                        ZStack {
                            Color.gray
                            ProgressView()
                        }
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    case .failure(let error):
                        Text(error.localizedDescription)
                    @unknown default:
                        EmptyView()
                }
            }
            Spacer()
            Text(viewModel.currentComic?.alt ?? "")
                .font(textFont)
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

