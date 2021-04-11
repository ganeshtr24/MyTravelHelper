//
//  AppDelegate.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        return false
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {

     }

     // MARK: - UISceneSession Lifecycle

     @available(iOS 13.0, *)
     func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
         // Called when a new scene session is being created.
         // Use this method to select a configuration to create the new scene with.
         return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
     }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }
}

