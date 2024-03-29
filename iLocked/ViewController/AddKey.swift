//
//  AddKey.swift
//  iLocked
//
//  Created by Nathan on 30/07/2019.
//  Copyright © 2019 Nathan. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import InAppPurchaseLib

class AddKey: UIViewController, UITextViewDelegate,UIScrollViewDelegate, UITextFieldDelegate  {
    

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var nameKeyField: UITextField!
    @IBOutlet weak var keyTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nameError: UIButton!
    @IBOutlet weak var publicKeyError: UIButton!
    @IBOutlet weak var notificationView:UIButton!
    

    var currentColorButton = UIButton()
    var chooseColorControl = UISegmentedControl()
    //var segmentView = UIView()
    var allCellsText = [String]() // Store data from the textField in table View
    
    static let keyQrCodeRedNotificationName = Notification.Name("keyQrCodeRedNotificationName")
    
    let log = LogFile(fileManager: FileManager())
    let queue = DispatchQueue.global(qos: .background)
    
    var viewOnBack: String = ""
    var oldName:String = ""
    var oldKey : String = ""
    
    let keyTextViewPlaceholder = "Aa"
    
    let forbiddenKeyName = [UserKeys.publicKey.tag,  UserKeys.privateKey.tag, "My encryption key".localized()] // List of forbidden keyName
    
    //##################################################################################
    //##################################################################################
        //ATTENTION CE MORCEAU DE CODE EST STRICTEMENT SUPERFLU. IL CONCERNE UNE FONCTIONNALITÉ NON IMPLENTÉE ET TOUJOURS EN COURS DE DEVELOPPEMENT.
        //RÉINTEGRER CETTE PARTIE DE CODE EST INUTILE PUISQUE NON-UTILISÉ.
        /*local var
        let listeImageColor: [UIImage] = [UIImage(named: "blue")!, UIImage(named: "red")!, UIImage(named: "orange")!, UIImage(named: "green")!, UIImage(named: "pink")!, UIImage(named: "white")!, UIImage(named: "gray")!]*/
    //##################################################################################
    //##################################################################################
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View on back = \(self.viewOnBack)")
        self.constructView()
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(newKeyWithQRCode), name: AddKey.keyQrCodeRedNotificationName, object: nil)
    }
    
    
    
    
    //
    // View constructions func
    //
    
    
    private func constructView(){
        self.nameKeyField.delegate = self 
        self.nameKeyField.attributedPlaceholder = NSAttributedString(string: "Aa",
                                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        self.keyTextView.delegate = self
        self.keyTextView.layer.cornerRadius = 10
        self.keyTextView.layer.borderWidth = 0.1
        self.keyTextView.layer.borderColor = UIColor.white.cgColor
        self.keyTextView.textColor = .lightGray
        self.keyTextView.text = self.keyTextViewPlaceholder
        
        if oldName != ""{ // We are editing an existant key
            self.nameKeyField.text = oldName
            self.textViewDidBeginEditing(self.keyTextView) // As a user do
            self.keyTextView.text = oldKey
        }
        
        
        self.saveButton.layer.cornerRadius = 10
        
        self.nameError.frame = self.nameKeyField.frame
        self.nameError.titleLabel!.font = UIFont(name: "Arial Rounded MT Bold", size: 18)
        self.nameError.setTitleColor(.systemRed, for: .normal)
        self.nameError.layer.cornerRadius = 15
        self.nameError.layer.borderWidth = 1
        self.nameError.layer.borderColor = UIColor.white.cgColor
        self.nameError.backgroundColor = .white
        self.nameError.isHidden = true
        
        
        self.publicKeyError.frame = self.keyTextView.frame
        self.publicKeyError.titleLabel!.font = UIFont(name: "Arial Rounded MT Bold", size: 18)
        self.publicKeyError.setTitleColor(.systemRed, for: .normal)
        self.publicKeyError.layer.cornerRadius = 15
        self.publicKeyError.layer.borderWidth = 1
        self.publicKeyError.titleLabel?.numberOfLines = 20
        self.publicKeyError.layer.borderColor = UIColor.white.cgColor
        self.publicKeyError.backgroundColor = .white
        self.publicKeyError.isHidden = true
        self.publicKeyError.titleLabel?.textAlignment = .center
        
       
        self.notificationView.layer.borderWidth = 2
        self.notificationView.layer.cornerRadius = 20
        self.notificationView.backgroundColor = .white
        self.notificationView.setTitleColor(.red, for: .normal)
        self.notificationView.alpha = 0
    }
    
    
    //
    // Objective C func
    //
    
    //##################################################################################
    //##################################################################################
    //Bouton pour changer la couleur selectionné
    //ATTENTION CETTE FONCTION EST NON IMPLÉMENTÉE DANS LE CODE
    //CETTE FONCTION EST DANS LA PRÉVISION D'UNE AMÉRLIORATION À VENIR.
    //CETTE FONCTION PEUT ÉVENTUELLEMENT DISPARAITRE MOMENTANEMÉNT OU PASSER EN COMMENTAIRE
    /*@objc private func colorButtonSelected(sender:UIButton){
        let animation = UIViewPropertyAnimator(duration: 1, curve: .easeInOut, animations: {
            self.currentColorButton.translatesAutoresizingMaskIntoConstraints = true
            self.chooseColorControl.translatesAutoresizingMaskIntoConstraints = true
            self.currentColorButton.frame.origin.x = 20
            self.chooseColorControl.frame.origin.x = 20 + self.currentColorButton.frame.size.width
        })
        animation.startAnimation()
    }*/
    //##################################################################################
    //##################################################################################
    
    
    
    @objc func dismissView(){
        self.dismiss(animated: true, completion: nil)
    }
    
 
    
    @objc private func backToNormal(){ // reset the button
        let animation = UIViewPropertyAnimator(duration: 0.7, dampingRatio: 0.7, animations: {
            self.notificationView.alpha = 0
       })
       animation.startAnimation()
       
    }
    @objc private func showErrorView(withTitle title : String ){
        let correctedTitle = "  " + title + "  "
        self.notificationView.setTitle(correctedTitle, for: .normal)
        let animation = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.5, animations: {
            self.notificationView.alpha = 1
       })
       animation.startAnimation()
        perform(#selector(backToNormal), with: nil, afterDelay: 5)
        
        //self.copyButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        //self.copyButton.tintColor = .systemGreen
        
    }
    
    
    
    
    //
    // @IBOutlet func
    //
    
    @IBAction func cancelSelected(sender: UIBarButtonItem){
        print("cancel button selected")
        NotificationCenter.default.post(name: Encrypt.notificationOfNewKey, object: nil, userInfo:["addKey dismissed" : true])
        
        perform(#selector(dismissView), with: nil)
        
    }
    @IBAction func saveItemButtonSelected(_ sender: Any) {
        self.saveButtonSelected(sender:self.saveButton)
    }
    
    @IBAction func saveButtonSelected(sender: UIButton){
        //We can try to save data
        print("[*] Save button selected")
        if self.verify(name : self.nameKeyField.text,key: self.keyTextView.text) {
            ///we save new data
            if oldName == "" {
                self.saveKeyWithName(nameString: self.nameKeyField.text!)
            } else { /// we edit new data :
                let keyId = KeyId()
                let nameList = keyId.getKeyName()
                print("old name = \(self.oldName)")
                if !nameList.contains(oldName) { // Impossible to find the name. Fatal error
                    queue.async {
                        try? self.log.write(message: "⚠️ ERROR ##DATA/AK.SWIFT 0003. Impossible to identify this key")
                    }
                    self.publicKeyError.setTitle("Impossible to identify this key. Please, try to save it again. If you see this error several times please report the bug with the id : ##DATA/AK.SWIFT 0003 🛠".localized(withKey: "Error0003"), for: .normal)
                    self.flip(firstView: self.keyTextView, secondView: self.publicKeyError)
                } else { // id found
                    self.saveKeyWithName(nameString: nameKeyField.text!)
                }
            }
        }
        print("[*] Save button func ended")
    }
    
    @IBAction func nameKeyErrorSelected(_ sender: Any) {
        flip(firstView : self.nameError, secondView: self.nameKeyField)
    }
    
    @IBAction func keyErrorSelected(_ sender: Any) {
        flip(firstView: self.publicKeyError, secondView: self.keyTextView)
    }
    
    @IBAction func notificationViewSelected(sender: UIButton){// If the notification is touched, we hide it
        backToNormal()
    }
    
    //
    // OBJC func
    //
    
    @objc private func newKeyWithQRCode(notification: Notification) {
        let notificationData = notification.userInfo
        let qrCodeString = notificationData?["DataString"] as? String
        if qrCodeString == nil {
            perform(#selector(showErrorView), with: "Impossible to retrieve any data of the QRCode".localized(), afterDelay: 0.5)
            queue.async {
                try? self.log.write(message: "⚠️ Error while decoding the QRCode. Notification received but there was no data attached.")
            }
        } else {
            let qrCodeData = QRCodeData()
            do{
                let data = try qrCodeData.decodeQrCodeText(qrCodeString!)
                if data[QRCodeData.QRCodeData.type.key] == QRCodeData.QRCodeData.type.pubKey {
                    self.textViewDidBeginEditing(self.keyTextView)
                    self.keyTextView.text = data[QRCodeData.QRCodeData.data.key]
                } else {
                    perform(#selector(showErrorView), with: "The QRCode doesn't contain a public key".localized(), afterDelay: 0.5)
                    queue.async {
                        try? self.log.write(message: "⚠️ Error while decoding the QRCode. Data received but this is not a public key.")
                    }
                }
            } catch let errorThrown as qrCodeError {
                switch errorThrown{
                case .incorrectJSON:
                    perform(#selector(showErrorView), with: "Invalid data. Cannot be read".localized(), afterDelay: 0.5)
                case .unknownVersion:
                    perform(#selector(showErrorView), with: "Invalid QRCode version. Cannot be read".localized(), afterDelay: 0.5)
                case .invalideChesksum:
                    perform(#selector(showErrorView), with: "The QRCode data is corrupted".localized(), afterDelay: 0.5)
                case .unknownType:
                    perform(#selector(showErrorView), with: "Data type unknown. Impossible to decode".localized(), afterDelay: 0.5)
                case .noChecksum:
                    perform(#selector(showErrorView), with: "The data integrity cannot be checked. Decoding prohibited".localized(), afterDelay: 0.5)
                case .noKey:
                    perform(#selector(showErrorView), with: "The QRCode doesn't contain a public key".localized(), afterDelay: 0.5)
                }
                queue.async {
                    try? self.log.write(message: "⚠️ Error while decoding the QRCode. Error thrown : \(errorThrown.localizedDescription)")
                }
                
                //alert("Invalid QRCode ! ", message: "Make sure your QRCode has been generated by iLocked.")
            } catch {
                queue.async {
                    try? self.log.write(message: "⚠️ Error while decoding the QRCode. First catch failed. Error thrown : \(error.localizedDescription)")
                }
                //alert("Invalid QRCode ! ", message: "Make sure your QRCode has been generated by iLocked.")
                perform(#selector(showErrorView), with: "Invalid format. Cannot be read".localized(), afterDelay: 0.5)
            }
        }
    }
    
    //
    // Design function
    //
    
    func flip(firstView : UIView, secondView: UIView) {
        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]

        UIView.transition(with: firstView , duration: 1.0, options: transitionOptions, animations: {
            firstView.isHidden = true
        })

        UIView.transition(with: secondView, duration: 1.0, options: transitionOptions, animations: {
            secondView.isHidden = false
        })
    }
    
    func alert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //
    // segue func
    //
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "lockApp"{
            let lockedView = segue.destination as! LockedView
            lockedView.activityInProgress = true
        } else if segue.identifier == "QRCodeReader"{
            let qrCodeReader = segue.destination as? QRCodeReader
            qrCodeReader?.notificationNameTopPostTo = AddKey.keyQrCodeRedNotificationName
        }
    }
    
   

    //
    //Text view/text field delegate
    //
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == self.keyTextViewPlaceholder{
            textView.text = ""
            textView.textColor = .white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView){
        if textView.text == "" {
            textView.text = self.keyTextViewPlaceholder
            textView.textColor = .darkGray
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    
    //
    // Data func
    //
    
    ///Save a key with an Id
    /// - id : String which correspond to an int
    public func saveKeyWithName(nameString name: String){
        let keyArray = KeyId()
        var nameList = keyArray.getKeyName()
        if nameList.contains(oldName){ // If old name where in the array, we replace it
           nameList.remove(at: nameList.firstIndex(of: oldName)!)
        }
        nameList.append(name)
        keyArray.stockNewNameIdArray(nameList)
        //enregsitrement dans la keyChain:
        let successfulSave:Bool = KeychainWrapper.standard.set("\(self.keyTextView.text!)", forKey: name)
        if successfulSave {
                //
                //SUCCÈS ::
                //
                NotificationCenter.default.post(name: Encrypt.notificationOfNewKey, object: nil, userInfo:["addKey success" : true])
                //get date
            let formatter:DateFormatter = DateFormatter()
                formatter.dateFormat = "DD/MM/YYY"
            //let todayDate:NSDate = formatter.date(from: Date().description(with: .current))! as NSDate
                if self.viewOnBack == "ShowKey"{
                    NotificationCenter.default.post(name: ShowKey.notificationOfModificationName, object: nil, userInfo: ["name": self.nameKeyField.text!, "key": self.keyTextView.text!])
                }
                dismissView()
        }
    }
    
    public func verify(name:String?,key:String?) -> Bool{
        print("[*] Verify func called")
        let keyArray = KeyId()
        if name == ""{
            self.nameError.setTitle("A key needs a name".localized(withKey: "nameError"), for: .normal)
            flip(firstView: self.nameKeyField, secondView: self.nameError)
            return false
        } else if key == "" || key == self.keyTextViewPlaceholder{
            self.publicKeyError.setTitle("Please, enter a key".localized(withKey: "noKeyError"), for: .normal)
            self.flip(firstView: keyTextView, secondView: self.publicKeyError)
            return false
        } else {
            // Check if the key is valid :
            if !KeyId().checkKeyValidity(key!){
                self.publicKeyError.setTitle("Key isn't valid ! \nIt must be generated by the iLocked app and must not be modified".localized(withKey: "invalidKey"), for: .normal)
                self.flip(firstView: keyTextView, secondView: self.publicKeyError)
                return false
            }
        }
        let nameList = keyArray.getKeyName()
        print("nameList in addKey = \(nameList)")
        if nameList.count != 0{
            if nameList.contains("##ERROR##"){
                self.publicKeyError.setTitle(nameList[0], for: .normal)
                flip(firstView: self.keyTextView, secondView: self.publicKeyError)
                return false
            } else if oldName == "" { // we don't have any error
                for forbiddenName in self.forbiddenKeyName{
                    if key == forbiddenName{ // Forbidden name
                        self.nameError.setTitle("This name are forbidden. Try another one".localized(withKey: "forbiddenError"), for: .normal)
                        flip(firstView: self.nameKeyField, secondView: self.nameError)
                        return false
                    }
                }
            }
            print("nameList in addKey = \(nameList)")
            for name in nameList { // we verify if the name already exist
                print("name already stored = \(name)\n")
                if name == self.nameKeyField.text! && self.nameKeyField!.text != oldName{
                    self.nameError.setTitle("This name is already taken !".localized(withKey: "takenError"), for: .normal)
                    flip(firstView: self.nameKeyField, secondView: self.nameError)
                    return false
                }
            }
        }
        // If we haven't already returned false, it must be true
        // If the user already have 5 keys, isn't premium and isn't editing a existing key
        if nameList.count >= 5 && !self.checkIfPremium() && self.oldKey == ""{
            print("[*] Max key reached")
            performSegue(withIdentifier: "upgrade", sender: self)
            return false
        }
        
        return true // If we haven't already returned false, it must be true
    }
    
    
    func checkIfPremium() -> Bool {
        if InAppPurchase.hasActivePurchase(for: "nonConsumableId") {
          return true
        }
        return false
    }
    
}

