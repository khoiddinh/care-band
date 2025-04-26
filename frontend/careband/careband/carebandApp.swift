//
//  carebandApp.swift
//  careband
//
//  Created by Khoi Dinh on 4/25/25.
//

import SwiftUI
import CoreNFC
import Firebase
import FirebaseAuth
import FirebaseCore

@main
struct MedicalBraceletApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
