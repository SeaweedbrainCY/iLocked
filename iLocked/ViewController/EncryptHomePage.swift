//
//  EncryptHomePage.swift
//  iLocked
//
//  Created by Nathan on 27/07/2019.
//  Copyright © 2019 Nathan. All rights reserved.
//

import Foundation
import UIKit




class Encrypt: UIViewController, UITextViewDelegate{
    
    @IBOutlet weak var textToEncrypt: UITextView!
    @IBOutlet weak var senderView: UIView!
    @IBOutlet weak var lockAppButton: UIBarButtonItem!
    @IBOutlet weak var keyNameButton: UIButton!
    @IBOutlet weak var encryptButton: UIButton!
    @IBOutlet weak var dismissKeyboardButton: UIButton!
    
    var keyArray: [String] = ["Add a key", "My encryption key"] // list of all names displayed on UIPIckerView
    var heightPicker: NSLayoutConstraint?
    var heightSender: NSLayoutConstraint?
    var titleButtonClean = ""
    var textEncrypted = "error"
    var nameArray: [String] = [] // list of all name saved
    
    //Data came from ShowKey.swift > encryptMessageSelected()
    var keyNameTransmitted = ""
    
    //Default value : stock the default value of color and text, to check if they have been modified
    let defaultKeyNameButtonTextColor: UIColor = UIColor.lightGray // updated in viewDidLoad
    var defaultKeyNameButtonText:String = "Select a key"
    var defaultTextToEncryptColor: UIColor = UIColor.darkGray // updated in viewDidLoad
    var defaultTextToEncryptText:String = "Text to encrypt"
    
    
    
    
    //Notification
    static let notificationOfNewKey = Notification.Name("AddKeyDismissed")
    static let notificationOfSelectionName = Notification.Name("notificationOfSelectionFromKeyListToEncryptView")
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Observation des notiifcations
        
        //Récuperation des infos :
        loadData()
        
        self.textToEncrypt.delegate = self
        
        //Set up some button
        self.encryptButton.setTitleColor(.gray, for: .selected)
        
        self.senderView.translatesAutoresizingMaskIntoConstraints = false
       // self.senderView.centerXAnchor.constraint(equalToSystemSpacingAfter: self.keyList.centerXAnchor, multiplier: 1).isActive = true
        //self.senderView.centerYAnchor.constraint(equalToSystemSpacingBelow: self.keyList.centerYAnchor, multiplier: 1).isActive = true
        self.heightSender = self.senderView.heightAnchor.constraint(equalToConstant: 0)
        self.heightSender?.isActive = true
        
        if keyNameTransmitted != "" { //User already choose the key in ShowKey.swift's view
            self.keyNameButton.setTitleColor(.black, for: .normal)
            self.keyNameButton.setTitle("\(self.keyNameTransmitted)", for: .normal)
            self.titleButtonClean = self.keyNameTransmitted// simulation of user's action
        }
        
        // Set up the default values
        if keyNameTransmitted == "" {// If not, the user has already chosen the key in ShowKey.swift's view
            self.keyNameButton.setTitle(self.defaultKeyNameButtonText, for: .normal)
            self.keyNameButton.setTitleColor(self.defaultKeyNameButtonTextColor, for: .normal)
            self.keyNameButton.setTitleColor(.lightGray, for: .selected)
        }
        self.textToEncrypt.textColor = self.defaultTextToEncryptColor
        self.textToEncrypt.text = self.defaultTextToEncryptText
        
        // round some button :
        self.dismissKeyboardButton.layer.cornerRadius = 10
        self.encryptButton.layer.cornerRadius = 10
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        //Is called when the app move to background
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        //Is called when user has selected a key in order to encrypt with it
        notificationCenter.addObserver(self, selector: #selector(keySelected), name: Encrypt.notificationOfSelectionName, object: nil)
        // Is called when the keyboard will show
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        
        
        
    }

    func alert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    public func loadData(){
        let data = KeyId()
        let keyName = data.getKeyName()
        print("key name recieved = \(keyName)")
        if keyName.count != 0{
            if keyName[0].contains("##ERROR##"){
                alert("Oups ! We got an error ! ", message: keyName[0])
            } else { // we don't have any error
                self.nameArray = keyName
                print("name array : \(nameArray)")
                for name in nameArray{
                    self.keyArray.append(name)
                }
            }
        } 
    }
    
    //
    // IBAction func
    //
    
    @IBAction private func encryptSelected(sender:UIButton){
        let is_correct = checkForEncryption()
        print("[*] Check for encryption : \(is_correct)")
        if is_correct {
            var keySaved: String? = nil
            if self.keyNameButton.currentTitle! == "My encryption key"{
                keySaved = KeychainWrapper.standard.string(forKey: userPublicKeyId)
            } else {
                keySaved = KeychainWrapper.standard.string(forKey:self.keyNameButton.currentTitle!)
            }
            if keySaved == nil {
                alert("Impossible to find the encryption key", message: "Please verify that a key is selected. If all the fields are filled, try to relaunch the app.")
            } else {
                var encryptedText = encryptText(text: self.textToEncrypt.text!, publicKey: keySaved!)
                let encryptionMethod = Encryption()
                var nameSelected = self.keyNameButton.currentTitle
                if nameSelected == "My encryption key"{
                    nameSelected = userPublicKeyId
                }
                encryptedText = encryptionMethod.encryptText(self.textToEncrypt.text, withKeyName: nameSelected!)
                if encryptedText != "error" && encryptedText != "" {
                    self.textEncrypted = encryptedText
                    performSegue(withIdentifier: "Encryption", sender: nil)
                } else {
                    alert("Oups ... encryption error message", message: "Impossible to encrypt this message. Please try again")
                }
            }
        }
        
    }
    
    
    @IBAction func lockAppSelected(sender: UIBarButtonItem){
        performSegue(withIdentifier: "lockApp", sender: self)
    }
    
    @IBAction func selectKeySelected(_ sender: Any) {
        performSegue(withIdentifier: "keyList", sender: self)
    }
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Text to encrypt"{
            textView.text = ""
            textView.textColor = UIColor.white
        }
    }
    @IBAction func dismissButtonSelected(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView){
        self.dismissKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        self.encryptButton.translatesAutoresizingMaskIntoConstraints = false
        if textView.text == "" {
            textView.text = "Text to encrypt"
            textView.textColor = .darkGray
        }
    }
    
    

    //Encryption method :
    private func encryptText(text: String, publicKey: String) -> String{
        do {
            let clear = try ClearMessage(string: text, using: .utf8)
            print("Text to encrypt = \(clear.base64String)")
            //error("Attention verifier qu'il ne faut pas encoder la public key. Que cela marche aussi avec une key sous la forme d'une string")
            
            let encrypted = try clear.encrypted(with: PublicKey(base64Encoded: publicKey) , padding: .PKCS1)
            return encrypted.base64String
        } catch {
            return "error"
        }
    }
    
    
    //
    // Notifications func
    //
    
    @objc private func appMovedToBackground(){
        //print("notification recieved")
        performSegue(withIdentifier: "lockApp", sender: self)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.dismissKeyboardButton.translatesAutoresizingMaskIntoConstraints = true
            self.encryptButton.translatesAutoresizingMaskIntoConstraints = true
            self.dismissKeyboardButton.frame.origin.y = self.view.frame.height - keyboardHeight - self.dismissKeyboardButton.frame.height - 10
            self.encryptButton.frame.origin.y =  self.view.frame.height - keyboardHeight - self.encryptButton.frame.height - 10
            
        }
    }
    
    @objc func keyboardWillHide(_ notification : Notification){
        self.dismissKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        self.encryptButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// Get the key selected in order to encrypt with it
    @objc private func keySelected(notification: Notification){
        self.keyNameButton.setTitleColor(.black, for: .normal)
        let notificationData = notification.userInfo
        self.keyNameButton.setTitle((notificationData?["name"] as! String), for: .normal)
    }
    
    //
    // Data func
    //
    
    /// Check if the encryption text is correct and a key is selected
    private func checkForEncryption() -> Bool{
        if self.keyNameButton.titleLabel?.textColor == self.defaultKeyNameButtonTextColor && self.keyNameButton.titleLabel?.text == self.defaultKeyNameButtonText{ // Check if a key is selected
            shakeView(self.keyNameButton)
            return false
        } else if textToEncrypt.textColor == self.defaultTextToEncryptColor && self.textToEncrypt.text == self.defaultTextToEncryptText{
            shakeView(self.textToEncrypt)
            return false
        }
        return true
    }
    
    //
    // Animation func
    //
    
    func shakeView(_ view:UIView){
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: view.center.x - 10, y: view.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: view.center.x + 10, y: view.center.y))
        
        view.layer.add(animation, forKey: "position")
    }
    
    //
    // Segue func
    //
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Encryption" && textEncrypted != "error" && textEncrypted != ""{
            let encryptionView = segue.destination as! EncryptedResult
            encryptionView.encryptedTextTransmitted = self.textEncrypted
            encryptionView.clearTextTransmitted = self.textToEncrypt.text!
            encryptionView.keyNameTransmitted = self.keyNameButton.currentTitle!
        } else if segue.identifier == "addKey"{
            let nv = segue.destination as? UINavigationController
            if let addView = nv?.viewControllers.first as? AddKey {
                addView.viewOnBack = "Encrypt"
            } else {
                print("it's other ! : \(segue.destination)")
            }
        } else if segue.identifier == "lockApp"{
            let lockedView = segue.destination as! LockedView
            lockedView.activityInProgress = true
        } else if segue.identifier == "keyList"{
            let nv = segue.destination as? UINavigationController
            if let keyList = nv?.viewControllers.first as? KeyList {
                keyList.isKeySelection = true
            } else {
                print("[*] Error : Wrong segue destination ->   \(segue.destination)")
            }
            
        }
    }
    
}





