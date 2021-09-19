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
            ***************************************************************
            *************************** WARNING ***************************
            ***************************************************************
            ******* MUST BE RED BEFORE CREATE A NEW QRCODE ENCODING *******
            ***************************************************************
            ***************************************************************
     
     This class encode, decode a QRCode.
     
     A version is attributed to a documented (below) format.
     
     The following rules MUST be respected, in all time
        
                            
                                *********** RULES *********
     When a version is used on production,
        1 - It MUST be documented here, and
     
        2 - The decoding func MUST remain here
     
        3 - The encoded string MUST be
                    * In JSON
        4 - The decoded string MUST
                    * Be a dictionnary of strings of type [String: String]
                    * Contain a key named "Version" which details the version number
     */
    
    
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
        Hash : SHA256. Used on the JSON of the 3 first values concanated
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
                return "Version" // MUST NEVER CHANGE
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
        
        let checksum = checksumVersion1(version: QRCodeData.version.current, type: QRCodeData.type.pubKey, key: publicKey)
        infos.updateValue(checksum, forKey: QRCodeData.checksum.key)
        guard let finalJson = infos.toJson() else {
            background.async {
                try? self.log.write(message: "⚠️ ERROR. Impossible to generate the QR Code : The data are not convertible into JSON. Porcess aborted. Checksum = \(checksum)")
            }
            return nil
        }
        return finalJson
    }
    
    // MUST NEVER BE DELETED
    public func decodeQrCodeText(_ text: String) throws -> [String:String]{
        guard let data: [String: String] = text.jsonToDictionary() else {
            print("incorrect json")
            throw qrCodeError.incorrectJSON
        }
        
        guard let version = data[QRCodeData.version.key] else {
            throw qrCodeError.unknownVersion
        }
        
        
        switch version {
        case "1" :
            return try decodeVersion1(data)
        default:
            throw qrCodeError.unknownVersion
        }
    }
    
    private func decodeVersion1(_ data: [String: String]) throws -> [String:String] {
        
        guard let checksum = data[QRCodeData.checksum.key] else {
            throw qrCodeError.noChecksum
        }
        
        guard let type = data[QRCodeData.type.key] else {
            throw qrCodeError.unknownType
        }
        
        guard let version = data[QRCodeData.version.key] else {
            throw qrCodeError.unknownVersion
        }
        
        guard let key = data[QRCodeData.data.key] else {
            throw qrCodeError.noKey
        }
        
        let newChecksum = checksumVersion1(version: version, type: type, key: key)
        guard checksum == newChecksum else {
            throw qrCodeError.invalideChesksum
        }
        
        return data
    }
    
    func checksumVersion1(version: String, type:String, key:String) -> String {
        let str = version + type + key
        return str.sha256()
    }
    
}

enum qrCodeError : Error, LocalizedError, CustomNSError{
    case unknownVersion
    case invalideChesksum
    case unknownType
    case incorrectJSON
    case noChecksum
    case noKey
    
    var localizedDescription : String{
        switch self {
        case .unknownVersion :
            return "The data cannot be decoded because the version of the qrCode is unknown."
            
        case .invalideChesksum :
            return "The checksum of the qrCode data isn't correct. The data may be corupted."
            
        case .unknownType:
            return "The data cannot be decoded because the type of the qrCode data is unknown."
            
        case .incorrectJSON:
            return "The provided JSON cannot be decoded."
            
        case .noChecksum:
            return "There is no checksum in the provided data. "
            
        case .noKey:
            return "There is no key in the provided data. "
            
        }
    }
}
