//
//  Constants.swift
//  dckx
//
//  Created by Vito Royeca on 2/22/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI

extension Color {
    static let buttonColor     = Color("ButtonColor")
    static let backgroundColor = Color("BackgroundColor")
    static let dckxBlue        = Color(red: 0.43, green: 0.48, blue: 0.57)
}

struct ButtonModifier: ViewModifier {
    var isDisabled = true
    
    func body(content: Content) -> some View {
        content
            .padding(4)
            .font(.custom("xkcd-Script-Regular", size: 15))
            .foregroundColor(isDisabled ? Color.gray : .white)
            .background(RoundedRectangle(cornerRadius: 4, style:   .circular).foregroundColor(.buttonColor))
    }
}

extension View {
    func customButton(isDisabled: Bool) -> ModifiedContent<Self, ButtonModifier> {
        return modifier(ButtonModifier(isDisabled: isDisabled))
    }
}
