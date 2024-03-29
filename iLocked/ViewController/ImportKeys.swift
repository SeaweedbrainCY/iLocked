//
//  ImportKeys.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 31/07/2021.
//  Copyright © 2021 Nathan. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import SwiftyRSA

class ImportKeys:UIViewController, UITextViewDelegate, UIDocumentPickerDelegate
 {
    
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var textToImport : UITextView!
    @IBOutlet weak var txtFileButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var checkMark: UIImageView!
    @IBOutlet weak var pasteButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var checkmarkBackground : UIView!
    @IBOutlet weak var successLabel : UILabel!
    
    let placeHolder = "Paste your keys here".localized()
    
    let queue = DispatchQueue.global(qos: .background)
    let log = LogFile(fileManager: FileManager())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textToImport.delegate = self
        self.activityIndicator.layer.cornerRadius = 10
        self.checkMark.layer.cornerRadius = 10
        self.importButton.layer.cornerRadius = 20
        self.checkmarkBackground.layer.cornerRadius = 20
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeHolder{
            textView.text = ""
            textView.textColor = UIColor.white
        }
    }

    func alert(_ title: String, message: String, quitMessage: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: quitMessage, style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func textViewDidEndEditing(_ textView: UITextView){
        if textView.text == "" {
            textView.text = placeHolder
            textView.textColor = .darkGray
        }
    }
    
    //
    // IBAction func
    //
    
    @IBAction func importTxtSelected(sender: UIButton) {
        let picker = UIDocumentPickerViewController.init(documentTypes: [String(kUTTypeText)], in: .open)
        picker.delegate = self
        picker.modalPresentationStyle = .fullScreen
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func importKeysSelected(sender: UIButton){
        if textToImport.text == "" || textToImport.text == self.placeHolder {
            alert("Paste your keys (in text format) to import them".localized(), message: "Paste the text generated by iLocked while exporting your keys. iLocked supports .txt, human readable and JSON formats.".localized(withKey: "pasteKeyErrorMessage"), quitMessage: "Ok")
        } else {
            extractKeysFromString(textToImport.text)
        }
        
    }
    
    @IBAction func backButtonSelected(sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pasteButtonSelected(sender: UIButton){
        let content = UIPasteboard.general.string
        if content == "" || content == nil{
            print("Nothing to paste")
            alert("Nothing to paste".localized(), message: "", quitMessage: "Ok")
        } else {
            print("Clipboard = \(String(describing: content))")
            self.textViewDidBeginEditing(self.textToImport)
            self.textToImport.text = content
            self.textViewDidEndEditing(self.textToImport)
        }
    }
    
    @IBAction func clearButtonSelected(sender: UIButton){
        self.view.endEditing(true)
        textToImport.text = self.placeHolder
    }
    
    //
    // Delegate func
    //
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]){
        guard let myURL = urls.first else {
            impossibleToRetrieveTxt()
            return
        }
        print("import result : \(myURL.relativePath)")
        let isAccessing = myURL.startAccessingSecurityScopedResource()
        do {
            let contents = try String(contentsOfFile: myURL.relativePath, encoding: .utf8)
            if isAccessing {
                myURL.stopAccessingSecurityScopedResource()
            }
                
            let myStrings = contents.components(separatedBy: .newlines)
                    let text = myStrings.joined(separator: "\n")
            print(text)
            self.activityIndicator.startAnimating()
            extractFromTxt(text)
                } catch {
                    print(error)
                    impossibleToRetrieveTxt()
                }
    }
    
    //
    // Keys dealing func (.txt)
    //
    
    func extractFromTxt(_ text:String){
        let public_start = keyFormat.pem_public.start
        let public_end = keyFormat.pem_public.end
        let private_start = keyFormat.pem_private.start
        let private_end = keyFormat.pem_private.end
        
        
        var publicKey :String? = nil
        var privateKey : String? = nil
        
        
        // extract public key
        let splited_public_start = text.components(separatedBy: public_start)
        if splited_public_start.count == 2 {
            if splited_public_start[0].contains(public_end){
                let splited_public_end = splited_public_start[0].components(separatedBy: public_end)
                if splited_public_end.count == 2 {
                    publicKey = splited_public_end[0]
                } else {
                    impossibleToExtractKeys()
                }
            } else if splited_public_start[1].contains(public_end) {
                let splited_public_end = splited_public_start[1].components(separatedBy: public_end)
                if splited_public_end.count == 2 {
                    publicKey = splited_public_end[0]
                } else {
                    impossibleToExtractKeys()
                }
            } else {
                impossibleToExtractKeys()
            }
        } else {
            impossibleToExtractKeys()
        }
        
        // extract private key
        let splited_private_start = text.components(separatedBy: private_start)
        if splited_private_start.count == 2 {
            if splited_private_start[0].contains(private_end){
                let splited_private_end = splited_private_start[0].components(separatedBy: private_end)
                if splited_private_end.count == 2 {
                    privateKey = splited_private_end[0]
                } else {
                    
                    impossibleToExtractKeys()
                }
            } else if splited_private_start[1].contains(private_end) {
                let splited_private_end = splited_private_start[1].components(separatedBy: private_end)
                if splited_private_end.count == 2 {
                    privateKey = splited_private_end[0]
                } else {
                    print("[*] ")
                    impossibleToExtractKeys()
                }
            } else {
                impossibleToExtractKeys()
            }
        } else {
            impossibleToExtractKeys()
        }
        
        if publicKey != nil && privateKey != nil {
            print("Success to extract keys")
            publicKey = KeyId().key_format(publicKey!)
            saveKeys(publicKey: publicKey!, privateKey: privateKey!, isX509Given: nil)
        } else {
            impossibleToExtractKeys()
        }
        
    }
    
    
    /// Save the public and private key of the user. Keys have to be checked before this func. It only stores them and check if they are correctly stocked.
    ///  It deals with error while storing and perform the segue in case of success
    ///
    ///  - Parameters:
    ///     - publicKey : The public key, base64 encoded
    ///     - privateKey : The private key, base64 encoded
    ///     - isX509 : Optional. Nil if we have to check, bool value if we already know. The func store the result and test if necessary
    func saveKeys(publicKey:String, privateKey: String, isX509Given: Bool?){
        print("[*] Saving your keys")
        self.importButton.isEnabled = false
        let saveSuccessfulPrivateKey = KeychainWrapper.standard.set(privateKey, forKey: UserKeys.privateKey.tag)
        let saveSuccessfulPublicKey = KeychainWrapper.standard.set(publicKey, forKey: UserKeys.publicKey.tag)
        if !saveSuccessfulPrivateKey && !saveSuccessfulPublicKey {
            self.activityIndicator.stopAnimating()
            alert("Impossible to save your keys".localized(), message: "Please check you have enough space in your iDevice.".localized(), quitMessage: "Ok")
            self.importButton.isEnabled = true
        } else { // success
            self.activityIndicator.stopAnimating()
            let settingData = SettingsData()
            var settingDict = settingData.getSetting()
            
            var isX509 = false
            if isX509Given != nil {
                isX509 = isX509Given!
            } else {
                let keys = KeyId()
                if let publicKeyData = Data(base64Encoded: keys.extract_key(publicKey)) {
                    do {
                        isX509 = try publicKeyData.hasX509Header()
                        print("[*] Recieved public key = \(publicKeyData.base64EncodedString())")
                        print("[*] Public key checked. Test passed. Result : hasX509Header = \(isX509)")
                    } catch {
                        print("[*] Impossible to verify X509 certificate")
                        isX509 = false
                    }
                    
                } else {
                    queue.async {
                        try? self.log.write(message: "⚠️ ERROR while importing keys : Error occured while converting the public key. Public key = \(publicKey)")
                    }
                    print("[*] Error while converting the public key. Public key = \(publicKey)")
                }
            }
            
            settingDict.updateValue(String(isX509), forKey: SettingsName.X509Certificate.key)
            settingData.saveSetting(dict: settingDict)
            showSuccess()
            self.perform(#selector(performSegueWithDelay), with: nil, afterDelay: 0.8)
        }
        
    }
    
    //
    // Keys dealing func (human readable or JSON)
    //
    
    func extractKeysFromString(_ str:String){
        print("[*] Try to extract keys from a given text")
        if let dictIfJSON = str.jsonToDictionary() { // it's json
            extractFromJSON(dictIfJSON)
        } else {
            extractFromHumanReadable(str)
        }
    }
    
    
    
    func extractFromJSON(_ dict: [String:String]){
        var privateKey:String?
        var publicKey:String?
        var isX509: Bool?
        guard let type = dict[ExportKeysJSON.type.key] else {
            incorrectInfo()
            return
        }
        
        if type != "RSA-4096"{
            queue.async {
                try? self.log.write(message: "⚠️ ERROR while importing keys : Incorrect type. Format = \(type)")
            }
            print("[** Error **] Incorrect type. Format = \(type)")
            incorrectInfo()
            return
        }
        
        print("[*] Right type (\(type). Extraction ...")
        
        guard let format = dict[ExportKeysJSON.format.key] else {
            print("[** Error **] Incorrect format (key doesn't exist in the retrieved dictionnary)")
            queue.async {
                try? self.log.write(message: "⚠️ ERROR while importing keys : Incorrect format (key doesn't exist in the retrieved dictionnary)")
            }
            incorrectInfo()
            return
        }
        print("[*] Format = \(format)")
        
        guard let publicKeyString = dict[ExportKeysJSON.publicKey.key] else {
            queue.async {
                try? self.log.write(message: "⚠️ ERROR while importing keys : Incorrect public key (key doesn't exist in the retrieved dictionnary)")
            }
            print("[** Error **] Incorrect public key (key doesn't exist in the retrieved dictionnary)")
            incorrectInfo()
            return
        }
        print("[*] PublicKey = \(publicKeyString)")
        
        guard let privateKeyString = dict[ExportKeysJSON.privateKey.key] else {
            queue.async {
                try? self.log.write(message: "⚠️ ERROR while importing keys : Incorrect public key (key doesn't exist in the retrieved dictionnary)")
            }
            print("[** Error **] Incorrect private key (key doesn't exist in the retrieved dictionnary)")
            incorrectInfo()
            return
        }
        print("[*] PrivateKey = \(privateKeyString)")
        
        let keys = KeyId()
        
        switch format {
        case ExportKeysJSON.format.pemX509:
            publicKey = keys.extract_from_pem_format(publicKeyString, isPrivate: false)
            privateKey = keys.extract_from_pem_format(privateKeyString, isPrivate: true)
            isX509 = true
        case ExportKeysJSON.format.pem:
            publicKey = keys.extract_from_pem_format(publicKeyString, isPrivate: false)
            privateKey = keys.extract_from_pem_format(privateKeyString, isPrivate: true)
            isX509 = false
        case ExportKeysJSON.format.base64X509:
            publicKey = publicKeyString
            privateKey = privateKeyString
            isX509 = true
        case ExportKeysJSON.format.base64:
            publicKey = publicKeyString
            privateKey = privateKeyString
            isX509 = false
        default : // error
            queue.async {
                try? self.log.write(message: "⚠️ ERROR while importing keys : Format unuknown. Format = \(format))")
            }
            print("[** Error **] Format unknown. Format = \(format)")
            publicKey = nil
            privateKey = nil
            isX509 = nil
        }
        
        if publicKey == nil || privateKey == nil {
            queue.async {
                try? self.log.write(message: "⚠️ ERROR while importing keys : One of the key is nil. PublicKey = \(String(describing: publicKey)), PrivateKey = \(String(describing: privateKey))")
            }
            print("[** Error **] One of the key is nil. PublicKey = \(String(describing: publicKey)), PrivateKey = \(String(describing: privateKey))")
            impossibleToExtractKeys()
            return
        }
        
        let keysTest = PublicPrivateKeys()
        do {
            let publicKey_withType : PublicKey = try PublicKey(base64Encoded : publicKey!)
            let privateKey_withType: PrivateKey = try PrivateKey(base64Encoded: privateKey!)
            if keysTest.verifyIfKeysWork(privateKey:privateKey_withType , publicKey: publicKey_withType){
                publicKey = keys.key_format(publicKey!)
                saveKeys(publicKey: publicKey!, privateKey: privateKey!, isX509Given: isX509)
            } else {
                wrongKeys()
                return
            }
        } catch {
            wrongKeys()
            return
        }
    }
    
    
    func extractFromHumanReadable(_ str: String){
        print("[*] Try to decrypt human readable keys")
        var privateKey:String?
        var publicKey:String?
        var isX509: Bool?
        let lines = str.components(separatedBy: "\n[")
        guard  lines.count >= 4 else {
            queue.async {
                try? self.log.write(message: "⚠️ ERROR while importing keys : Too much data. Nb of lines = \(lines.count)")
            }
            print("[** Error **] Too much data. Nb of lines = \(lines.count)")
            incorrectInfo()
            return
        }
            guard lines[0].contains(ExportKeysJSON.humanTitle.str) else {
                queue.async {
                    try? self.log.write(message: "⚠️ ERROR while importing keys :Incorrect title. Line 0 : \(lines[0])")
                }
                print("[** Error **] Incorrect title. Line 0 : \(lines[0])")
                incorrectInfo()
                return
            }
            
            guard lines[1].contains(ExportKeysJSON.format.key) else {
                queue.async {
                    try? self.log.write(message: "⚠️ ERROR while importing keys : Incorrect format. Line 1 : \(lines[1])")
                }
                print("[** Error **] Incorrect format. Line 1 : \(lines[1])")
                incorrectInfo()
                return
            }
            let formatInfos = lines[1].split(separator: ":")
            guard formatInfos.count == 2 else {
                
                incorrectInfo()
                return
            }
            
            let format = formatInfos[1].replacingOccurrences(of: " ", with: "")
            
            guard lines[2].contains(ExportKeysJSON.publicKey.key) else {
                queue.async {
                    try? self.log.write(message: "⚠️ ERROR while importing keys : Incorrect public key. Line 2 : \(lines[2])")
                }
                print("[** Error **] Incorrect public key. Line 2 : \(lines[2])")
                incorrectInfo()
                return
            }
            let publicKeyInfos = lines[2].split(separator: ":")
            guard publicKeyInfos.count == 2 else {
                incorrectInfo()
                return
            }
            let publicKeyString = publicKeyInfos[1].replacingOccurrences(of: " ", with: "")
            
            guard lines[3].contains(ExportKeysJSON.privateKey.key) else {
                queue.async {
                    try? self.log.write(message: "⚠️ ERROR while importing keys : Incorrect public key. Line 3 : \(lines[3])")
                }
                print("[** Error **] Incorrect private key. Line 3 : \(lines[3])")
                incorrectInfo()
                return
            }
            let privateKeyInfos = lines[3].split(separator: ":")
            guard privateKeyInfos.count == 2 else {
                incorrectInfo()
                return
            }
            let privateKeyString = privateKeyInfos[1].replacingOccurrences(of: " ", with: "")
            
        let keys = KeyId()
        
        switch format {
        case ExportKeysJSON.format.pemX509.replacingOccurrences(of: " ", with: ""):
            publicKey = keys.extract_from_pem_format(publicKeyString, isPrivate: false)
            privateKey = keys.extract_from_pem_format(privateKeyString, isPrivate: true)
            isX509 = true
        case ExportKeysJSON.format.pem.replacingOccurrences(of: " ", with: ""):
            publicKey = keys.extract_from_pem_format(publicKeyString, isPrivate: false)
            privateKey = keys.extract_from_pem_format(privateKeyString, isPrivate: true)
            isX509 = false
        case ExportKeysJSON.format.base64X509.replacingOccurrences(of: " ", with: ""):
            publicKey = publicKeyString
            privateKey = privateKeyString
            isX509 = true
        case ExportKeysJSON.format.base64.replacingOccurrences(of: " ", with: ""):
            publicKey = publicKeyString
            privateKey = privateKeyString
            isX509 = false
        default : // error
            queue.async {
                try? self.log.write(message: "⚠️ ERROR while importing keys : Format unknown. Format = \(format)")
            }
            print("[** Error **] Format unknown. Format = \(format)")
            publicKey = nil
            privateKey = nil
            isX509 = nil
        }
        
        if publicKey == nil || privateKey == nil {
            queue.async {
                try? self.log.write(message: "⚠️ ERROR while importing keys : One of the key is nil. PublicKey = \(String(describing: publicKey)), PrivateKey = \(String(describing: privateKey))")
            }
            print("[** Error **] One of the key is nil. PublicKey = \(String(describing: publicKey)), PrivateKey = \(String(describing: privateKey))")
            impossibleToExtractKeys()
            return
        }
        
        let keysTest = PublicPrivateKeys()
        do {
            let publicKey_withType : PublicKey = try PublicKey(base64Encoded : publicKey!)
            let privateKey_withType: PrivateKey = try PrivateKey(base64Encoded: privateKey!)
            if keysTest.verifyIfKeysWork(privateKey:privateKey_withType , publicKey: publicKey_withType){
                publicKey = keys.key_format(publicKey!)
                saveKeys(publicKey: publicKey!, privateKey: privateKey!, isX509Given: isX509)
            } else {
                wrongKeys()
                return
            }
        } catch {
            wrongKeys()
            return
        }
    }
    
    
    
    //
    // Obj C func
    //
    
    @objc func performSegueWithDelay(){
        performSegue(withIdentifier: "homePage", sender: self)
    }
    
    //
    // Error alert func
    //
    
    func impossibleToRetrieveTxt(){
        self.activityIndicator.stopAnimating()
        alert("Impossible to retrieve your .txt".localized(), message: "Your .txt file seems to be unreachable. Please try again".localized(withKey: "unreachableFIleMessageError"), quitMessage: "Ok")
    }
    
    func impossibleToExtractKeys(){
        self.activityIndicator.stopAnimating()
        alert("Impossible to extract your keys".localized(), message: "Your keys can't be extracted. Please, only try to import a text generated by iLocked.".localized(withKey: "extractionErrorMessage"), quitMessage: "Ok")
    }
    
    func incorrectInfo(){
        self.activityIndicator.stopAnimating()
        alert("Impossible to retrieve your keys".localized(), message: "Your keys can't be extracted because informations provided are incorrect or corrupted. Please, only try to import a text file generated by iLocked.".localized(withKey: "wrongInfoErrorMessage"), quitMessage: "Ok")
    }
    
    func wrongKeys(){
        self.activityIndicator.stopAnimating()
        alert("Wrong keys".localized(), message: "The public key given doesn't correspond to the private key. Please, verify you correctly provided a key pair.".localized(withKey: "wrongKeysErrorMessage"), quitMessage: "Ok")
    }
    
    func showSuccess(){
        let animation = UIViewPropertyAnimator(duration: 0.5, curve: .linear, animations: {
            self.checkmarkBackground.alpha = 1
        })
        animation.startAnimation()
    }
    
}
