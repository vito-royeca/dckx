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
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("General")
                                    .font(.custom("xkcd-Script-Regular", size: 15)),
                        footer: Text("Advance content may include references to sensitive or health-related issues.")
                                    .font(.custom("xkcd-Script-Regular", size: 12))
                                    .foregroundColor(Color.gray)) {
                    Toggle("Show Advance Content", isOn: $settings.showSensitiveContent)
                        .onChange(of: settings.showSensitiveContent) { value in
                            settings.showSensitiveContent = value
                        }
                        .font(.custom("xkcd-Script-Regular", size: 15))
                }
                
                Section(header: Text("Comics")
                                    .font(.custom("xkcd-Script-Regular", size: 15))) {
                    Toggle("Use System Font in Viewer", isOn: $settings.comicsViewerUseSystemFont)
                        .onChange(of: settings.comicsViewerUseSystemFont) { value in
                            settings.comicsViewerUseSystemFont = value
                        }
                        .font(.custom("xkcd-Script-Regular", size: 15))
                    Toggle("Use System Font in Explanation", isOn: $settings.comicsExplanationUseSystemFont)
                        .onChange(of: settings.comicsExplanationUseSystemFont) { value in
                            settings.comicsExplanationUseSystemFont = value
                        }
                        .font(.custom("xkcd-Script-Regular", size: 15))
                }

                Section(header: Text("What If?")
                                    .font(.custom("xkcd-Script-Regular", size: 15))) {
                    Toggle("Use System Font in Viewer", isOn: $settings.whatIfViewerUseSystemFont)
                        .onChange(of: settings.whatIfViewerUseSystemFont) { value in
                            settings.whatIfViewerUseSystemFont = value
                        }
                        .font(.custom("xkcd-Script-Regular", size: 15))
                }
                
                Section(header: Text("About")
                                    .font(.custom("xkcd-Script-Regular", size: 15))) {
                    Text("xkcd is created by Randall Munroe")
                        .font(.custom("xkcd-Script-Regular", size: 15))
                    Text("dckx is an xkcd reader created by Vito Royeca")
                        .font(.custom("xkcd-Script-Regular", size: 15))
                }
            }
                .navigationBarTitle(Text("Settings"), displayMode: .large)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

// MARK: - Settings

class Settings: ObservableObject {
    @Published var showSensitiveContent: Bool {
        didSet {
            UserDefaults.standard.set(showSensitiveContent, forKey: "showSensitiveContent")
            UserDefaults.standard.synchronize()
        }
    }
    
    @Published var comicsViewerUseSystemFont: Bool {
        didSet {
            UserDefaults.standard.set(comicsViewerUseSystemFont, forKey: "comicsViewerUseSystemFont")
            UserDefaults.standard.synchronize()
        }
    }
    
//    @Published var comicsListUseSystemFont: Bool{
//        didSet {
//            UserDefaults.standard.set(comicsListUseSystemFont, forKey: "comicsListUseSystemFont")
//            UserDefaults.standard.synchronize()
//        }
//    }
    
    @Published var comicsExplanationUseSystemFont: Bool{
        didSet {
            UserDefaults.standard.set(comicsExplanationUseSystemFont, forKey: "comicsExplanationUseSystemFont")
            UserDefaults.standard.synchronize()
        }
    }
    
    @Published var whatIfViewerUseSystemFont: Bool{
        didSet {
            UserDefaults.standard.set(whatIfViewerUseSystemFont, forKey: "whatIfViewerUseSystemFont")
            UserDefaults.standard.synchronize()
        }
    }
    
//    @Published var whatIfListUseSystemFont: Bool{
//        didSet {
//            UserDefaults.standard.set(whatIfListUseSystemFont, forKey: "whatIfListUseSystemFont")
//            UserDefaults.standard.synchronize()
//        }
//    }
    
    init() {
        showSensitiveContent           = UserDefaults.standard.bool(forKey: "showSensitiveContent")
        comicsViewerUseSystemFont      = UserDefaults.standard.bool(forKey: "comicsViewerUseSystemFont")
//        comicsListUseSystemFont        = UserDefaults.standard.bool(forKey: "comicsListUseSystemFont")
        comicsExplanationUseSystemFont = UserDefaults.standard.bool(forKey: "comicsExplanationUseSystemFont")
        whatIfViewerUseSystemFont      = UserDefaults.standard.bool(forKey: "whatIfViewerUseSystemFont")
//        whatIfListUseSystemFont        = UserDefaults.standard.bool(forKey: "whatIfListUseSystemFont")
    }
}
