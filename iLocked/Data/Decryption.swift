//
//  Decryption.swift
//  iLocked
//
//  Created by Nathan on 26/10/2019.
//  Copyright © 2019 Nathan. All rights reserved.
//

import Foundation
import UIKit
import SwiftyRSA
import SwiftKeychainWrapper

class Decryption {
    ///This function return the decrypted text of a String given
    func decryptText(_ text:String) -> String{
        do {
            let decrypted = try EncryptedMessage(base64Encoded: text)
            if let privateKey: String = KeychainWrapper.standard.string(forKey: userPrivateKeyId) {
                let clear = try decrypted.decrypted(with: PrivateKey(base64Encoded: privateKey), padding: .PKCS1)
                return try clear.string(encoding: .utf8)
            } else {
                return "iLocked can't access to your private Key"
            }
            
        } catch {
            return "An error occur while decrypting the text"
        }
    }
}
