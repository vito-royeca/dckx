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
    var date: String
    
    init(num: Int,
         thumbnail: String,
         title: String,
         isFavorite: Bool,
         date: String) {
        self.num = num
        self.thumbnail = thumbnail
        self.title = title
        self.isFavorite = isFavorite
        self.date = date
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            let titleFont = UserDefaults.standard.bool(forKey: SettingsKey.comicsViewerUseSystemFont) ?
            nil : Font.dckxRegularText
            let smallFont = UserDefaults.standard.bool(forKey: SettingsKey.comicsViewerUseSystemFont) ?
            Font.system(.subheadline) : Font.dckxSmallText
            
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
            
            VStack(alignment: .leading) {
                Text("#\(String(num)): \(title)")
                    .font(titleFont)
                Text(date)
                    .font(smallFont)
                Spacer()
            }
            
            Spacer()
            
            Image(systemName: isFavorite ? "bookmark.fill" : "bookmark")
                .imageScale(.small)
        }
    }
}

struct ListRowView_Previews: PreviewProvider {
    static var previews: some View {
        ListRowView(num: 100,
                    thumbnail: "",
                    title: "Test",
                    isFavorite: false,
                    date: "2000-01-01")
    }
}
