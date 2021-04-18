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
    @Environment(\.colorScheme) var colorScheme
    
    var num: Int32
    var thumbnail: String
    var title: String
    var isFavorite: Bool
    var isSeen: Bool
    var action: (Int32) -> Void
    var font: Font
    @ObservedObject var imageManager: ImageManager
    
    init(num: Int32, thumbnail: String, title: String, isFavorite: Bool,
         isSeen: Bool, font: Font, action: @escaping (Int32) -> Void) {
        self.num = num
        self.thumbnail = thumbnail
        self.title = title
        self.isFavorite = isFavorite
        self.isSeen = isSeen
        self.font = font
        self.action = action
        imageManager = ImageManager(url: URL(string: thumbnail))
    }
    
    var body: some View {
        HStack {
            Image(uiImage: imageManager.image ?? UIImage(named: "logo")!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 70, height: 70)
                .background(colorScheme == .dark ? Color.init(UIColor.lightGray) : Color.clear)
                .cornerRadius(5)
                .onAppear {
                    self.imageManager.load()
                }
                .onDisappear {
                    self.imageManager.cancel()
                }
            Spacer()
            VStack {
                Spacer()
                HStack {
                    Text("#\(String(num)): \(title)")
                        .font(font)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: isFavorite ? "bookmark.fill" : "bookmark")
                        .imageScale(.small)
                    Image(systemName: isSeen ? "eye.fill" : "eye")
                        .imageScale(.small)
                }
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
                    font: Font.dckxRegularText,
                    action: {_ in })
    }
}
