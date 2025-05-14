//
//  AppDelegate.swift
//  PictureApp
//
//  Created by Jose Quemba on 5/14/25.
//
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("PhotoNotes: Application did finish launching")
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("PhotoNotes: Application will terminate")
    }
}
