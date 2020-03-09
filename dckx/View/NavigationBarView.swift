//
//  NavigationBarView.swift
//  dckx
//
//  Created by Vito Royeca on 2/29/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI

class NavigationBarViewNavigator: ObservableObject {
    init() {
        loadLastData()
    }
    
    func loadFirstData() {}
    func canDoPrevious() -> Bool  { return false}
    func loadPreviousData()  {}
    func loadRandomData()  {}
    func loadNextData()  {}
    func canDoNext() -> Bool  { return false }
    func loadLastData()  {}
}

struct NavigationBarView: View {
    @ObservedObject var navigator: NavigationBarViewNavigator
    var resetAction: (() -> Void)?
    
    var body: some View {
        HStack {
            Button(action: {
                self.navigator.loadFirstData()
                self.resetAction?()
            }) {
                Text("|<")
                    .customButton(isDisabled: !navigator.canDoPrevious())
            }
            .disabled(!navigator.canDoPrevious())
            Spacer()
            
            Button(action: {
                self.navigator.loadPreviousData()
                self.resetAction?()
            }) {
                Text("<Prev")
                    .customButton(isDisabled: !navigator.canDoPrevious())
            }
            .disabled(!navigator.canDoPrevious())
            Spacer()
            
            Button(action: {
                self.navigator.loadRandomData()
                self.resetAction?()
            }) {
                Text("Random")
                    .customButton(isDisabled: false)
            }
            Spacer()
            
            Button(action: {
                self.navigator.loadNextData()
                self.resetAction?()
            }) {
                Text("Next>")
                    .customButton(isDisabled: !navigator.canDoNext())
            }
            .disabled(!navigator.canDoNext())
            Spacer()
            
            Button(action: {
                self.navigator.loadLastData()
                self.resetAction?()
            }) {
                Text(">|")
                    .customButton(isDisabled: !navigator.canDoNext())
            }
            .disabled(!navigator.canDoNext())
        }
    }
}

struct NavigationBarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBarView(navigator: NavigationBarViewNavigator(),
                          resetAction: nil)
    }
}

