//
//  dckxApp.swift
//  dckx
//
//  Created by Vito Royeca on 4/13/24.
//  Copyright © 2024 Vito Royeca. All rights reserved.
//

import SwiftUI
import SwiftData

@main
struct dckxApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([
                ComicModel.self,
                WhatIfModel.self
            ])
            let storeURL = URL.documentsDirectory.appending(path: "dckx.sqlite")
            let config1 = ModelConfiguration(url: storeURL,
                                             cloudKitDatabase: .automatic)
            
            print(storeURL)
            container = try ModelContainer(for: schema,
                                           configurations: [config1])
        } catch {
            fatalError("Failed to create ModelContainer for Movie.")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            HamburgerView(modelContext: container.mainContext)
        }
        .modelContainer(container)
    }
    
    static func getVersion() -> String {
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject

        return nsObject as! String
    }
    
    static func getBuild() -> String {
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleVersion"] as AnyObject

        return nsObject as! String
    }
}
