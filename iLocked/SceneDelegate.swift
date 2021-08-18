//
//  SceneDelegate.swift
//  iLocked
//
//  Created by Nathan on 13/10/2019.
//  Copyright © 2019 Nathan. All rights reserved.
//

import UIKit
import InAppPurchaseLib

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    let viewControllerTitleAllowedForSegue = ["MainTabBarController", "EncryptHomePage","addKeyNavCrtl","AddKeyCrtl","PublicKeyList","PublicKeyView","SettingsView", "AdvancedSettingsView","developerView","DecryptHomePage","DecryptResult","DecryptResult"]
    // List of the titles of the VC that can perform a segue named "lockApp"
    
    let settingsData = SettingsData()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
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

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        let (isHidden, (_, _)) = settingsData.checkIfHideScreenAndPassword()
        print("[*] isHidden, isPasswordActivated, timeBeforeLocking = \((isHidden)),(_, _)))")
        if isHidden {
            //Is called when the app move to background OR is in app switcher
            self.performSegue()
        }
        
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
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

    func sceneDidEnterBackground(_ scene: UIScene) {
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

