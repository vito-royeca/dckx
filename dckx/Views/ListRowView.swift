//
//  ListRowView.swift
//  dckx
//
//  Created by Vito Royeca on 4/3/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct ListRowView: View {
    var num: Int32
    var thumbnail: String
    var title: String
    var isFavorite: Bool
    var isSeen: Bool
    var action: (Int32) -> Void
    @ObservedObject var imageManager: ImageManager
    
    init(num: Int32, thumbnail: String, title: String, isFavorite: Bool,
    isSeen: Bool, action: @escaping (Int32) -> Void) {
        self.num = num
        self.thumbnail = thumbnail
        self.title = title
        self.isFavorite = isFavorite
        self.isSeen = isSeen
        self.action = action
        imageManager = ImageManager(url: URL(string: thumbnail))
    }
    
    var body: some View {
        HStack {
            Image(uiImage: imageManager.image ?? UIImage(named: "logo")!)
                .resizable()
                .frame(width: 50, height: 50)
                .background(Color.white)
                .onAppear {
                    self.imageManager.load()
                }
                .onDisappear {
                    self.imageManager.cancel()
                }
            Spacer()
            VStack {
                HStack {
                    Text("#\(String(num)): \(title)")
                        .font(.custom("xkcd-Script-Regular", size: 15))
                    Spacer()
                }
                Spacer()
                HStack {
                    Image(systemName: isFavorite ? "bookmark.fill" : "bookmark")
                        .imageScale(.small)
                    Image(systemName: isSeen ? "eye.fill" : "eye")
                        .imageScale(.small)
                    Spacer()
                }
            }
            Spacer()
            Button(action: {
                self.action(self.num)
            }) {
                Text(">")
                    .font(.custom("xkcd-Script-Regular", size: 15))
            }
        }
    }
}

struct ListRowView_Previews: PreviewProvider {
    static var previews: some View {
        ListRowView(num: 100,
                    thumbnail: "",
                    title: "Test",
                    isFavorite: false,
                    isSeen: false,
                    action: {_ in })
    }
}
