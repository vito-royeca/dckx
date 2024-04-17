//
//  SettingsView.swift
//  dckx
//
//  Created by Vito Royeca on 4/3/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

import Combine
import SwiftUI

struct SettingsView: View {
    @Binding var showingMenu: Bool
    
    @AppStorage(SettingsKey.showAdvanceContent) private var showAdvanceContent = false
    @AppStorage(SettingsKey.useSystemFont) private var useSystemFont = false
    
    var body: some View {
        NavigationView {
            let regularFont = useSystemFont ? Font.system(.body) : Font.dckxRegularText
            let footerFont = useSystemFont ? Font.system(.footnote) : Font.dckxRegularText
            
            List {
                Section(header: Text("General")
                            .font(regularFont),
                        footer: Text("Advance content may include references to sensitive or health-related topics.")
                            .font(footerFont)) {
                    Toggle("Show Advance Content", isOn: $showAdvanceContent)
                        .font(regularFont)
                }
                
                Section(header: Text("User Interface")
                            .font(regularFont)) {
                    Toggle("Use System Font", isOn: $useSystemFont)
                            .font(regularFont)
                }

                Section(header: Text("About")
                            .font(regularFont)) {
                    Text("xkcd is created by Randall Munroe.")
                        .font(regularFont)
                    Text("What If? is created by Randall Munroe.")
                        .font(regularFont)
                    Text("dckx is a web comics reader created by Vito Royeca.")
                        .font(regularFont)
                    Text("Version \(dckxApp.getVersion())")
                        .font(regularFont)
                }
            }
                .navigationBarTitle(Text("Settings"), displayMode: .large)
                .navigationBarItems(leading: menuButton)
                .listStyle(.insetGrouped)
        }
    }
    
    var menuButton: some View {
        Button(action: {
            withAnimation {
                self.showingMenu.toggle()
            }
        }) {
            Image(systemName: "line.horizontal.3")
                .imageScale(.large)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    @State static private var showingMenu = false
    
    static var previews: some View {
        SettingsView(showingMenu: $showingMenu)
    }
}
