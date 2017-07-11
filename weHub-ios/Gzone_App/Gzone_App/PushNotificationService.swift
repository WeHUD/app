//
//  PushNotificationService.swift
//  Gzone_App
//
//  Created by Tracy Sablon on 06/07/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

import UserNotifications
import Firebase
import FirebaseInstanceID
import FirebaseMessaging

class PushNotificationService: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    static let sharedInstance = PushNotificationService()
    
    let notificationFCMPoints = Notification.Name("didReceivedFCMPoints")

    // Registering for Firebase notifications
    func configureFirebase(application: UIApplication) {
        
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        Messaging.messaging().shouldEstablishDirectChannel = true
        
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        
        print("-----firebase token: \(String(describing: Messaging.messaging().fcmToken)) ----")
    }
    
    // MARK: FCM Token Refreshed
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        // FCM token updated, update it on Backend Server
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("remoteMessage: \(remoteMessage)")
        
    }
    
    // Called when a notification is delivered to a foreground app.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
        
    }
    
    // Called to let your app know which action was selected by the user for a given notification.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("User Info = \(response.notification.request.content.userInfo)")
        
        let userFCMInfo = response.notification.request.content.userInfo
        
        // Post notification every time user received FCM
        NotificationCenter.default.post(name: notificationFCMPoints, object: nil, userInfo: userFCMInfo)
        
        //Switch to storyboard Home
        /* let storyboard = UIStoryboard(name: "Home", bundle: nil)
         let vc = storyboard.instantiateViewController(withIdentifier: "Home_ID") as UIViewController
         self.window?.rootViewController = vc
         
         //Go to Geolocation tabbar item
         if let tabBarController = vc as? UITabBarController {
         tabBarController.selectedIndex = 2
         
         }*/
        
        completionHandler()
        
    }
}
