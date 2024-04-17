//
//  WhatIfToolbarView.swift
//  dckx
//
//  Created by Vito Royeca on 4/17/24.
//  Copyright © 2024 Vito Royeca. All rights reserved.
//

import SwiftUI

struct WhatIfToolbarView: View {
    @EnvironmentObject var viewModel: WhatIfViewModel
    @State private var showingShare = false
    
    var body: some View {
        HStack {
            Button(action: {
                viewModel.toggle(isFavoriteEnabled: !(viewModel.currentWhatIf?.isFavorite ?? false))
            }) {
                Image(systemName: viewModel.currentWhatIf?.isFavorite ?? false ? "bookmark.fill" : "bookmark")
                    .imageScale(.large)
            }
                .disabled(viewModel.isBusy)
            Spacer()
            
            Button(action: {
                self.showingShare.toggle()
            }) {
                Image(systemName: "square.and.arrow.up")
                    .imageScale(.large)
            }
                .disabled(viewModel.isBusy)
                .sheet(isPresented: $showingShare) {
                    ShareSheetView(activityItems: self.activityItems(),
                                   applicationActivities: nil)
                }
        }
    }
    
    func activityItems() -> [Any] {
        var items = [Any]()
        
        if let whatIf = viewModel.currentWhatIf,
           let url = URL(string: whatIf.link) {
            items.append(url)
        }
        
        return items
    }
}

#Preview {
    WhatIfToolbarView()
}
