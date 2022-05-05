//
//  AppDelegate.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/02/19.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        if let user = Auth.auth().currentUser {
            UserInfo.shared.uid = user.uid
            UserInfo.shared.email = user.email
            
            if let name = user.displayName {
                UserInfo.shared.name = name
            } else {
                FirestoreService().getUserName(uid: user.uid) { name in
                    UserInfo.shared.name = name
                }
            }
            
            print("You're sign in as \(user.uid), email: \(user.email ?? "no email")")
            
        }

        let db = Firestore.firestore()
        
        print(db)
        
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

