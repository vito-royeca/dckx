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
    func loadFirst()
    func loadPrevious()
    func loadRandom()
    func loadNext()
    func loadLast()
    
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
    var loadFirst: () -> Void
    var loadPrevious: () -> Void
    var loadRandom: () -> Void
    var search: () -> Void
    var loadNext: () -> Void
    var loadLast: () -> Void
    @State var canDoPrevious: Bool
    @State var canDoNext: Bool
    @State var isBusy: Bool
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Button(action: {
                self.loadFirst()
            }) {
                Image(systemName: "backward.end")
//                    .imageScale(.large)
            }
                .disabled(!self.canDoPrevious || isBusy)
        }
        ToolbarItem(placement: .bottomBar) {
            Spacer()
        }

        ToolbarItem(placement: .bottomBar) {
            Button(action: {
                self.loadPrevious()
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
                self.loadRandom()
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
                self.loadNext()
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
                self.loadLast()
            }) {
                Image(systemName: "forward.end")
                    .imageScale(.large)
            }
                .disabled(!self.canDoNext || isBusy)
        }
    }
}
