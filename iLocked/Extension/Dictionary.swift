//
//  Dictionnary.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 17/02/2020.
//  Copyright © 2020 Nathan. All rights reserved.
//

import Foundation
import UIKit

class DictionnaryExtension {
    /// Return the first key correponding to the element given in argument
    /// - Parameters:
    ///   - of: Element corresponding to the key researched
    ///   - in: Dictionnray in which we want saerch the key
    /// - Returns: Same type as the key find. If there is no occurence, it's return *NSNull()*
    public func firstKey(of element : AnyObject, in array: [AnyHashable: AnyObject])-> AnyHashable {
        for (key, value) in array {
            if  element.isEqual(value){
                return key
            }
        }
        return NSNull()
    }
    

    
    /// Return the an array of keys correponding to the element given in argument
    /// - Warning:This function is iterative and can take a long time to be executed
    /// - Parameters:
    ///   - of: Element corresponding to the key researched
    ///   - in: Dictionnray in which we want saerch the key
    /// - Returns: Same type as the key find. If there is no occurence, it's return *[NSNull()]*
    public func listOfKeys(of element : AnyObject, in array: [AnyHashable: AnyObject])-> [AnyHashable] {
        var keys : [AnyHashable]?
        for (key, value) in array {
            if  element.isEqual(value){
                keys?.append(key)
            }
        }
        guard let list = keys else {
            return [NSNull()]
        }
        return list
    }
    
    /// Convert a dictionnary [*String*:*String*] to a  json string
    /// - Parameter dict: [*String*:*String*]
    func dictionaryToJson(dict: [String: String]) -> String? {
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: dict,
            options: []) {
            let JSONText = String(data: theJSONData, encoding: .ascii)
            return JSONText
        }
        return nil
    }
}
