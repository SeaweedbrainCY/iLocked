//
//  DecryptHomePage.swift
//  iLocked
//
//  Created by Nathan on 30/08/2019.
//  Copyright © 2019 Nathan. All rights reserved.
//

import Foundation
import UIKit
import SwiftKeychainWrapper

class Decrypt: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var helpBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var sharePublicKeyButton: UIButton!
    @IBOutlet weak var helpAboutSharingButton: UIButton!
    @IBOutlet weak var textToEncryptView: UITextView!
    @IBOutlet weak var encryptButton: UIButton!
    
    var textToDecryptViewErrorMessage = UIButton()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        viewConstruction()
        self.textToEncryptView.delegate = self
        
        //Call when the user tap once or twice on the home button
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    
    
    
    //ferme le clavier au toucher
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func alert(_ title: String, message: String, quitMessage: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: quitMessage, style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }

    //
    // Views construction func
    //
    
    private func viewConstruction(){
        self.sharePublicKeyButton.rondBorder()
        self.sharePublicKeyButton.backgroundColor = UIColor(red: 0.121, green: 0.13, blue: 0.142, alpha: 1)
        self.textToEncryptView.layer.borderColor = UIColor.lightGray.cgColor
        self.textToEncryptView.layer.borderWidth = 2
        self.textToEncryptView.layer.cornerRadius = 20
        self.textToDecryptViewErrorMessage.center = textToEncryptView.center
        self.textToDecryptViewErrorMessage.frame.size = self.textToEncryptView.frame.size
        self.textToDecryptViewErrorMessage.titleLabel?.font = UIFont(name: "Arial Rounded MT Bold", size: 18)
        self.textToDecryptViewErrorMessage.setTitleColor(.systemRed, for: .normal)
        self.textToDecryptViewErrorMessage.layer.cornerRadius = 15
        self.textToDecryptViewErrorMessage.layer.borderWidth = 1
        self.textToDecryptViewErrorMessage.layer.borderColor = UIColor.white.cgColor
        self.textToDecryptViewErrorMessage.backgroundColor = .white
        self.textToDecryptViewErrorMessage.isHidden = true
        self.textToDecryptViewErrorMessage.addTarget(self, action: #selector(textToDecryptErrorMessageSelected), for: .touchUpInside)
        
    }
    
    //IBAction functions
    
    @IBAction func decryptButton(_ sender: UIButton) {
        var isOk = true
        if textToEncryptView.text == "" || textToEncryptView.text == "Text to decrypt"{
            isOk = false
            alert("I don't really think decrypt an empty message is very useful ... 🧐", message: "", quitMessage: "Oh yeah sorry !")
        }
        
        if isOk {
            //Tests passé, on passe au décryptage:
            performSegue(withIdentifier: "showDecryptedText", sender: self)
        }
    }
    
    @IBAction func shareButtonSelected(sender: UIButton){
        if let publicKey: String = KeychainWrapper.standard.string(forKey: userPublicKeyId) {
            let activityViewController = UIActivityViewController(activityItems: ["\(publicKey)" as NSString], applicationActivities: nil)
            present(activityViewController, animated: true, completion: {})
        } else {
            alert("Impossible to access to your public key", message: "An error occur when trying to get the access to your public key", quitMessage: "Let's try again !")
        }
        
    }
    
    
    
    //
    // Text view Delegate func
    //
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.translatesAutoresizingMaskIntoConstraints = true
        textView.frame.origin.y = 10
        if textView.text == "Text to decrypt" {
            textView.text = ""
            textView.textColor = UIColor.white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView){
        textView.translatesAutoresizingMaskIntoConstraints = false
        if textView.text == "" {
            textView.text = "Text to decrypt"
            textView.textColor = .lightGray
        }
    }
    
    //
    // Objetctive C call func
    //
    
    @objc private func textToDecryptErrorMessageSelected(sender: UIButton){
        self.flip(firstView: textToDecryptViewErrorMessage, secondView: self.textToEncryptView)
    }
    
    /// Called by notification when the app is moves to background
    @objc private func appMovedToBackground(){
        performSegue(withIdentifier: "lockApp", sender: self)
    }
    
    //
    // Animationfunction
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
    
    //
    // segue func
    //
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "lockApp"{
            let lockedView = segue.destination as! LockedView
            lockedView.activityInProgress = true
        } else if segue.identifier == "showDecryptedText"{
            let decryptedResultView = segue.destination as! DecryptedResult
            decryptedResultView.encryptedText = self.textToEncryptView.text
        }
    }
}
