//
//  ListRowView.swift
//  dckx
//
//  Created by Vito Royeca on 4/3/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

import SwiftUI
import SwiftData
import SDWebImageSwiftUI

struct ListRowView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var num: Int
    var thumbnail: URL?
    var title: String
    var isFavorite: Bool
    var date: String
    
    private let titleFont = UserDefaults.standard.bool(forKey: SettingsKey.comicsViewerUseSystemFont) ?
    nil : Font.dckxRegularText
    private let smallFont = UserDefaults.standard.bool(forKey: SettingsKey.comicsViewerUseSystemFont) ?
    Font.system(.subheadline) : Font.dckxSmallText
    
    init(num: Int,
         thumbnail: URL?,
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
        VStack {
            VStack(alignment: .leading) {
                HStack(alignment: .top, spacing: 5) {
                    WebImage(url: thumbnail) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 90, height: 90)
                            .background(Color.backgroundColor)
                            .cornerRadius(5)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 90, height: 90)
                    }
                    
                    Text(title)
                        .font(titleFont)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                    Image(systemName: isFavorite ? "bookmark.fill" : "bookmark")
                        .imageScale(.small)
                        .foregroundStyle(Color.accentColor)
                }
                .padding(10)
            }
            
            Divider()
                .background(Color.secondary)
            
            HStack {
                Text("#\(num)")
                    .font(smallFont)
                Spacer()
                Text(date)
                    .font(smallFont)
            }
            .padding(.leading, 3)
            .padding(.trailing, 3)
            .padding(.bottom, 3)
        }
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.secondary, lineWidth: 1)
        )
    }
}

#Preview {
    NavigationView {
        List {
            ListRowView(num: 2918,
                        thumbnail: URL(string: "https://imgs.xkcd.com/comics/sitting_in_a_tree.png"),
                        title: "Sitting in a Tree",
                        isFavorite: false,
                        date: "2024-04-12")
                .listRowSeparator(.hidden)
            
            ListRowView(num: 2918,
                        thumbnail: URL(string: "https://imgs.xkcd.com/comics/tick_marks.png"),
                        title: "Tick Marks",
                        isFavorite: false,
                        date: "2024-04-10")
                .listRowSeparator(.hidden)
            ListRowView(num: 404,
                        thumbnail: URL(string: ""),
                        title: "Handle 404",
                        isFavorite: false,
                        date: "2024-04-10")
                .listRowSeparator(.hidden)
            ListRowView(num: 2918,
                        thumbnail: URL(string: "https://imgs.xkcd.com/comics/tick_marks.png"),
                        title: "A very very very long title here indeed hahaha. How many lines can this fit in? Hahaha! Could this be another line here?",
                        isFavorite: false,
                        date: "2024-04-10")
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }
}
