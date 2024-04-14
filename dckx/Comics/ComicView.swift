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
            .navigationBarItems(leading: menuButton,
                                trailing: ComicToolbarView())
            .toolbar() {
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
            Text("\(viewModel.comicTitle)")
                .font(.custom("xkcd", size: 24))
            HStack {
                Text("#\(viewModel.currentComic?.num ?? 0)")
                    .font(.custom("xkcd", size: 16))
                Spacer()
                Text(viewModel.currentComic?.displayDate ?? "")
                    .font(.custom("xkcd", size: 16))
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
                .font(.custom("xkcd", size: 16))
        }
    }
    
    var menuButton: some View {
        Button(action: {
            withAnimation {
                self.showingMenu.toggle()
            }
        }) {
            Image(systemName: "line.horizontal.3")
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

