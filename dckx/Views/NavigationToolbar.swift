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
    var loadNext: () -> Void
    var loadLast: () -> Void
    @State var canDoPrevious: Bool
    @State var canDoNext: Bool
    
    @available(iOS 14.0, *)
    var body: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Button(action: {
                self.loadFirst()
            }) {
                Image(systemName: "backward.end")
                    .imageScale(.large)
//                    .foregroundColor(.buttonColor)
            }
            .disabled(!self.canDoPrevious)
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
//                    .foregroundColor(.buttonColor)
            }
            .disabled(!self.canDoPrevious)
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
//                    .foregroundColor(.buttonColor)
            }
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
//                    .foregroundColor(.buttonColor)
            }
            .disabled(!self.canDoNext)
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
//                    .foregroundColor(.buttonColor)
            }
            .disabled(!self.canDoNext)
        }
        
//        ToolbarItem(placement: .bottomBar) {
//            Button(action: {
//                self.delegate.loadFirst()
//            }) {
//                Image(systemName: "backward.end")
//                    .imageScale(.large)
////                    .foregroundColor(.buttonColor)
//            }
//            .disabled(!self.delegate.canDoPrevious)
//        }
//        ToolbarItem(placement: .bottomBar) {
//            Spacer()
//        }
//
//        ToolbarItem(placement: .bottomBar) {
//            Button(action: {
//                self.delegate.loadPrevious()
//            }) {
//                Image(systemName: "arrowtriangle.backward")
//                    .imageScale(.large)
////                    .foregroundColor(.buttonColor)
//            }
//            .disabled(!self.delegate.canDoPrevious)
//        }
//        ToolbarItem(placement: .bottomBar) {
//            Spacer()
//        }
//
//        ToolbarItem(placement: .bottomBar) {
//            Button(action: {
//                self.delegate.loadRandom()
//            }) {
//                Image(systemName: "shuffle")
//                    .imageScale(.large)
////                    .foregroundColor(.buttonColor)
//            }
//        }
//        ToolbarItem(placement: .bottomBar) {
//            Spacer()
//        }
//
//        ToolbarItem(placement: .bottomBar) {
//            Button(action: {
//                self.delegate.loadNext()
//            }) {
//                Image(systemName: "arrowtriangle.forward")
//                    .imageScale(.large)
////                    .foregroundColor(.buttonColor)
//            }
//            .disabled(!self.delegate.canDoNext)
//        }
//        ToolbarItem(placement: .bottomBar) {
//            Spacer()
//        }
//
//        ToolbarItem(placement: .bottomBar) {
//            Button(action: {
//                self.delegate.loadLast()
//            }) {
//                Image(systemName: "forward.end")
//                    .imageScale(.large)
////                    .foregroundColor(.buttonColor)
//            }
//            .disabled(!self.delegate.canDoNext)
//        }
    }
}
