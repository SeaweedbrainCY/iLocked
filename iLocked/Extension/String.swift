//
//  String.swift
//  iLocked
//
//  Created by Nathan on 30/07/2019.
//  Copyright © 2019 Nathan. All rights reserved.
//

import Foundation

extension String {
        func toJSON() -> [String] {
            guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return [] }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String] {
                    return json
                }
            } catch {
               return[""]
            }
            return[""]
        }
    /// Convert a json string to a dictionnary [*String*:*String*]
    func jsonToDictionary() -> [String: String]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    /// Enable str[3] to return the 3rd char of a string
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
    
    func localized() -> String {
        return NSLocalizedString(self, tableName: "Localizable", bundle: .main, value: self, comment: self)
    }
    
    func localized(withKey key :String) -> String {
        return NSLocalizedString(key, tableName: "Localizable", bundle: .main, value: self, comment: self)
        
    }
    
   
        func sha256() -> String{
            if let stringData = self.data(using: String.Encoding.utf8) {
                return stringData.sha256()
            }
            return ""
        }


}
