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
                                    .font(Font.dckxRegularText),
                        footer: Text("Advance content may include references to sensitive or health-related topics.")
                                    .font(Font.dckxSmallText)
                                    .foregroundColor(Color.gray)) {
                    Toggle("Show Advance Content", isOn: $settings.showSensitiveContent)
                        .onChange(of: settings.showSensitiveContent) { value in
                            settings.showSensitiveContent = value
                        }
                        .font(Font.dckxRegularText)
                }
                
                Section(header: Text("Comics")
                                    .font(Font.dckxRegularText)) {
                    Toggle("Use System Font in Viewer", isOn: $settings.comicsViewerUseSystemFont)
                        .onChange(of: settings.comicsViewerUseSystemFont) { value in
                            settings.comicsViewerUseSystemFont = value
                        }
                        .font(Font.dckxRegularText)
                    Toggle("Use System Font in Explanation", isOn: $settings.comicsExplanationUseSystemFont)
                        .onChange(of: settings.comicsExplanationUseSystemFont) { value in
                            settings.comicsExplanationUseSystemFont = value
                        }
                        .font(Font.dckxRegularText)
                    Toggle("Use Safari Browser in Explanation", isOn: $settings.comicsExplanationUseSafariBrowser)
                        .onChange(of: settings.comicsExplanationUseSafariBrowser) { value in
                            settings.comicsExplanationUseSafariBrowser = value
                        }
                        .font(Font.dckxRegularText)
                }

                Section(header: Text("What If?")
                                    .font(Font.dckxRegularText)) {
                    Toggle("Use System Font in Viewer", isOn: $settings.whatIfViewerUseSystemFont)
                        .onChange(of: settings.whatIfViewerUseSystemFont) { value in
                            settings.whatIfViewerUseSystemFont = value
                        }
                        .font(Font.dckxRegularText)
                }
                
                Section(header: Text("About")
                                    .font(Font.dckxRegularText)) {
                    Text("xkcd is created by Randall Munroe.")
                        .font(Font.dckxRegularText)
                    VStack {
                        Text("dckx is an xkcd reader created by Vito Royeca.")
                            .font(Font.dckxRegularText)
                        Link("vitoroyeca.com", destination: URL(string: "https://www.vitoroyeca.com")!)
                            .font(Font.dckxRegularText)
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

enum SettingsKey {
    static let showSensitiveContent              = "showSensitiveContent"
    static let comicsViewerUseSystemFont         = "comicsViewerUseSystemFont"
    static let comicsExplanationUseSystemFont    = "comicsExplanationUseSystemFont"
    static let comicsExplanationUseSafariBrowser = "comicsExplanationUseSafariBrowser"
    static let whatIfViewerUseSystemFont         = "whatIfViewerUseSystemFont"
}

class Settings: ObservableObject {
    @Published var showSensitiveContent: Bool {
        didSet {
            UserDefaults.standard.set(showSensitiveContent, forKey: SettingsKey.showSensitiveContent)
            UserDefaults.standard.synchronize()
        }
    }
    
    @Published var comicsViewerUseSystemFont: Bool {
        didSet {
            UserDefaults.standard.set(comicsViewerUseSystemFont, forKey: SettingsKey.comicsViewerUseSystemFont)
            UserDefaults.standard.synchronize()
        }
    }
    
    @Published var comicsExplanationUseSystemFont: Bool{
        didSet {
            UserDefaults.standard.set(comicsExplanationUseSystemFont, forKey: SettingsKey.comicsExplanationUseSystemFont)
            UserDefaults.standard.synchronize()
        }
    }
    
    @Published var comicsExplanationUseSafariBrowser: Bool{
        didSet {
            UserDefaults.standard.set(comicsExplanationUseSafariBrowser, forKey: SettingsKey.comicsExplanationUseSafariBrowser)
            UserDefaults.standard.synchronize()
        }
    }
    
    @Published var whatIfViewerUseSystemFont: Bool{
        didSet {
            UserDefaults.standard.set(whatIfViewerUseSystemFont, forKey: SettingsKey.whatIfViewerUseSystemFont)
            UserDefaults.standard.synchronize()
        }
    }
    
    init() {
        showSensitiveContent              = UserDefaults.standard.bool(forKey: SettingsKey.showSensitiveContent)
        comicsViewerUseSystemFont         = UserDefaults.standard.bool(forKey: SettingsKey.comicsViewerUseSystemFont)
        comicsExplanationUseSystemFont    = UserDefaults.standard.bool(forKey: SettingsKey.comicsExplanationUseSystemFont)
        comicsExplanationUseSafariBrowser = UserDefaults.standard.bool(forKey: SettingsKey.comicsExplanationUseSafariBrowser)
        whatIfViewerUseSystemFont         = UserDefaults.standard.bool(forKey: SettingsKey.whatIfViewerUseSystemFont)
    }
}
