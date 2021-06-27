//
//  SettingsData.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 09/03/2020.
//  Copyright © 2020 Nathan. All rights reserved.
//

import Foundation

class SettingsData {
    
    /// Return all settings data saved in an array
    /// - Return : [*String:String*]
    func getSetting() -> [String: String]{
        var json = ""
        do {
            json = try String(contentsOf: URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]).appendingPathComponent(settingPath), encoding: .utf8)
            
        } catch {
           print("***ATTENTION***\n\n ***ERROR***\n\nImpossible to retrieve data.\n\n***************")
        }
        print("getSetting = \(json)")
        let dict = json.jsonToDictionary() ?? ["":""]
        return dict
    }
    
    ///**Give the model of saved dict**
    func saveSetting(dict: [String:String]){
        let dictExtension = DictionnaryExtension()
        let jsonString = dictExtension.dictionaryToJson(dict: dict)
        _ = FileManager.default.createFile(atPath: URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]).appendingPathComponent(settingPath).path, contents: "\(jsonString!)".data(using: String.Encoding.utf8), attributes: nil)
    }
}
    
public enum SettingsName : String { // List all key's name according to the corresponding setting
        case inAppBrowser
        case isPasswordActivated
        case X509Certificate
        
        var key : String {
            switch self {
            case .inAppBrowser:
                return "inAppBrowser"
            case .isPasswordActivated:
                return "password"
            case .X509Certificate:
                return "X509Certificate"
            }
        }
        
    }
