//
//  Constants.swift
//  dckx
//
//  Created by Vito Royeca on 2/22/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI
import CoreData

extension UIFont {
    static let dckxLargeTitleText = UIFont(name: "xkcd-Script-Regular",
                                           size: 28)!
    static let dckxTitleText      = UIFont(name: "xkcd-Script-Regular",
                                           size: 22)!
    static let dckxRegularText    = UIFont(name: "xkcd-Script-Regular",
                                           size: 18)!
    static let dckxSmallText    = UIFont(name: "xkcd-Script-Regular",
                                           size: 12)!
}

extension Font {
    static let dckxLargeTitleText = Font.custom("xkcd-Script-Regular",
                                                size: 28)
    static let dckxTitleText      = Font.custom("xkcd-Script-Regular",
                                                size: 22)
    static let dckxRegularText    = Font.custom("xkcd-Script-Regular",
                                                size: 18)
    static let dckxSmallText      = Font.custom("xkcd-Script-Regular",
                                                size: 12)
}

extension Color {
    static let backgroundColor = Color("BackgroundColor")
    static let dckxBlue        = Color(red: 0.59, green: 0.66, blue: 0.78) // RGB: 150,168,200
}

enum SettingsKey {
    static let showAdvanceContent = "showAdvanceContent"
    static let useSystemFont      = "useSystemFont"
}



