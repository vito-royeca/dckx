//
//  NavigationToolbar.swift
//  dckx
//
//  Created by Vito Royeca on 2/29/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI

protocol NavigationToolbarDelegate: ObservableObject {
    var canDoPrevious: Bool { get }
    var canDoNext: Bool { get }
    func loadFirst() async throws
    func loadPrevious() async throws
    func loadRandom() async throws
    func loadNext() async throws
    func loadLast() async throws
    
    func dateToString(date: Date?) -> String
}

extension NavigationToolbarDelegate {
    func dateToString(date: Date?) -> String {
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
        
            return formatter.string(from: date)
        } else {
            return "2020-01-02"
        }
    }
}

struct NavigationToolbar: ToolbarContent  {
    var loadFirst: () async throws -> Void
    var loadPrevious: () async throws -> Void
    var loadRandom: () async throws -> Void
    var search: () -> Void
    var loadNext: () async throws -> Void
    var loadLast: () async throws -> Void

    @State var canDoPrevious: Bool
    @State var canDoNext: Bool
    @State var isBusy: Bool
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Button(action: {
                Task {
                    do {
                        try await loadFirst()
                    } catch {
                        print(error)
                    }
                }
            }) {
                Image(systemName: "backward.end")
                    .imageScale(.large)
            }
                .disabled(!self.canDoPrevious || isBusy)
        }
        ToolbarItem(placement: .bottomBar) {
            Spacer()
        }

        ToolbarItem(placement: .bottomBar) {
            Button(action: {
                Task {
                    do {
                        try await loadPrevious()
                    } catch {
                        print(error)
                    }
                }
            }) {
                Image(systemName: "arrowtriangle.backward")
                    .imageScale(.large)
            }
                .disabled(!self.canDoPrevious || isBusy)
        }
        ToolbarItem(placement: .bottomBar) {
            Spacer()
        }

        ToolbarItem(placement: .bottomBar) {
            Button(action: {
                Task {
                    do {
                        try await loadRandom()
                    } catch {
                        print(error)
                    }
                }
            }) {
                Image(systemName: "shuffle")
                    .imageScale(.large)
            }
            .disabled(isBusy)
        }

        ToolbarItem(placement: .bottomBar) {
            Button(action: {
                self.search()
            }) {
                Image(systemName: "magnifyingglass")
                    .imageScale(.large)
            }
                .disabled(isBusy)
        }
        ToolbarItem(placement: .bottomBar) {
            Spacer()
        }
        
        ToolbarItem(placement: .bottomBar) {
            Button(action: {
                Task {
                    do {
                        try await loadNext()
                    } catch {
                        print(error)
                    }
                }
            }) {
                Image(systemName: "arrowtriangle.forward")
                    .imageScale(.large)
            }
                .disabled(!self.canDoNext || isBusy)
        }
        ToolbarItem(placement: .bottomBar) {
            Spacer()
        }

        ToolbarItem(placement: .bottomBar) {
            Button(action: {
                Task {
                    do {
                        try await loadLast()
                    } catch {
                        print(error)
                    }
                }
            }) {
                Image(systemName: "forward.end")
                    .imageScale(.large)
            }
                .disabled(!self.canDoNext || isBusy)
        }
    }
}
