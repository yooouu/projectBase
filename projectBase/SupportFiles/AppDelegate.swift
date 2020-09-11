//
//  AppDelegate.swift
//  projectBase
//
//  Created by 유영문 on 2020/09/07.
//  Copyright © 2020 유영문. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if let base = ((self.window?.rootViewController) as? UINavigationController)?.visibleViewController as? BaseViewController {
            base.applicationDidEnterBackground()
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if let base = ((self.window?.rootViewController) as? UINavigationController)?.visibleViewController as? BaseViewController {
            base.applicationDidBecomeActive()
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        if let base = ((self.window?.rootViewController) as? UINavigationController)?.visibleViewController as? BaseViewController {
            base.applicationWillEnterForeground()
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        if let base = ((self.window?.rootViewController) as? UINavigationController)?.visibleViewController as? BaseViewController {
            base.applicationWillTerminate()
        }
    }
}

// MARK: - Protocol AppStateDelegate
protocol AppStateDelegate {
    func applicationDidEnterBackground()
    func applicationDidBecomeActive()
    func applicationWillEnterForeground()
    func applicationWillTerminate()
}
