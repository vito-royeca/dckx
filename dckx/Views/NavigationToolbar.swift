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
    var isBusy: Bool { get }
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
    var delegate: any NavigationToolbarDelegate
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Button(action: {
                Task {
                    do {
                        try await delegate.loadFirst()
                    } catch {
                        print(error)
                    }
                }
            }) {
                Image(systemName: "backward.end")
                    .imageScale(.large)
            }
            .disabled(!delegate.canDoPrevious || delegate.isBusy)
        }
        ToolbarItem(placement: .bottomBar) {
            Spacer()
        }

        ToolbarItem(placement: .bottomBar) {
            Button(action: {
                Task {
                    do {
                        try await delegate.loadPrevious()
                    } catch {
                        print(error)
                    }
                }
            }) {
                Image(systemName: "arrowtriangle.backward")
                    .imageScale(.large)
            }
            .disabled(!delegate.canDoPrevious || delegate.isBusy)
        }
        ToolbarItem(placement: .bottomBar) {
            Spacer()
        }

        ToolbarItem(placement: .bottomBar) {
            Button(action: {
                Task {
                    do {
                        try await delegate.loadRandom()
                    } catch {
                        print(error)
                    }
                }
            }) {
                Image(systemName: "shuffle")
                    .imageScale(.large)
            }
            .disabled(delegate.isBusy)
        }

        ToolbarItem(placement: .bottomBar) {
            Spacer()
        }
        
        ToolbarItem(placement: .bottomBar) {
            Button(action: {
                Task {
                    do {
                        try await delegate.loadNext()
                    } catch {
                        print(error)
                    }
                }
            }) {
                Image(systemName: "arrowtriangle.forward")
                    .imageScale(.large)
            }
            .disabled(!delegate.canDoNext || delegate.isBusy)
        }
        ToolbarItem(placement: .bottomBar) {
            Spacer()
        }

        ToolbarItem(placement: .bottomBar) {
            Button(action: {
                Task {
                    do {
                        try await delegate.loadLast()
                    } catch {
                        print(error)
                    }
                }
            }) {
                Image(systemName: "forward.end")
                    .imageScale(.large)
            }
            .disabled(!delegate.canDoNext || delegate.isBusy)
        }
    }
}
