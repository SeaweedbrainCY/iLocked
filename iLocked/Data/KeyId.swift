//
//  KeyId.swift
//  iLocked
//
//  Created by Nathan on 11/08/2019.
//  Copyright © 2019 Nathan. All rights reserved.
//

import Foundation

class KeyId {
    let  start_key_format = "-----BEGIN RSA 4096 PUBLIC KEY-----\n"
    let end_key_format = "\n-----END RSA 4096 PUBLIC KEY-----"
    
    /// Return all key and id associated to saved keys
    /// - Data format = [keyName(String)]
    public func getKeyName() -> [String]{
        //Récupération des données enregistrées
        var arrayEncoded: String! = "nil"
        do {
            arrayEncoded = try String(contentsOf: URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]).appendingPathComponent(arrayNameIdPath), encoding: .utf8)
        } catch {
            print("Fichier introuvable. ERREUR GRAVE line 211")
            arrayEncoded = "not found"
        }
        
        if arrayEncoded == "nil" {
            //
            // *************************************************************************
            // ERROR N° 0002
            // Une grave erreur s'est produite lors de l'accès à la sauvegarde ERROR
            // *************************************************************************
            //
            return ["##ERROR## An internal error unable the application to access to your stored data. Please, contact the developer with this error code : ##DATA/KI.SWIFT#0002# 🛠"]
        }
        
        if arrayEncoded == "not found" {
            return []
        }
        
        if arrayEncoded == "" {
            return []
        }
        
        
        let arrayDecoded: [String] = arrayEncoded.toJSON()  // convertion json->array
            print("dico decoded = \(arrayDecoded)")
            return arrayDecoded // succès
    }
    
    //
    ///Stock and remplace old data
    ///array de la forme [id: nom]
    //
    public func stockNewNameIdArray(_ initialArray: [String]) {
        let array = initialArray
        print(array)
        //on convertie et enregistre
        let jsonArray = json(from: array as Any)
        print("json array = \(String(describing: jsonArray))")
        _ = FileManager.default.createFile(atPath: URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]).appendingPathComponent(arrayNameIdPath).path, contents: "\(jsonArray!)".data(using: String.Encoding.utf8), attributes: nil)
    }
    
    
        //
       // data function
       //
       
       public func json(from object:Any) -> String? {
           guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
               return nil
           }
           return String(data: data, encoding: String.Encoding.utf8)
       }
    
    /// Sort by alphabetic order two list sgiven:
    /// - returns:[[*keys*], [*values*]] all sorted according to keys
    public func sortByAlphabeticOrder(keys : [String], value: [String]) -> [[String]] {
        //triage :
        let sortedNames = value.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
        var sortedKeys : [String] = []
        print("array sorted = \(sortedNames)")
        //On réinstancie l'array initial
        for i in 0 ..< sortedNames.count {
            sortedKeys.append(keys[value.firstIndex(of: sortedNames[i])!])
        }
        return [sortedKeys, sortedNames]
    }
    
    /// Check if a key is valid, ie if there is -----BEGIN RSA PUBLIC KEY----- and -----END RSA PUBLIC KEY-----  in the key
    /// - key : key to check
    public func checkKeyValidity(_ key:String) -> Bool{
        let begin = self.start_key_format
        let end = self.end_key_format
        if key.count >= begin.count + end.count{
            for i in 0 ..< begin.count {
                if begin[begin.index(begin.startIndex, offsetBy: i)] != key[key.index(key.startIndex, offsetBy: i)]{
                    return false
                }
            }
            for i in 0 ..< end.count {
                    if end[end.index(end.startIndex, offsetBy: i)] != key[key.index(key.startIndex, offsetBy: key.count - end.count + i)]{
                        return false
                    }
                }
        } else { // Length doesn't correspond
            return false
        }
        return true
    }
    
    /// Extrcat keys from their wrap
    public func extract_key(_ key: String) -> String?{
        if self.checkKeyValidity(key){
            var extracted = ""
            for i in self.start_key_format.count ..< (key.count - self.end_key_format.count){
                extracted += "\(key[i])"
            }
            return extracted
        } else {
            return nil
        }
    }
}


