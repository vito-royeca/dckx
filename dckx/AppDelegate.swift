//
//  AppDelegate.swift
//  dckx
//
//  Created by Vito Royeca on 2/13/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import UIKit
import Firebase
//import SwiftRater

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        print("docsPath = \(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])")
        
        // UI custumization
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([.font : UIFont.dckxRegularText],
                                                                                                          for: .normal)
        
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont.dckxLargeTitleText]
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont.dckxTitleText]
        
        // Firebase
        FirebaseApp.configure()
        
        // Database setup
//        Database.sharedInstance.createDatabase()
        Database.sharedInstance.copyDatabase()
        

        // SwiftRater
//        SwiftRater.daysUntilPrompt = 7
//        SwiftRater.daysBeforeReminding = 7
//        SwiftRater.appLaunched()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

