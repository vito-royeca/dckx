//
//  AppDelegate+Version.swift
//  dckx
//
//  Created by Vito Royeca on 4/20/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

import Foundation

extension AppDelegate {
    static func getVersion() -> String {
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject

        return nsObject as! String
    }
    
    static func getBuild() -> String {
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleVersion"] as AnyObject

        return nsObject as! String
    }
}
