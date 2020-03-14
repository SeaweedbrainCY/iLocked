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
    public func extractData() -> [String: String]{
        var settingData :String? = nil
        do {
            settingData = try String(contentsOf: URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]).appendingPathComponent(settingPath), encoding: .utf8)
        } catch {
            return ["Error" : "Impossible to get settings' data"]
        }
        if settingData != nil {
            if let dictionnary : [String: String] = settingData!.JsonToDictionary() {
                return dictionnary
            } else {
                return ["Error" : "Impossible to get settings' data"]
            }
        } else {
            return ["Error" : "Impossible to get settings' data"]
        }
    }
    
   
    
}
