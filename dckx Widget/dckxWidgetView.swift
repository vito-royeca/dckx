//
//  dckxWidgetView.swift
//  dckx WidgetExtension
//
//  Created by Vito Royeca on 4/20/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct dckxWidgetView: View {
    var urlString: String
    var imageManager: ImageManager
    
    init(urlString: String) {
        self.urlString = urlString
        imageManager = ImageManager(url: URL(string: urlString))
    }
    
    var body: some View {
        Image(uiImage: imageManager.image ?? UIImage(named: "logo")!)
            .resizable()
            .aspectRatio(contentMode: .fit)
//            .frame(width: 70, height: 70)
//            .cornerRadius(5)
            .onAppear {
                self.imageManager.load()
            }
            .onDisappear {
                self.imageManager.cancel()
            }
    }
}

struct dckxWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        dckxWidgetView(urlString: "https://imgs.xkcd.com/comics/iss_vaccine.png")
    }
}
