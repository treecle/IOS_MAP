//
//  AppDelegate.swift
//  TreecleMap
//
//  Created by Yee on 2021/08/12.
//

import UIKit
import OneSignal

let ONE_SIGNAL_APP_ID = "f45c0354-e93b-4b43-b439-16b9e48dd243"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if #available(iOS 13.0, *) {
            self.window?.overrideUserInterfaceStyle = .light
        }
        
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false,
                                     kOSSettingsKeyInAppLaunchURL: false]
        
        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
            // This block gets called when the user reacts to a notification received
            let payload: OSNotificationPayload? = result?.notification.payload
            
            print("Message = \(payload!.body ?? "")")
            print("badge number = \(payload?.badge ?? 0)")
            print("notification sound = \(payload?.sound ?? "None")")
            
            // 구앱 대응 - HTML로 푸시를 보낼때 아래 로직이 동작
            if let additionalData = result!.notification.payload!.additionalData,
                let pushURL = additionalData["custom_url"] as? String {
                print("additionalData = \(additionalData)")
                print("pushURL = \(pushURL)")
                
                if let rootVC = self.window?.rootViewController as? ViewController {
                    rootVC.reloadURL(pushURL)
                }
                
                if let actionSelected = payload?.actionButtons {
                    print("actionSelected = \(actionSelected)")
                }
                
                // DEEP LINK from action buttons
                if let actionID = result?.action.actionID {
                    print("actionID = \(actionID)")
                }
            }
            
        }
        
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: ONE_SIGNAL_APP_ID,
                                        handleNotificationReceived: nil,
                                        handleNotificationAction: notificationOpenedBlock,
                                        settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User enable notifications: \(accepted)")
        })
        
        OneSignal.add(self as OSPermissionObserver)
        OneSignal.add(self as OSSubscriptionObserver)
        
        return true
    }

}


extension AppDelegate: OSPermissionObserver, OSSubscriptionObserver {
    func onOSPermissionChanged(_ stateChanges: OSPermissionStateChanges!) {
        
        if stateChanges.from.status == OSNotificationPermission.notDetermined {
            if stateChanges.to.status == OSNotificationPermission.authorized {
                print("푸시 노티 허용!")
                if let rootVC = self.window?.rootViewController as? ViewController {
                    rootVC.setPushID()
                }
            } else if stateChanges.to.status == OSNotificationPermission.denied {
                print("푸시 노티 미허용!!!! ")
            }
        }
    }
    
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        if !stateChanges.from.subscribed && stateChanges.to.subscribed {
            print("Subscribed for OneSignal push notifications!")
        }
    }
}


