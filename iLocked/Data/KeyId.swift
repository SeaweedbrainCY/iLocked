//
//  KeyId.swift
//  iLocked
//
//  Created by Nathan on 11/08/2019.
//  Copyright © 2019 Nathan. All rights reserved.
//

import Foundation

class KeyId {
    
    /// Return all key and id associated to saved keys
    /// - Data format = [id(String) : keyName(String)]
    public func getKeyIdArray() -> [String: String]{
        //Récupération des données enregistrées
        var dicoEncoded: String! = "nil"
        do {
            dicoEncoded = try String(contentsOf: URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]).appendingPathComponent(arrayNameIdPath), encoding: .utf8)
        } catch {
            print("Fichier introuvable. ERREUR GRAVE line 211")
            dicoEncoded = "not found"
        }
        
        if dicoEncoded == "nil" {
            //
            // *************************************************************************
            // ERROR N° 0002
            // Une grave erreur s'est produite lors de l'accès à la sauvegarde ERROR
            // *************************************************************************
            //
            return ["##ERROR##" : "An internal error unable the application to access to your stored data. Please, contact the developer with this error code : ##DATA/KI.SWIFT#0002# 🛠"]
        }
        
        if dicoEncoded == "not found" {
            return [:]
        }
        
        if dicoEncoded == "" {
            return [:]
        }
        
        
        if let dicoDecoded: [String: String] = dicoEncoded.convertToDictionary(text: dicoEncoded!)  { // convertion json->array
            return dicoDecoded // succès
                
            } else {
                // La portion décodé n'est pas compatible
            return ["##ERROR##" : "We are unabled to read your saved data. They may be corrupted. If you see this error several times, please contact the developer in app's settings and report this warning 🚔"]
                
            }
    }
    
    //
    ///Stock and remplace old data
    ///array de la forme [id: nom]
    //
    public func stockNewNameIdArray(_ initialArray: [String: String]) {
        let array = initialArray
        //on convertie et enregistre
        let jsonArray = json(from: array as Any)
        print("json array = \(String(describing: jsonArray))")
        let file = FileManager.default
        file.createFile(atPath: URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]).appendingPathComponent(arrayNameIdPath).path, contents: "\(jsonArray!)".data(using: String.Encoding.utf8), attributes: nil)
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
}


