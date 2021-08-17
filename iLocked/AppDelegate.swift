//
//  AppDelegate.swift
//  iLocked
//
//  Created by Nathan on 13/10/2019.
//  Copyright © 2019 Nathan. All rights reserved.
//

import UIKit
import InAppPurchaseLib

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let viewControllerTitleAllowedForSegue = ["MainTabBarController", "EncryptHomePage","addKeyNavCrtl","AddKeyCrtl","PublicKeyList","PublicKeyView","SettingsView", "AdvancedSettingsView","developerView","DecryptHomePage","DecryptResult","DecryptResult","revokeView"]
    // List of the titles of the VC that can perform a segue named "lockApp"
    
    let settingsData = SettingsData()

    
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
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let dateString  = dateFormatter.string(from: date)
        print("[*] Scene delegate called, date = \(date)")
        settingsData.saveLastTimeAppIsClosed(timesInfo: [DateInfosName.dateOfClose.key : dateString, DateInfosName.hasBeenUnlocked.key : "false"])
        
        let (_, (isPasswordActivated, timeBeforeLocking)) = settingsData.checkIfHideScreenAndPassword()
        if isPasswordActivated && timeBeforeLocking == 0 {
            //Is called when the app move to background AND NOT in app switcher
            performSegue()
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool{
        print("[*] Application launched")
        #warning("In app purchase isn't completed and will not work.\nIt must be completed before launching, after the creation of an apple ID.\nSee more @ https://iridescent.dev/posts/swift/in-app-purchases-ios-2")
        /*InAppPurchase.initialize(
              iapProducts: [
                IAPProduct(productIdentifier: "nonConsumableId", productType: .nonConsumable),
              ],
              validatorUrlString: "https://validator.fovea.cc/v1/validate?appName=demo&apiKey=12345678"
            )*/
            return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("[*] Application will terminate")
          InAppPurchase.stop()
      }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        let (isHidden, (_, _)) = settingsData.checkIfHideScreenAndPassword()
        print("[*] isHidden, isPasswordActivated, timeBeforeLocking = \((isHidden)),(_, _)))")
        if isHidden {
            //Is called when the app move to background OR is in app switcher
            self.performSegue()
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        let (_, (isPasswordActivated, timeBeforeLocking)) = settingsData.checkIfHideScreenAndPassword()
        // For this part of code, I troubleshoted all issues which can occur. In case of a failure, the rule is to do nothing. It can be an error of format, or totally normal if the password had just been activated.
        //
        let lastDate = SettingsData().getLastTimeAppIsClosed()
        if isPasswordActivated {
        if lastDate != nil { // else do nothing
            if lastDate!.keys.contains(DateInfosName.dateOfClose.key) && lastDate!.keys.contains(DateInfosName.hasBeenUnlocked.key) { // else, an error occured so we do noting. It will be corrected the next time user quit app
                if lastDate![DateInfosName.hasBeenUnlocked.key] == "false"{ // else, no need to ask authentification again
                    let date = Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
                    
                    let lastDateString = lastDate![DateInfosName.dateOfClose.key]
                    let dateString  = dateFormatter.string(from: date)
                    print("date = \(dateString), lastDate = \(String(describing: lastDateString))")
                    let newDate = (dateFormatter.date(from: dateString))
                    let lastDate = dateFormatter.date(from: lastDateString!)
                    if newDate != nil && lastDate != nil {
                        let diffInMins = Calendar.current.dateComponents([.minute], from: lastDate!, to: newDate!).minute
                        print("[*] Distance = \(String(describing: diffInMins))")
                        if diffInMins ?? 0 >= timeBeforeLocking { // Lock the app
                            performSegue()
                        }
                    }
                }
            }
        }
        }
    }
    
    func performSegue(){
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
        // topController should now be your topmost view controller
            print("title = \(String(describing: topController.title))")
            if let title = topController.title{
                if self.viewControllerTitleAllowedForSegue.contains(title) {
                    topController.performSegue(withIdentifier: "lockApp", sender: nil)
                }
            }
        }
    }
}

