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
                Section(header: Text("General"),
                        footer: Text("Advance topics may include references to sensitive or health-related issues.")) {
                    Toggle("Show Advance Topics", isOn: $settings.showSensitiveContent)
                        .onChange(of: settings.showSensitiveContent) { value in
                            settings.showSensitiveContent = value
                        }
                }
                
                Section(header: Text("Comics")) {
                    Toggle("Use System Font in Viewer", isOn: $settings.comicsViewerUseSystemFont)
                        .onChange(of: settings.comicsViewerUseSystemFont) { value in
                            settings.comicsViewerUseSystemFont = value
                        }
                    Toggle("Use System Font in List", isOn: $settings.comicsListUseSystemFont)
                        .onChange(of: settings.comicsListUseSystemFont) { value in
                            settings.comicsListUseSystemFont = value
                        }
                    Toggle("Use System Font in Explanation", isOn: $settings.comicsExplanationUseSystemFont)
                        .onChange(of: settings.comicsExplanationUseSystemFont) { value in
                            settings.comicsExplanationUseSystemFont = value
                        }
                }

                Section(header: Text("What If?")) {
                    Toggle("Use System Font in Viewer", isOn: $settings.whatIfViewerUseSystemFont)
                        .onChange(of: settings.whatIfViewerUseSystemFont) { value in
                            settings.whatIfViewerUseSystemFont = value
                        }
                    Toggle("Use System Font in List", isOn: $settings.whatIfListUseSystemFont)
                        .onChange(of: settings.whatIfListUseSystemFont) { value in
                            settings.whatIfListUseSystemFont = value
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
    
    @Published var comicsListUseSystemFont: Bool{
        didSet {
            UserDefaults.standard.set(comicsListUseSystemFont, forKey: "comicsListUseSystemFont")
            UserDefaults.standard.synchronize()
        }
    }
    
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
    
    @Published var whatIfListUseSystemFont: Bool{
        didSet {
            UserDefaults.standard.set(whatIfListUseSystemFont, forKey: "whatIfListUseSystemFont")
            UserDefaults.standard.synchronize()
        }
    }
    
    init() {
        showSensitiveContent           = UserDefaults.standard.bool(forKey: "showSensitiveContent")
        comicsViewerUseSystemFont      = UserDefaults.standard.bool(forKey: "comicsViewerUseSystemFont")
        comicsListUseSystemFont        = UserDefaults.standard.bool(forKey: "comicsListUseSystemFont")
        comicsExplanationUseSystemFont = UserDefaults.standard.bool(forKey: "comicsExplanationUseSystemFont")
        whatIfViewerUseSystemFont      = UserDefaults.standard.bool(forKey: "whatIfViewerUseSystemFont")
        whatIfListUseSystemFont        = UserDefaults.standard.bool(forKey: "whatIfListUseSystemFont")
    }
}
