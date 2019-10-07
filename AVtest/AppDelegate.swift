//
//  AppDelegate.swift
//  AVtest
//
//  Created by 周全营 on 2019/10/6.
//  Copyright © 2019 周全营. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let nav = UINavigationController(rootViewController: ViewController())
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.red
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
        return true
    }
}

