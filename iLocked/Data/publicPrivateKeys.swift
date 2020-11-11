//
//  publicPrivateKeys.swift
//  iLocked
//
//  Created by Nathan on 25/10/2019.
//  Copyright © 2019 Nathan. All rights reserved.
//

import Foundation
import UIKit



/// This class manage creation, stock, access to the differents keys
class PublicPrivateKeys {
    
    public func generateAndStockKeyUser() -> Bool{
        do {
            let keyPair = try SwiftyRSA.generateRSAKeyPair(sizeInBits: 2048)
            let privateKeyString = keyPair.privateKey
            let publicKeyString = keyPair.publicKey
            let privateKey64 = try keyPair.privateKey.base64String()
            let publicKey64 = try keyPair.publicKey.base64String()
            let privateKeyPadded = "-----BEGIN RSA PRIVATE KEY-----\n" + privateKey64 + "\n-----END RSA PRIVATE KEY-----\n"
            let publicKeyPadded = "-----BEGIN RSA PUBLIC KEY-----\n" + publicKey64 + "\n-----END RSA PUBLIC KEY-----"
            
            if verifyIfKeysWork(privateKey: privateKeyString, publicKey: publicKeyString){ // verify if key works
                let saveSuccessfulPrivateKey = KeychainWrapper.standard.set(privateKeyPadded, forKey: userPrivateKeyId)
                let saveSuccessfulPublicKey = KeychainWrapper.standard.set(publicKeyPadded, forKey: userPublicKeyId)
                if saveSuccessfulPublicKey && saveSuccessfulPrivateKey {
                    return true
                } else{return false}
            } else {
                print("Keys don't decrypt the message")
                return false
            }
        }catch{
            print("An error occur with one 'try'")
            return false
        }
    }
}

private func verifyIfKeysWork(privateKey: PrivateKey, publicKey: PublicKey)-> Bool{
    do{
        let text = "Some random text"
        var clear = try ClearMessage(string: text, using: .utf8)
        var encrypted = try clear.encrypted(with: publicKey, padding: .PKCS1)
        encrypted = try EncryptedMessage(base64Encoded: encrypted.base64String)
        clear = try encrypted.decrypted(with: privateKey, padding: .PKCS1)
        
        if try clear.string(encoding: .utf8) == text {
            return true
        } else {
            return false
        }
    } catch {
        return false
    }
}

/*Method to verify if keys works
 print("private key = \( try privateKeyString.base64String())")
     print("public key = \(try publicKeyString.base64String())")
 
     let text = "Je m'appelle Nathan Stchépinsky\n\n"
     var clear = try ClearMessage(string: text, using: .utf8)
     print("Message = Je m'appelle Nathan Stchépinsky\n\n")
     var encrypted = try clear.encrypted(with: publicKeyString, padding: .PKCS1)
 
 
     print("Data encrypted = \(encrypted.base64String)\n\n")
 
     encrypted = try EncryptedMessage(base64Encoded: encrypted.base64String)
     clear = try encrypted.decrypted(with: privateKeyString, padding: .PKCS1)
     print("clear =\( try clear.string(encoding: .utf8))")
 */
