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
                } else {
                    ActivityIndicatorView(shouldAnimate: $viewModel.isBusy)
                }
            }
            .navigationBarTitle(Text(viewModel.comicTitle),
                                displayMode: .large)
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

