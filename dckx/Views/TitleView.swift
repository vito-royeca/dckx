//
//  TitleView.swift
//  dckx
//
//  Created by Vito Royeca on 3/13/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI

struct TitleView: View {
    var title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.custom("xkcd-Script-Regular", size: 30))
        }
            .padding(5)
    }
}

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        TitleView(title: "Title")
    }
}
