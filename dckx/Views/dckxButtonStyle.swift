//
//  dckxButtonStyle.swift
//  dckx
//
//  Created by Vito Royeca on 4/16/24.
//  Copyright © 2024 Vito Royeca. All rights reserved.
//

import SwiftUI

struct dckxButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        dckxButton(configuration: configuration)
    }
    
    struct dckxButton: View {
        let configuration: ButtonStyle.Configuration
        @Environment(\.isEnabled) private var isEnabled: Bool
        @Environment(\.colorScheme) var colorScheme
        
        var body: some View {
            configuration
                .label
                .foregroundColor(isEnabled ? .white : .gray)
                .font(.system(size: 24, weight: .bold))
                .padding(.top, 3)
                .padding(.leading, 5)
                .padding(.trailing, 5)
                .padding(.bottom, 3)
                .background(isEnabled ? Color.accentColor: .clear)
                .cornerRadius(3)
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(isEnabled ? (colorScheme == .dark ? Color.accentColor : .black) : .gray, lineWidth: 2)
                )
        }
    }
}

struct dckxButtonView: View {
    var body: some View {
        HStack {
            Button("|<") {
                print("Button pressed!")
            }
            .buttonStyle(dckxButtonStyle())
            
            Button("< Prev") {
                print("Button pressed!")
            }
            .buttonStyle(dckxButtonStyle())
            
            Button("Random") {
                print("Button pressed!")
            }
            .buttonStyle(dckxButtonStyle())
            
            Button("Next >") {
                print("Button pressed!")
            }
            .disabled(true)
            .buttonStyle(dckxButtonStyle())
            
            Button(">|") {
                print("Button pressed!")
            }
            .disabled(true)
            .buttonStyle(dckxButtonStyle())
        }
    }
}

#Preview {
    dckxButtonView()
}
