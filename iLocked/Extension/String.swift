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
        print("[*] jsonToDictionnary : text given = \(self)")
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
}
