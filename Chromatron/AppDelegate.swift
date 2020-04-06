//
//  AppDelegate.swift
//  Chromatron
//
//  Created by SwanCurve on 03/10/20.
//  Copyright © 2020 SwanCurve. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        prepareDecoder()
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

    private func prepareDecoder() {
        // typealias ResponsibleData = (t: String, placed: Bool, color: BeamColor, angle: Angle, x: Int, y: Int)
        CDecode.shared.register("R") { data in
            let r = Reflector()
            if let data = data {
                r.angle = data.angle
                r.color = data.color
                r.location = Point(x: data.x, y: data.y)
            }
            return r
        }
        
        CDecode.shared.register("L") { data in
            let r = Laser()
            if let data = data {
                r.location = Point(x: data.x, y: data.y)
                r.color = data.color
                r.angle = data.angle
            }
            return r
        }
        
        CDecode.shared.register("S") { data in
            let r = Splitter()
            if let data = data {
                r.angle = data.angle
                r.color = data.color
                r.location = Point(x: data.x, y: data.y)
            }
            return r
        }
        
        CDecode.shared.register("T") { data in
            let r = Target()
            if let data = data {
                r.require = data.color
                r.location = Point(x: data.x, y: data.y)
            }
            return r
        }
        
        CDecode.shared.register("C") { data in
            let r = Conduits()
            if let data = data {
                r.angle = data.angle
                r.color = data.color
                r.location = Point(x: data.x, y: data.y)
            }
            return r
        }
        
        CDecode.shared.register("B") { data in
            let r = Bender()
            if let data = data {
                r.angle = data.angle
                r.color = data.color
                r.location = Point(x: data.x, y: data.y)
            }
            return r
        }
    }
}

