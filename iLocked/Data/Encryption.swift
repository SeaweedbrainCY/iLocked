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
    /// - withKeyId : The name displayed to the user, if it's user's key, its 'userPublicKey'
    public func encryptText(_ text: String, withKeyId keyUsed : String) -> String{
        let keyIdMethod = KeyId()
        let keyIdList = keyIdMethod.getKeyIdArray()
        print(keyIdList)
        var publicKeyUsed = ""
        for (id, name) in keyIdList{
            print("name = \(name)")
            print("id = \(id)")
            if name == keyUsed{
                publicKeyUsed = id
                print("key found")
            }
        }
        if keyUsed == "userPublicKey" {
            publicKeyUsed = userPublicKeyId
        }
        if publicKeyUsed == ""  {
            return "ERROR : The key given cannot be found."
        }
        if let publicKey: String = KeychainWrapper.standard.string(forKey: userPublicKeyId) {
            do {
                let clear = try ClearMessage(string: text, using: .utf8)
                let encrypted = try clear.encrypted(with: PublicKey(base64Encoded: publicKey), padding: .PKCS1)
                return encrypted.base64String
            } catch {
                return "ERROR : An error occur"
            }
        } else {
            return "ERROR : Impossible to get the public key associated"
        }
    }
}
