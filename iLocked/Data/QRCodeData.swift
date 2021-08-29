//
//  QRCodeData.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 30/08/2021.
//  Copyright © 2021 Nathan. All rights reserved.
//

import Foundation

class QRCodeData {
    ///
    /// The version mention helps the decoder if different formats are used
    ///
    
    /*
     ***** VERSION 1 *****
        Created : 30/08/21
        By : Nathan Stchepinsky
        Dico used :
                [
                "Version" : "1",
                "Type" : "pubKey", //example
                "Data" : "----BEGIN [...]",
                "Checksum" : "IJHDNLK[...]"
            ]
        Hash : SHA256. Used on the JSON of the 3 first keys (and values)
        PubKey : The one displayed to the user
     */
    
    enum QRCodeData {
        case version
        case type
        case data
        case checksum
        
        var key : String{
            switch self {
            case .version:
                return "Version"
            case .type:
                return "Type"
            case .data :
                return "Data"
            case .checksum:
                return "Checksum"
            }
        }
        
        var current:String{
            switch self {
            case .version:
                return "1"
            default:
                return ""
            }
        }
        
        var pubKey:String{
            switch self {
            case .type:
                return "Public key"
            default:
                return ""
            }
        }
    }
    
    let background = DispatchQueue.global(qos: .background)
    let log = LogFile(fileManager: FileManager())
    
    
    public func getQRCodeTextFromPublicKey(_ publicKey:String) -> String? {
        var infos = [
            QRCodeData.version.key : QRCodeData.version.current,
            QRCodeData.type.key : QRCodeData.type.pubKey,
            QRCodeData.data.key : publicKey
        ]
        
        guard let jsonInfos = infos.toJson() else { // To calcul the checksum
            background.async {
                try? self.log.write(message: "⚠️ ERROR. Impossible to generate the QR Code : The data are not convertible into JSON. Porcess aborted.")
            }
            return nil
        }
        let checksum = jsonInfos.sha256()
        infos.updateValue(checksum, forKey: QRCodeData.checksum.key)
        guard let finalJson = infos.toJson() else {
            background.async {
                try? self.log.write(message: "⚠️ ERROR. Impossible to generate the QR Code : The data are not convertible into JSON. Porcess aborted. Checksum = \(checksum)")
            }
            return nil
        }
        return finalJson
    }
}
