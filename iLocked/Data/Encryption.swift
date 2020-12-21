//
//  Encryption.swift
//  iLocked
//
//  Created by Nathan on 26/10/2019.
//  Copyright © 2019 Nathan. All rights reserved.
//

import Foundation
import UIKit



class Encryption{
    ///This func return the encryption of the text givent
    /// - text : The text to encrypt
    /// - withKeyId : The name displayed to the user, if it's user's key, its "My encryption key"
    public func encryptText(_ text: String, withKeyName keyUsed : String) -> String{
        var publicKeyUsed = ""
        if keyUsed == "My encryption key" {
            publicKeyUsed = userPublicKeyId
        } else {
            publicKeyUsed = keyUsed
        }
        if let publicKey: String = KeychainWrapper.standard.string(forKey: publicKeyUsed) {
            do {
                if let extractedKey = KeyId().extract_key(publicKey){
                    print("\n\nExtraced key = '\(extractedKey)'")
                    let clear = try ClearMessage(string: text, using: .utf8)
                    let encrypted = try clear.encrypted(with: PublicKey(base64Encoded: extractedKey), padding: .PKCS1)
                    return encrypted.base64String
                } else {
                    return "ERROR : Please verify that your public key is correct"
                }
            } catch {
                return "ERROR : Please verify that your public key is correct"
            }
        } else {
            return "ERROR : Impossible to get the public key associated"
        }
    }
}
