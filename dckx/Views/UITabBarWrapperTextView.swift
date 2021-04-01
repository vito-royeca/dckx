//
//  UITabBarWrapperTextView.swift
//  dckx
//
//  Created by Vito Royeca on 3/31/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

import SwiftUI

struct UITabBarWrapperTextView: View {
    var body: some View {
        UITabBarWrapper([
            TabBarElement(tabBarElementItem: .init(title: "First", systemImageName: "house.fill")) {
                Text("First View")
            },
            TabBarElement(tabBarElementItem: .init(title: "Second", systemImageName: "pencil.circle.fill")) {
                Text("Second View")
            },
            TabBarElement(tabBarElementItem: .init(title: "Third", systemImageName: "folder.fill")) {
                Text("Third View")
            },
            TabBarElement(tabBarElementItem: .init(title: "Fourth", systemImageName: "tray.fill")) {
                Text("Fourth View")
            },
            TabBarElement(tabBarElementItem: .init(title: "Fifth", systemImageName: "doc.fill")) {
                Text("Fifth View")
            },
            TabBarElement(tabBarElementItem: .init(title: "Sixth", systemImageName: "link.circle.fill")) {
                Text("Sixth View")
            },
            TabBarElement(tabBarElementItem: .init(title: "Seventh", systemImageName: "person.fill")) {
                Text("Seventh View")
            }
        ])
    }
}

struct UITabBarWrapperTextView_Previews: PreviewProvider {
    static var previews: some View {
        UITabBarWrapperTextView()
    }
}
