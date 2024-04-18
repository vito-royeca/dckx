//
//  OpenCVTestView.swift
//  dckx
//
//  Created by Vito Royeca on 4/18/24.
//  Copyright © 2024 Vito Royeca. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct OpenCVTestView: View {
    @State var info = ""
    let url = "https://imgs.xkcd.com/comics/regular_expressions.png"
    
    var body: some View {
        VStack {
            WebImage(url: URL(string: url)) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                Rectangle().foregroundColor(.gray)
            }
            .onSuccess { image, data, cacheType in
                if let fileName = SDImageCache.shared.cachePath(forKey: url) {
                    OpenCVWrapper.split(fileName, 1) { dictionary in
                        print(dictionary)
                        info = "\(dictionary)"
                    }
                }
            }
            
            Text(info)
        }
    }
}

#Preview {
    OpenCVTestView()
}
