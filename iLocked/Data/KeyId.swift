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
    let pem_format = "RSA 4096 PUBLIC"
    
    let queue = DispatchQueue.global(qos: .background)
    let log = LogFile(fileManager: FileManager())
    
    /// Return all key and id associated to saved keys
    /// - Data format = [keyName(String)]
    public func getKeyName() -> [String]{
        //Récupération des données enregistrées
        var arrayEncoded: String! = "nil"
        do {
            arrayEncoded = try String(contentsOf: URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]).appendingPathComponent(settingsPath.arrayNameId.path), encoding: .utf8)
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
            queue.async {
                try? self.log.write(message: "⚠️ ERROR002 ##DATA/KI.SWIFT#0002# : An internal error unables the application to access to your stored")
            }
            return ["##ERROR## An internal error unables the application to access to your stored data. Please, contact the developer with this error code : ##DATA/KI.SWIFT#0002# 🛠".localized(withKey: "error0002")]
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
    ///array looks like [id: nom]
    //
    public func stockNewNameIdArray(_ initialArray: [String]) {
        let array = initialArray
        print(array)
        //on convertie et enregistre
        let jsonArray = json(from: array as Any)
        print("json array = \(String(describing: jsonArray))")
        _ = FileManager.default.createFile(atPath: URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]).appendingPathComponent(settingsPath.arrayNameId.path).path, contents: "\(jsonArray!)".data(using: String.Encoding.utf8), attributes: nil)
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
    public func extract_key(_ key: String) -> String{
        if checkKeyValidity(key){
            var extracted = ""
            for i in self.start_key_format.count ..< (key.count - self.end_key_format.count){
                extracted += "\(key[i])"
            }
            return extracted
        } else {
            return key // No pem, so returned as is
        }
    }
    
    public func key_format(_ key : String) -> String{
        return self.start_key_format + key + self.end_key_format
    }
    
    /// Export a given key to the official pem format, in order to export it
    public func export_pem_format(_ key:String, isPrivate:Bool)-> String{
        let exctracted = extract_key(key)
        if isPrivate {
            return keyFormat.pem_private.start + exctracted + keyFormat.pem_private.end
        } else {
            return keyFormat.pem_public.start + exctracted + keyFormat.pem_public.end
        }
    }
    
    /// Extract a given key from the official pem format, in order to import it
    /// Then, the public key is padded with the iLocked format.
    public func extract_from_pem_format(_ keyText:String, isPrivate:Bool)-> String? {
        print("[*] Extraction of a key in PEM official format")
        var separatorStart = ""
        var separatorEnd = ""
        if isPrivate{
            separatorStart = keyFormat.pem_private.start.replacingOccurrences(of: " ", with: "")
            separatorEnd = keyFormat.pem_private.end.replacingOccurrences(of: " ", with: "")
        } else {
            separatorStart = keyFormat.pem_public.start.replacingOccurrences(of: " ", with: "")
            separatorEnd = keyFormat.pem_public.end.replacingOccurrences(of: " ", with: "")
        }
        let key = keyText.replacingOccurrences(of: " ", with: "") // We ignore space " "
        
        // extract key
        let splited_key_start = key.components(separatedBy: separatorStart)
        if splited_key_start.count == 2 {
            if splited_key_start[0].contains(separatorEnd){
                let splited_key_end = splited_key_start[0].components(separatedBy: separatorEnd)
                if splited_key_end.count == 2 {
                    return splited_key_end[0]
                } else {
                    queue.async {
                        try? self.log.write(message: "⚠️ [** Error **] No end detected while parsing. Splited_key_end = \(splited_key_end), Splited_key_start = \(splited_key_start)")
                    }
                    
                    print("[** Error **] No end detected while parsing. Splited_key_end = \(splited_key_end), Splited_key_start = \(splited_key_start)")
                    return nil
                }
            } else if splited_key_start[1].contains(separatorEnd) {
                let splited_key_end = splited_key_start[1].components(separatedBy: separatorEnd)
                if splited_key_end.count == 2 {
                    return splited_key_end[0]
                } else {
                    queue.async {
                        try? self.log.write(message: "⚠️ [** Error **] No end detected while parsing. Splited_key_end = \(splited_key_end), Splited_key_start = \(splited_key_start)")
                    }
                    
                    print("[** Error **] No end detected while parsing. Splited_key_end = \(splited_key_end), Splited_key_start = \(splited_key_start)")
                    return nil
                }
            } else {
                queue.async {
                    try? self.log.write(message: "⚠️ [** Error **] No end detected. Splited_key_start = \(splited_key_start)")
                }
                print("[** Error **] No end detected. Splited_key_start = \(splited_key_start)")
                return nil
            }
        } else {
            queue.async {
                try? self.log.write(message: "⚠️ [** Error **] No start detected. Splited_key_start = \(splited_key_start). Start separator = \(separatorStart)")
            }
            print("⚠️ [** Error **] No start detected. Splited_key_start = \(splited_key_start). Start separator = \(separatorStart)")
            return nil
        }
    }
    
}

public enum keyFormat{
    case pem_public
    case pem_private
    
    var start:String {
        switch self {
        case .pem_public:
            return "-----BEGIN PUBLIC KEY-----\n"
        case .pem_private:
            return "-----BEGIN PRIVATE KEY-----\n"
        }
    }
    var end:String {
        switch self {
        case .pem_public:
            return"\n-----END PUBLIC KEY-----"
        case .pem_private:
            return"\n-----END PRIVATE KEY-----"
        }
    }
}

