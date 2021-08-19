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
    @IBOutlet weak var addNewKeyButton: UIBarButtonItem!
    @IBOutlet weak var helpBarButtonItem : UIBarButtonItem!
    
    //Help views
    let helpTextView = UITextView()
    let helpView = UIView()
    let quitButton = UIButton()
    var backgroundInfo = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.dark))
    var closeHelpButtonView = UIButton() // cover the background info view, and close help if touched
    
    var keyArray: [String] = ["Add a key".localized(), "My encryption key".localized()] // list of all names displayed on UIPIckerView
    var heightPicker: NSLayoutConstraint?
    var heightSender: NSLayoutConstraint?
    var titleButtonClean = ""
    var textEncrypted = "error"
    var nameArray: [String] = [] // list of all name saved
    var lockAppButtonIsHit = false // True if the user voluntarily hit the lockApp button. More explanations in LockedView.swift code.
    
    //Data came from ShowKey.swift > encryptMessageSelected()
    var keyNameTransmitted = ""
    
    //Default value : stock the default value of color and text, to check if they have been modified
    let defaultKeyNameButtonTextColor: UIColor = UIColor.lightGray // updated in viewDidLoad
    var defaultKeyNameButtonText:String = "Select a key".localized()
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
        
        // construct view
        self.constructView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        
        let notificationCenter = NotificationCenter.default
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
                alert("Oups ! We got an error ! ".localized(), message: keyName[0])
            } else { // we don't have any error
                self.nameArray = keyName
                print("name array : \(nameArray)")
                for name in nameArray{
                    self.keyArray.append(name)
                }
            }
        } 
    }
    
    private func constructView(){// construct the current view
        self.textToEncrypt.delegate = self
        
        self.view.backgroundColor = Colors.darkGray6.color
        
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
        
        // Help views
        self.view.addSubview(self.backgroundInfo)
        self.backgroundInfo.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundInfo.heightAnchor.constraint(equalToConstant: self.view.frame.size.height).isActive = true
        self.backgroundInfo.widthAnchor.constraint(equalToConstant: self.view.frame.size.width).isActive = true
        self.backgroundInfo.centerYAnchor.constraint(equalToSystemSpacingBelow: self.view.centerYAnchor, multiplier: 1).isActive = true
        self.backgroundInfo.centerYAnchor.constraint(equalToSystemSpacingBelow: self.view.centerYAnchor, multiplier: 1).isActive = true
        self.backgroundInfo.alpha = 0
        
        self.view.addSubview(self.helpView)
        self.helpView.frame.size.height = self.view.frame.size.height
        self.helpView.frame.size.width = self.view.frame.size.width - 20
        self.helpView.center = self.view.center
        self.helpView.backgroundColor = .none
        self.helpView.alpha = 0
        
        self.helpView.addSubview(closeHelpButtonView)
        self.closeHelpButtonView.translatesAutoresizingMaskIntoConstraints = false
        self.closeHelpButtonView.heightAnchor.constraint(equalToConstant: self.helpView.frame.height).isActive = true
        self.closeHelpButtonView.widthAnchor.constraint(equalToConstant: self.helpView.frame.width).isActive = true
        self.closeHelpButtonView.centerXAnchor.constraint(equalToSystemSpacingAfter: self.helpView.centerXAnchor, multiplier: 1).isActive = true
        self.closeHelpButtonView.centerYAnchor.constraint(equalToSystemSpacingBelow: self.helpView.centerYAnchor, multiplier: 1).isActive = true
        
        self.closeHelpButtonView.backgroundColor = .none
        self.closeHelpButtonView.addTarget(self, action: #selector(closeHelpSelected), for: .touchUpInside)
        
        
        self.helpView.addSubview(self.helpTextView)
        self.helpTextView.translatesAutoresizingMaskIntoConstraints = false
        self.helpTextView.widthAnchor.constraint(equalToConstant: self.helpView.frame.size.width - 20).isActive = true
        self.helpTextView.heightAnchor.constraint(equalToConstant: self.helpView.frame.size.height
             / 2).isActive = true
        self.helpTextView.centerXAnchor.constraint(equalToSystemSpacingAfter: self.helpView.centerXAnchor, multiplier: 1).isActive = true
        self.helpTextView.centerYAnchor.constraint(equalToSystemSpacingBelow: self.helpView.centerYAnchor, multiplier: 1).isActive = true
        self.helpTextView.isEditable = false
        self.helpTextView.isSelectable = false
        self.helpTextView.textAlignment = .justified
        self.helpTextView.font = UIFont(name: "American Typewriter", size: 17.0)
        self.helpTextView.textColor = .white
        self.helpTextView.backgroundColor = .none
        self.helpTextView.isScrollEnabled = true
        /*self.helpTextLabel.adjustsFontSizeToFitWidth = true
        self.helpTextLabel.adjustsFontForContentSizeCategory = true
        self.helpTextLabel.lineBreakMode = .byClipping
        self.helpTextLabel.minimumScaleFactor = 0.5*/
        
        
        
        
        // encrypt textview :
        self.textToEncrypt.text = "Text to encrypt".localized()
        
        
        if #available(iOS 14.0, *), #available(watchOS 7.0, *), #available(tvOS 14.0, *){
            self.encryptButton.setImage(UIImage(systemName: "lock.doc.fill"), for: .normal)
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
            if self.keyNameButton.currentTitle! == "My encryption key".localized(){
                keySaved = KeychainWrapper.standard.string(forKey:  UserKeys.publicKey.tag)
            } else {
                keySaved = KeychainWrapper.standard.string(forKey:self.keyNameButton.currentTitle!)
            }
            if keySaved == nil {
                alert("Impossible to find the public key".localized(), message: "Please verify that a key is selected. If all the fields are filled, try to relaunch the app.".localized(withKey: "alertKeyErrorMessage"))
            } else {
                var encryptedText = encryptText(text: self.textToEncrypt.text!, publicKey: keySaved!)
                let encryptionMethod = Encryption()
                var nameSelected = self.keyNameButton.currentTitle
                if nameSelected == "My encryption key".localized(){
                    nameSelected =  UserKeys.publicKey.tag
                }
                encryptedText = encryptionMethod.encryptText(self.textToEncrypt.text, withKeyName: nameSelected!)
                if encryptedText != "error" && encryptedText != "" {
                    self.textEncrypted = encryptedText
                    performSegue(withIdentifier: "Encryption", sender: nil)
                } else {
                    alert("Oups ...", message: "Impossible to encrypt this message. Please try again".localized(withKey: "ErrorEncryption"))
                }
            }
        }
        
    }
    
    
    @IBAction func lockAppSelected(sender: UIBarButtonItem){
        self.lockAppButtonIsHit = true
        performSegue(withIdentifier: "lockApp", sender: self)
    }
    
    @IBAction func selectKeySelected(_ sender: Any) {
        performSegue(withIdentifier: "keyList", sender: self)
    }
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Text to encrypt".localized(){
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
            textView.text = "Text to encrypt".localized()
            textView.textColor = .darkGray
        }
    }
    
    @IBAction func addNewKeySelected(sender: UIBarButtonItem){
        self.performSegue(withIdentifier: "addKey", sender: self)
    }
    
    @IBAction func infoButtonSelected(_ sender: Any) {
        if self.helpBarButtonItem.image == UIImage(systemName: "info.circle"){
            let helpText = """
                ⚠️ CONFIDENTIALITY : iLocked NEVER (never) keeps or shares your messages.
                To prove it, the app doesn't require any internet connection to encrypt, decrypt or store a key ! What's in your iPhone, stays in your iPhone.
                
                
                
                🔐 iLocked uses the RSA-4096 encryption method, a highly secure protection, to encrypt your messages.
                
                Nobody but the owner of the private key corresponding to the public key you are going to use to encrypt, can decrypt it. Even you.
                
                🙇 IMPORTANT : Make sure to encrypt your message with the public key of the person you want to send it to. Be careful to copy the whole encrypted text before sending it. No more no less. Or it won't work  . . .
                """.localized(withKey: "helpTextEncryption")
            self.showHelp(text: helpText)
        } else {
            closeHelp()
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
    // objc func
    //
    
    @objc func closeHelpSelected(sender: UIButton){
        closeHelp()
    }
    
    //
    // Notifications func
    //
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.dismissKeyboardButton.translatesAutoresizingMaskIntoConstraints = true
            
            
            self.encryptButton.translatesAutoresizingMaskIntoConstraints = true
            let encryptButton_x = self.dismissKeyboardButton.frame.origin.x + self.dismissKeyboardButton.frame.width + 20
            let encryptButton_y = self.view.frame.height - keyboardHeight - self.encryptButton.frame.height - 10
            let encryptButton_width = self.view.frame.width - self.dismissKeyboardButton.frame.width - 60 // 60 because the button is at 20 pt from the right border, 20 pt from the dismissKeyboard button, which is at 20 pt from the left border
            self.encryptButton.frame = CGRect(x: encryptButton_x, y: encryptButton_y, width: encryptButton_width, height: self.encryptButton.frame.height)
            
            self.dismissKeyboardButton.frame.origin.y = self.view.frame.height - keyboardHeight - self.dismissKeyboardButton.frame.height - 10
            self.dismissKeyboardButton.isHidden = false
            
            
            reduceTextView(keyboardHeight: keyboardHeight)
        }
    }
    
    @objc func keyboardWillHide(_ notification : Notification){
        self.dismissKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        self.encryptButton.translatesAutoresizingMaskIntoConstraints = false
        self.dismissKeyboardButton.isHidden = true
        expandTextView()
    }
    
    /// Get the key selected in order to encrypt with it
    @objc private func keySelected(notification: Notification){
        self.keyNameButton.setTitleColor(.black, for: .normal)
        let notificationData = notification.userInfo
        self.keyNameButton.setTitle((notificationData?["name"] as! String), for: .normal)
    }
    
    /// Reduce the height of textToEncrypt view, to fit with the keyboard height
    func reduceTextView(keyboardHeight:CGFloat){
        self.textToEncrypt.translatesAutoresizingMaskIntoConstraints = true
        let height = self.view.frame.height - keyboardHeight - self.encryptButton.frame.height - self.textToEncrypt.frame.origin.y - 20
        self.textToEncrypt.frame = CGRect(x: self.textToEncrypt.frame.origin.x, y: self.textToEncrypt.frame.origin.y, width: self.textToEncrypt.frame.width, height: height)
    }
    
    /// Expand the height of textToEncrypt view, it was reduced to fit with the keyboard heigth
    func expandTextView(){
        self.textToEncrypt.translatesAutoresizingMaskIntoConstraints = false
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
    
    func showHelp(text: String){
        self.helpBarButtonItem.image = UIImage(systemName: "multiply.circle.fill")
        self.helpView.layer.borderColor = UIColor.white.cgColor
        self.helpTextView.text = text
        let animator = UIViewPropertyAnimator(duration: 0.7, dampingRatio: 0.7, animations: {
            self.helpView.alpha = 1
            self.backgroundInfo.alpha = 1
        })
        animator.startAnimation()
    }
    
    func closeHelp(){
        self.helpBarButtonItem.image = UIImage(systemName: "info.circle")
         let animation = UIViewPropertyAnimator(duration: 0.7, dampingRatio: 0.7, animations: {
            self.helpView.alpha = 0
            self.backgroundInfo.alpha = 0
        })
        animation.startAnimation()
    }
    
    //
    // Segue func
    //
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Encryption" && textEncrypted != "error" && textEncrypted != ""{
            let encryptionView = segue.destination as! EncryptedResult
            print("[*] Text encrypted = \(self.textEncrypted)")
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
            if lockAppButtonIsHit {
                lockedView.voluntarilyLocked = true // Explanations in LockedView.swift code
                lockAppButtonIsHit = false // disable the tap
            }
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





