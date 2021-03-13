//
//  NavigationBarView.swift
//  dckx
//
//  Created by Vito Royeca on 2/29/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI

protocol NavigationBarViewNavigator {
    var canDoPrevious: Bool { get }
    var canDoNext: Bool { get }
    func loadFirst()
    func loadPrevious()
    func loadRandom()
    func loadNext()
    func loadLast()
    
    func dateToString(date: Date?) -> String
}

extension NavigationBarViewNavigator {
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

struct NavigationBarView: View {
    var navigator: NavigationBarViewNavigator
    var resetAction: (() -> Void)?
    
    var body: some View {
        HStack {
            Button(action: {
                self.navigator.loadFirst()
                self.resetAction?()
            }) {
                Text("|<")
                    .customButton(isDisabled: !self.navigator.canDoPrevious)
            }
                .disabled(!self.navigator.canDoPrevious)
            Spacer()
            
            Button(action: {
                self.navigator.loadPrevious()
                self.resetAction?()
            }) {
                Text("<Prev")
                    .customButton(isDisabled: !self.navigator.canDoPrevious)
            }
                .disabled(!self.navigator.canDoPrevious)
            Spacer()
            
            Button(action: {
                self.navigator.loadRandom()
                self.resetAction?()
            }) {
                Text("Random")
                    .customButton(isDisabled: false)
            }
            Spacer()
            
            Button(action: {
                self.navigator.loadNext()
                self.resetAction?()
            }) {
                Text("Next>")
                    .customButton(isDisabled: !self.navigator.canDoNext)
            }
                .disabled(!self.navigator.canDoNext)
            Spacer()
            
            Button(action: {
                self.navigator.loadLast()
                self.resetAction?()
            }) {
                Text(">|")
                    .customButton(isDisabled: !self.navigator.canDoNext)
            }
                .disabled(!self.navigator.canDoNext)
        }
    }
}

struct NavigationBarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBarView(navigator: ComicFetcher(),
                          resetAction: nil)
    }
}

