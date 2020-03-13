//
//  NavigationBarView.swift
//  dckx
//
//  Created by Vito Royeca on 2/29/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI

class NavigationBarViewNavigator {
    init() {
        loadLast()
    }
    
    func loadFirst() {}
    func canDoPrevious() -> Bool { return false }
    func loadPrevious() {}
    func loadRandom() {}
    func loadNext() {}
    func canDoNext() -> Bool { return false }
    func loadLast() {}
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
                    .customButton(isDisabled: !self.navigator.canDoPrevious())
            }
                .disabled(!self.navigator.canDoPrevious())
            Spacer()
            
            Button(action: {
                self.navigator.loadPrevious()
                self.resetAction?()
            }) {
                Text("<Prev")
                    .customButton(isDisabled: !self.navigator.canDoPrevious())
            }
                .disabled(!self.navigator.canDoPrevious())
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
                    .customButton(isDisabled: !self.navigator.canDoNext())
            }
                .disabled(!self.navigator.canDoNext())
            Spacer()
            
            Button(action: {
                self.navigator.loadLast()
                self.resetAction?()
            }) {
                Text(">|")
                    .customButton(isDisabled: !self.navigator.canDoNext())
            }
                .disabled(!self.navigator.canDoNext())
        }
    }
}

struct NavigationBarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBarView(navigator: ComicFetcher(),
                          resetAction: nil)
    }
}

