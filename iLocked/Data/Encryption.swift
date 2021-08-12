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
    
    let  start_encrypted_format = "-----BEGIN RSA ILOCKED ENCRYPTED MESSAGE-----\n"
    let end_encrypted_format = "\n-----END RSA ILOCKED ENCRYPTED MESSAGE-----"
    
    ///This func return the encryption of the text givent
    /// - text : The text to encrypt
    /// - withKeyId : The name displayed to the user, if it's user's key, its "My encryption key"
    public func encryptText(_ text: String, withKeyName keyUsed : String) -> String{
        var publicKeyUsed = ""
        if keyUsed == "My encryption key".localized() {
            publicKeyUsed =  UserKeys.publicKey.tag
        } else {
            publicKeyUsed = keyUsed
        }
        if let publicKey: String = KeychainWrapper.standard.string(forKey: publicKeyUsed) {
                let extractedKey: String = KeyId().extract_key(publicKey)
                    print("\n\nExtraced key = '\(extractedKey)'")
                do {
                    let keyData = try SwiftyRSA.stripKeyHeader(keyData:  PublicKey(base64Encoded: extractedKey).data()) // get rid of X509 certificate
                    print("stripped key = \(try PublicKey(data: keyData).base64String())")
                    let clear = try ClearMessage(string: text, using: .utf8)
                    let encrypted = try clear.encrypted(with: PublicKey(data: keyData), padding: .PKCS1)
                    return self.start_encrypted_format + encrypted.base64String + self.end_encrypted_format
                }catch {
                    return "ERROR : Please verify that your public key is correct".localized()
                }
        } else {
            return "ERROR : Impossible to get the public key associated".localized()
        }
    }
}
