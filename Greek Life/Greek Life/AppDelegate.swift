//
//  AppDelegate.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-10-20.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import IQKeyboardManagerSwift
import Whisper
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let defaults:UserDefaults = UserDefaults.standard


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure();
        IQKeyboardManager.sharedManager().enable = true
        
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
        application.registerForRemoteNotifications()
        return true
    }
    
    // Called when APNs has assigned the device a unique token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        self.defaults.set(deviceTokenString, forKey: "NotificationId")
        print("APNs device token: \(deviceTokenString)")
    }
    
    // Called when APNs failed to register the device for push notifications
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs registration failed: \(error)")
        GenericTools.Logger(data: "\n APNs registration failed: \(error)")
    }
    
    //not handling if app was closed and just launched
    
    // Push notification received while application is in use!!!
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        //For DMS we recieve the recievers id
        if let payload = data["id"] as? String {
            let index1 = payload.index(payload.startIndex, offsetBy: 3)
            let myNotifIdIndex = payload[..<index1]
            let myNotifId = String(myNotifIdIndex)
            
            
            if myNotifId == "DDM" { //direct
                let index2 = payload.index(payload.startIndex, offsetBy: 3)..<payload.endIndex
                let senderId = String(payload[index2])
                let aps = data[AnyHashable("aps")] as? NSDictionary
                if let body = aps!["alert"] as? String {
                    let sender = (body.components(separatedBy: ":"))[0]
                    let message = (body.components(separatedBy: ":"))[1]
                    let state: UIApplicationState = UIApplication.shared.applicationState
                    if state == .active && UIApplication.shared.keyWindow?.currentViewController()! is ChatViewController {
                        let announcement = Announcement(title: sender, subtitle: message, image: UIImage(named: "Icons/Logo2.png"))
                        Whisper.show(shout: announcement, to: (UIApplication.shared.keyWindow?.currentViewController())!, completion: {
                        })
                        if DMNotifications.UnreadIds.contains(senderId!) == false {
                            DMNotifications.UnreadIds.append(senderId!)
                        }
                    }
                }
            }
            if myNotifId == "CDM" { //channel
                let index2 = payload.index(payload.startIndex, offsetBy: 3)..<payload.endIndex
                let senderId = String(payload[index2])
                let aps = data[AnyHashable("aps")] as? NSDictionary
                if let body = aps!["alert"] as? String {
                    let sender = (body.components(separatedBy: ":"))[0]
                    let message = (body.components(separatedBy: ":"))[1]
                    let state: UIApplicationState = UIApplication.shared.applicationState
                    if state == .active && UIApplication.shared.keyWindow?.currentViewController()! is ChatViewController {
                        let announcement = Announcement(title: sender, subtitle: message, image: UIImage(named: "Icons/Logo2.png"))
                        Whisper.show(shout: announcement, to: (UIApplication.shared.keyWindow?.currentViewController())!, completion: {
                        })
                        if ChannelNotifications.UnreadIds.contains(senderId!) == false {
                            ChannelNotifications.UnreadIds.append(senderId!)
                        }
                    }
                }
            }
            
        }
        //here we just wanna whisper
    }

    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = -1
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

