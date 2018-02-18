//
//  AppDelegate.swift
//  Virtual Tourist
//
//  Created by Jordan Jackson on 1/26/18.
//  Copyright © 2018 Jordan Jackson. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        CoreDataStack.shared.autoSave(10)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        CoreDataStack.shared.save()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        CoreDataStack.shared.save()
    }
}

