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


class Decryption {
    
    // Code error corresponding to the differents possible error
    // Code 0 is reserved to state = true
    let noCodeError = 0
    let codeErrorFormatInvalid = 1 // if the key format in invalid
    let codeErrorNoPrivateKey = 2 // if we are unable to access to the user private key
    let codeErrorKeyIncorrect = 3 // if the key ins't the rigth key to decrypt the given text
    
    let queue = DispatchQueue.global(qos: .background)
    let log = LogFile(fileManager: FileManager())
    
    ///This function return the decrypted text of a String given
    /// - return : A dictionnary containing ONLY two keys : "state" : Bool (True if success, False if not) and "message" : String(The message according to the error or the result asked for)
    public func decryptText(_ text:String) -> [String: Any]{
        let (test,extracted_text) = extractEncryptedMessageFormat(text)
        print("Extracted text : \(extracted_text)")
        if !test{
            return ["state" : false, "codeError" : self.codeErrorFormatInvalid, "message" : "The format of this encrypted text isn't correct. Please try only to decrypt message previoulsy encrypted with the iLocked app.".localized(withKey: "formatKeyDecryptionMessage")]
        }
        do {
            let decrypted = try EncryptedMessage(base64Encoded: extracted_text)
            if let privateKey: String = KeychainWrapper.standard.string(forKey:  UserKeys.privateKey.tag) {
                print(privateKey)
                
                do {
                    let clear = try decrypted.decrypted(with: PrivateKey(base64Encoded: privateKey), padding: .PKCS1)
                    
                    return ["state" : true,"codeError" : self.noCodeError, "message" : try clear.string(encoding: .utf8)]
                } catch {
                    queue.async {
                        try? self.log.write(message: "Tried to decrypt a message. Impossible to decrypt. The private key isn't the right one. This should not be an error. Message thrown = \(error)")
                    }
                    return ["state" : false, "codeError" : self.codeErrorKeyIncorrect, "message": "Your cannot decrypt this text. You don't have the right key. Please ensure this message has been encrypted with YOUR public key".localized(withKey: "can'tDecryptErrorMessage")]
                    
                }
                
            } else {
                queue.async {
                    try? self.log.write(message: "⚠️ ERROR while decrypting. Operation aborted. Impossible to access to the user's private key")
                }
                return ["state" : false, "codeError" : self.codeErrorNoPrivateKey, "message" : "iLocked can't access to your private Key".localized(withKey: "can'tAccessErrorMessage")]
            }
            
        } catch {
            queue.async {
                try? self.log.write(message: "Tried to decrypt a message. Impossible to decrypt. The private key isn't the right one. This should not be an error. Message thrown = \(error)")
            }
            return ["state" : false, "codeError" : self.codeErrorKeyIncorrect, "message": "Your cannot decrypt this text. You don't have the right key. Please ensure this message has been encrypted with YOUR public key".localized(withKey: "can'tDecryptErrorMessage")]
        }
    }
    
    
    ///
    /// Extract the encrypted message from the encrypted format
    ///
    ///     - encrypted : encrypted text padded
    ///     - return : Clear encrypted text. Bool = false if the key format isn't correct. If it is, Bool = true
    public func extractEncryptedMessageFormat(_ encrypted: String) -> (Bool,String) {
        if encrypted == ""{
            return (false,"")
        }
        let start = Encryption().start_encrypted_format
        let end = Encryption().end_encrypted_format
        
        // Verify that encrypted length is at least superior to start length + en length
        if start.count + end.count > encrypted.count{
            return (false,"")
        }
        var extracted: String = ""
        var i_2sd_test = 0
                for i in 0 ..< encrypted.count{
                    if i < start.count{
                        //
                        // Start test for the beginning
                        //
                        if start[start.index(start.startIndex, offsetBy: i)] != encrypted[encrypted.index(encrypted.startIndex, offsetBy: i)]{ // If there is a different char
                            return (false,"")
                        }
                    } else if encrypted.count - i <= end.count{
                        //
                        // Start test for the end
                        //
                        if end[end.index(end.startIndex, offsetBy: i_2sd_test)] != encrypted[encrypted.index(encrypted.startIndex, offsetBy: i)]{// If there is a different char
                            return (false,"")
                        }
                        i_2sd_test += 1
                    } else {
                        //
                        // We are considering the key, so we save it
                        //
                        extracted += String(encrypted[encrypted.index(encrypted.startIndex, offsetBy: i)])
                    }
                }
        //The two tests are passed
        return (true, extracted)
    }
    
}
