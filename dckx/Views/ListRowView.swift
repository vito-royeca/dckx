//
//  ListRowView.swift
//  dckx
//
//  Created by Vito Royeca on 4/3/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

import SwiftUI
import SwiftData

struct ListRowView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var num: Int
    var thumbnail: String
    var title: String
    var isFavorite: Bool
    var isSeen: Bool
    var font: Font
    
    init(num: Int,
         thumbnail: String,
         title: String,
         isFavorite: Bool,
         isSeen: Bool,
         font: Font) {
        self.num = num
        self.thumbnail = thumbnail
        self.title = title
        self.isFavorite = isFavorite
        self.isSeen = isSeen
        self.font = font
    }
    
    var body: some View {
        HStack(alignment: .top) {
            AsyncImage(url: URL(string: thumbnail)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70, height: 70)
                    .background(colorScheme == .dark ? Color.init(UIColor.lightGray) : Color.clear)
                    .cornerRadius(5)
            } placeholder: {
                ProgressView()
            }
            
            VStack {
                Spacer()
                Text("#\(String(num)): \(title)")
                    .font(font)
                Spacer()
            }
            
            Spacer()
            
            HStack {
                Image(systemName: isFavorite ? "bookmark.fill" : "bookmark")
                    .imageScale(.small)
                Image(systemName: isSeen ? "eye.fill" : "eye")
                    .imageScale(.small)
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
                    font: Font.dckxSmallText)
    }
}
