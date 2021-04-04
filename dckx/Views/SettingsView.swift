//
//  SettingsView.swift
//  dckx
//
//  Created by Vito Royeca on 4/3/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

import SwiftUI

struct ComicsViewerUseSystemFontKey: EnvironmentKey {
    static var defaultValue: Binding<Bool> = .constant(UserDefaults.standard.bool(forKey: "comicsViewerUseSystemFont"))
}
struct ComicsListUseSystemFontKey: EnvironmentKey {
    static var defaultValue: Binding<Bool> = .constant(UserDefaults.standard.bool(forKey: "comicsListUseSystemFont"))
}
struct ComicsExplanationUseSystemFontKey: EnvironmentKey {
    static var defaultValue: Binding<Bool> = .constant(UserDefaults.standard.bool(forKey: "comicsExplanationUseSystemFont"))
}
struct WhatIfViewerUseSystemFontKey: EnvironmentKey {
    static var defaultValue: Binding<Bool> = .constant(UserDefaults.standard.bool(forKey: "whatIfViewerUseSystemFont"))
}
struct WhatIfListUseSystemFontKey: EnvironmentKey {
    static var defaultValue: Binding<Bool> = .constant(UserDefaults.standard.bool(forKey: "whatIfListUseSystemFont"))
}

extension EnvironmentValues {
    var comicsViewerUseSystemFont: Binding<Bool> {
        get { self[ComicsViewerUseSystemFontKey.self] }
        set {
            self[ComicsViewerUseSystemFontKey.self] = newValue
        }
    }
    
    var comicsListUseSystemFont: Binding<Bool> {
        get { self[ComicsListUseSystemFontKey.self] }
        set {
            self[ComicsListUseSystemFontKey.self] = newValue
        }
    }
    
    var comicsExplanationUseSystemFont: Binding<Bool> {
        get { self[ComicsExplanationUseSystemFontKey.self] }
        set {
            self[ComicsExplanationUseSystemFontKey.self] = newValue
        }
    }
    
    var whatIfViewerUseSystemFont: Binding<Bool> {
        get { self[WhatIfViewerUseSystemFontKey.self] }
        set {
            self[WhatIfViewerUseSystemFontKey.self] = newValue
        }
    }
    
    var whatIfListUseSystemFont: Binding<Bool> {
        get { self[WhatIfListUseSystemFontKey.self] }
        set {
            self[WhatIfListUseSystemFontKey.self] = newValue
        }
    }
}

struct SettingsView: View {
//    @Environment(\.comicsViewerUseSystemFont)      var eComicsViewerUseSystemFont
//    @Environment(\.comicsListUseSystemFont)        var eComicsListUseSystemFont
//    @Environment(\.comicsExplanationUseSystemFont) var eComicsExplanationUseSystemFont
//    @Environment(\.whatIfViewerUseSystemFont)      var eWhatIfViewerUseSystemFont
//    @Environment(\.whatIfListUseSystemFont)        var eWhatIfListUseSystemFont
    @State private var comicsViewerUseSystemFont      = UserDefaults.standard.bool(forKey: "comicsViewerUseSystemFont")
    @State private var comicsListUseSystemFont        = UserDefaults.standard.bool(forKey: "comicsListUseSystemFont")
    @State private var comicsExplanationUseSystemFont = UserDefaults.standard.bool(forKey: "comicsExplanationUseSystemFont")
    @State private var whatIfViewerUseSystemFont      = UserDefaults.standard.bool(forKey: "whatIfViewerUseSystemFont")
    @State private var whatIfListUseSystemFont        = UserDefaults.standard.bool(forKey: "whatIfListUseSystemFont")
    
    var body: some View {
        List {
            Section(header: Text("Comics")) {
                Toggle("Use System Font in Viewer", isOn: $comicsViewerUseSystemFont)
                    .onChange(of: comicsViewerUseSystemFont) { value in
                        comicsViewerUseSystemFont = value
                        UserDefaults.standard.set(value, forKey: "comicsViewerUseSystemFont")
                    }
                Toggle("Use System Font in List", isOn: $comicsListUseSystemFont)
                    .onChange(of: comicsListUseSystemFont) { value in
                        comicsListUseSystemFont = value
                        UserDefaults.standard.set(value, forKey: "comicsListUseSystemFont")
                    }
                Toggle("Use System Font in Explanation", isOn: $comicsExplanationUseSystemFont)
                    .onChange(of: comicsExplanationUseSystemFont) { value in
                        comicsExplanationUseSystemFont = value
                        UserDefaults.standard.set(value, forKey: "comicsExplanationUseSystemFont")
                    }
            }

            Section(header: Text("What If?")) {
                Toggle("Use System Font in Viewer", isOn: $whatIfViewerUseSystemFont)
                    .onChange(of: whatIfViewerUseSystemFont) { value in
                        whatIfViewerUseSystemFont = value
                        UserDefaults.standard.set(value, forKey: "whatIfViewerUseSystemFont")
                    }
                Toggle("Use System Font in List", isOn: $whatIfListUseSystemFont)
                    .onChange(of: whatIfListUseSystemFont) { value in
                        whatIfListUseSystemFont = value
                        UserDefaults.standard.set(value, forKey: "whatIfListUseSystemFont")
                    }
            }
        }
            .environment(\.comicsViewerUseSystemFont,      $comicsViewerUseSystemFont)
            .environment(\.comicsListUseSystemFont,        $comicsListUseSystemFont)
            .environment(\.comicsExplanationUseSystemFont, $comicsExplanationUseSystemFont)
            .environment(\.whatIfViewerUseSystemFont,      $whatIfViewerUseSystemFont)
            .environment(\.whatIfListUseSystemFont,        $whatIfListUseSystemFont)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
