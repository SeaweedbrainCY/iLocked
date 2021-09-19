//
//  SettingsData.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 09/03/2020.
//  Copyright © 2020 Nathan. All rights reserved.
//

import Foundation
import StoreKit

class SettingsData {
    
    /// Return all settings data saved in an array
    /// - Return : [*String:String*]
    func getSetting() -> [String: String]{
        var json = ""
        do {
            json = try String(contentsOf: URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]).appendingPathComponent(settingsPath.appSettings.path), encoding: .utf8)
            
        } catch {
           print("***ATTENTION***\n\n ***ERROR***\n\nImpossible to retrieve data.\n\n***************")
        }
        print("[*] Settings asked = \(json)")
        let dict = json.jsonToDictionary() ?? ["":""]
        return dict
    }
    
    ///**Give the model of saved dict**
    func saveSetting(dict: [String:String]){
        let dictExtension = DictionnaryExtension()
        let jsonString = dictExtension.dictionaryToJson(dict: dict)
        _ = FileManager.default.createFile(atPath: URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]).appendingPathComponent(settingsPath.appSettings.path).path, contents: "\(jsonString!)".data(using: String.Encoding.utf8), attributes: nil)
        print("[*] New settings saved : \(jsonString!)")
    }
    
    /// Save the last time the app was closed in order to deal with the app auto-lock and if the app has been unlocked scince the is has been re-opened
    public func saveLastTimeAppIsClosed(timesInfo: [String:String]){
        let dictExtension = DictionnaryExtension()
        let jsonString = dictExtension.dictionaryToJson(dict: timesInfo)
        _ = FileManager.default.createFile(atPath: URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]).appendingPathComponent(settingsPath.timeWhenClose.path).path, contents: "\(jsonString!)".data(using: String.Encoding.utf8), attributes: nil)
    }
    
    public func getLastTimeAppIsClosed() -> [String:String]? {
        var json = ""
        do {
            json = try String(contentsOf: URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]).appendingPathComponent(settingsPath.timeWhenClose.path), encoding: .utf8)
            
        } catch {
           print("***ATTENTION***\n\n ***ERROR***\n\nImpossible to retrieve data.\n\n***************")
            return nil
        }
        print("[*] Date asked = \(json)")
        let dict = json.jsonToDictionary() ?? ["":""]
        return dict
    }
    
    /// Check if screen has to be hidden in App Switcher
    ///  - Parameter :
    /// - Returns : (Bool, (Bool,int)) --> first if screen is hidden in App Switcher and the second if password is activated and the time before locking
    
    public func  checkIfHideScreenAndPassword() -> (Bool, (Bool,Int)) {
        let settings = getSetting()
        
        var password  = false
        var timeBeforeLocking = 0
        var isHiddenInAppSwitcher = false
        
        if let isHiddenScreen = settings[SettingsName.hideScreen.key], let isPasswordActivated = settings[SettingsName.isPasswordActivated.key] {
            if isHiddenScreen == "true" {
                isHiddenInAppSwitcher = true
            }
            if isPasswordActivated == "true" {
                password = true
                timeBeforeLocking = Int(settings[SettingsName.timeBeforeLocking.key]! as String)!
            }
        } else {
            return (true,(true,0))
        }
        return (isHiddenInAppSwitcher, (password, timeBeforeLocking))
    }
    
    /// Test and display (if the test is passed) the review request to the user
    /// It should be ask for all user after 10 relaods
    public func shouldAskForReview(){
        var count = UserDefaults.standard.integer(forKey: settingsPath.ratingRequest.path)
        count += 1
        print("[*] Check for review")
        // Get the current bundle version for the app
        let infoDictionaryKey = kCFBundleVersionKey as String
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String
            else {return}
        
        var  lastVersionPromptedForReview: String = ""
        lastVersionPromptedForReview = UserDefaults.standard.string(forKey: settingsPath.lastVersionPromptedForReview.path) ?? ""
        
        if count >= 5 && lastVersionPromptedForReview != currentVersion{
            print("[****] REQUEST FOR RATE REVIEW (before queue)")
            let twoSecondsFromNow = DispatchTime.now() + 2.0
                DispatchQueue.main.asyncAfter(deadline: twoSecondsFromNow) {[] in
                    print("[****] REQUEST FOR RATE REVIEW")
                    SKStoreReviewController.requestReview()
                    UserDefaults.standard.set(currentVersion, forKey: settingsPath.lastVersionPromptedForReview.path)
                }
        }
    }
}
    
public enum SettingsName : String { // List all key's name according to the corresponding setting
        case inAppBrowser
        case isPasswordActivated
        case X509Certificate
        case hideScreen
        case timeBeforeLocking
        
        var key : String {
            switch self {
            case .inAppBrowser:
                return "inAppBrowser"
            case .isPasswordActivated:
                return "password"
            case .X509Certificate:
                return "X509Certificate"
            case .hideScreen:
                return "hideScreen"
            case .timeBeforeLocking:
                return "timeBeforeLocking"
            }
        }
        
    }

public enum settingsPath : String{
    case appSettings
    case timeWhenClose
    case arrayNameId
    case logError
    case ratingRequest
    case lastVersionPromptedForReview
    
    var path : String{
        switch self {
        case .appSettings :
            return "setting.txt"
        case .timeWhenClose:
            return "time.txt"
        case .arrayNameId :
            return "arrayNameId.txt"
        case.logError :
            return "logError.txt"
        case .ratingRequest:
            return "ratingRequest"
        case .lastVersionPromptedForReview:
            return "lastVersionPromptedForReview"
        }
    }
}

/// Key related to the number of times the User encrypt or decrupt a text
/// It's used for ask for (an optionnal) support after a given amount of encryption/decryption
public enum UserStat: String {
    case decryption
    case encryption
    
    var key: String{
        switch self {
        case .decryption:
            return "decryption"
        case .encryption:
            return "encryption"
        }
    }
}

public enum DateInfosName{
    case dateOfClose
    case hasBeenUnlocked
    
    var key : String{
        switch self {
        case .dateOfClose :
            return "dateOfClose"
        case .hasBeenUnlocked :
            return "hasBeenUnlocked"
        }
    }
}
