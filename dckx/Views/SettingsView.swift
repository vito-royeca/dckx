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
                        footer: Text("Advance content may include references to sensitive or health-related topics.")
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
                    Toggle("Use Safari Browser in Explanation", isOn: $settings.comicsExplanationUseSafariBrowser)
                        .onChange(of: settings.comicsExplanationUseSafariBrowser) { value in
                            settings.comicsExplanationUseSafariBrowser = value
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
                    Text("xkcd is created by Randall Munroe.")
                        .font(.custom("xkcd-Script-Regular", size: 15))
                    VStack {
                        Text("dckx is an xkcd reader created by Vito Royeca.")
                            .font(.custom("xkcd-Script-Regular", size: 15))
                        Link("vitoroyeca.com", destination: URL(string: "https://www.vitoroyeca.com")!)
                            .font(.custom("xkcd-Script-Regular", size: 15))
                            .foregroundColor(.blue)
                    }
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
    
    @Published var comicsExplanationUseSystemFont: Bool{
        didSet {
            UserDefaults.standard.set(comicsExplanationUseSystemFont, forKey: "comicsExplanationUseSystemFont")
            UserDefaults.standard.synchronize()
        }
    }
    
    @Published var comicsExplanationUseSafariBrowser: Bool{
        didSet {
            UserDefaults.standard.set(comicsExplanationUseSafariBrowser, forKey: "comicsExplanationUseSafariBrowser")
            UserDefaults.standard.synchronize()
        }
    }
    
    @Published var whatIfViewerUseSystemFont: Bool{
        didSet {
            UserDefaults.standard.set(whatIfViewerUseSystemFont, forKey: "whatIfViewerUseSystemFont")
            UserDefaults.standard.synchronize()
        }
    }
    
    init() {
        showSensitiveContent              = UserDefaults.standard.bool(forKey: "showSensitiveContent")
        comicsViewerUseSystemFont         = UserDefaults.standard.bool(forKey: "comicsViewerUseSystemFont")
        comicsExplanationUseSystemFont    = UserDefaults.standard.bool(forKey: "comicsExplanationUseSystemFont")
        comicsExplanationUseSafariBrowser = UserDefaults.standard.bool(forKey: "comicsExplanationUseSafariBrowser")
        whatIfViewerUseSystemFont         = UserDefaults.standard.bool(forKey: "whatIfViewerUseSystemFont")
    }
}
