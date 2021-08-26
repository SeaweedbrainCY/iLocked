//
//  publicPrivateKeys.swift
//  iLocked
//
//  Created by Nathan on 25/10/2019.
//  Copyright © 2019 Nathan. All rights reserved.
//

import Foundation



/// This class manage creation, stock, access to the differents keys
class PublicPrivateKeys {
    
    let log = Logs()
    
    public func generateAndStockKeyUser() -> Bool{
        log.storeLog(message: "Start generating a key pair")
        do {
            let keyPair = try SwiftyRSA.generateRSAKeyPair(sizeInBits: 4096)
            let privateKey = keyPair.privateKey
            let publicKey = keyPair.publicKey
            let privateKey64 = try privateKey.base64String()
            let public_key_x509 : Data = try publicKey.data().prependx509Header()
            let x509key64 = public_key_x509.base64EncodedString() // x509 certificate
            print("[*] X509 : \(x509key64)")
            let publicKeyFormat = KeyId().key_format(x509key64)
            
            if verifyIfKeysWork(privateKey: privateKey, publicKey: try PublicKey(base64Encoded: x509key64)){ // verify if key works
                let saveSuccessfulPrivateKey = KeychainWrapper.standard.set(privateKey64, forKey: UserKeys.privateKey.tag)
                let saveSuccessfulPublicKey = KeychainWrapper.standard.set(publicKeyFormat, forKey: UserKeys.publicKey.tag)
                if saveSuccessfulPublicKey && saveSuccessfulPrivateKey {
                    return true
                } else{return false}
            } else {
                var logMessage = ""
                var i = 0
                while logMessage != "success" && i<20{
                    logMessage = log.storeLog(message: "**FATAL ERROR** The key pair generated isn't correct.They will e  destroyed. privateKey64 = \(privateKey64). X509 public key = \(x509key64).")
                    i += 1
                }
               
                print("[*] An error occur while verifying keys")
                print("[*] privateKey64 = \(privateKey64)")
                print("[*] X509 public key = \(x509key64)")
                return false
            }
        }catch{
            var logMessage = ""
            var i = 0
            while logMessage != "success" && i<20{
                logMessage = log.storeLog(message: "**FATAL ERROR** Impossible to generate a key. Error message : \(error)")
                i += 1
            }
           
            print("[*] An error occur while creating a key")
            return false
        }
    }
    
    
    public func verifyIfKeysWork(privateKey: PrivateKey, publicKey: PublicKey)-> Bool{
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
}

enum UserKeys: String{
    case publicKey
    case privateKey
    
    var tag: String {
        switch self{
        case .privateKey :
            return "userPrivateKeyId"
        case .publicKey :
            return "userPublicKeyId"
        }
    }
}
