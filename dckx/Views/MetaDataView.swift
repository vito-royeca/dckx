//
//  MetaDataView.swift
//  dckx
//
//  Created by Vito Royeca on 3/13/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI

struct MetaDataView: View {
    var leftTitle: String
    var rightTitle: String
    
    var body: some View {
        HStack {
            Text(leftTitle)
                .font(.custom("xkcd-Script-Regular", size: 15))
            Spacer()
            Text(rightTitle)
                .font(.custom("xkcd-Script-Regular", size: 15))
        }
    }
}

struct MetaDataView_Previews: PreviewProvider {
    static var previews: some View {
        MetaDataView(leftTitle: "Left", rightTitle: "Right")
    }
}
