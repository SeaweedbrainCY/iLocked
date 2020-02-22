//
//  Decryption.swift
//  iLocked
//
//  Created by Nathan on 26/10/2019.
//  Copyright © 2019 Nathan. All rights reserved.
//

import Foundation
import UIKit



class Decryption {
    ///This function return the decrypted text of a String given
    /// - return : A dictionnary containing ONLY two keys : "state" : Bool (True if success, False if not) and "message" : String(The message according to the error or the result asked for)
    func decryptText(_ text:String) -> [String: Any]{
        do {
            
            let decrypted = try EncryptedMessage(base64Encoded: text)
            if let privateKey: String = KeychainWrapper.standard.string(forKey: userPrivateKeyId) {
                let clear = try decrypted.decrypted(with: PrivateKey(base64Encoded: privateKey), padding: .PKCS1)
                return ["state" : true, "message" : try clear.string(encoding: .utf8)]
            } else {
                return ["state" : false, "message" : "iLocked can't access to your private Key"]
            }
            
        } catch {
            return ["state" : false, "message": "Your cannot decrypt this text. You don't have the right key. Please ensure this message has been encrypted with YOUR public key"]
        }
    }
}
