//
//  DecryptHomePage.swift
//  iLocked
//
//  Created by Nathan on 30/08/2019.
//  Copyright © 2019 Nathan. All rights reserved.
//

import Foundation
import UIKit


class Decrypt: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var helpBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var sharePublicKeyButton: UIButton!
    @IBOutlet weak var helpAboutSharingButton: UIButton!
    @IBOutlet weak var textToEncryptView: UITextView!
    @IBOutlet weak var encryptButton: UIButton!
    @IBOutlet weak var leftItemButton : UIBarButtonItem!
    
    
    //Help views
    let helpTextLabel = UILabel()
    let helpView = UIView()
    let quitButton = UIButton()
    let backgroundInfo = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.dark))
    
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
        
        self.view.addSubview(self.backgroundInfo)
        self.backgroundInfo.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundInfo.heightAnchor.constraint(equalToConstant: self.view.frame.size.height).isActive = true
        self.backgroundInfo.widthAnchor.constraint(equalToConstant: self.view.frame.size.width).isActive = true
        self.backgroundInfo.centerYAnchor.constraint(equalToSystemSpacingBelow: self.view.centerYAnchor, multiplier: 1).isActive = true
        self.backgroundInfo.centerYAnchor.constraint(equalToSystemSpacingBelow: self.view.centerYAnchor, multiplier: 1).isActive = true
        self.backgroundInfo.alpha = 0
        
        
        
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
        
        //helpView :
        
        self.view.addSubview(self.helpView)
        self.helpView.frame.size.height = self.view.frame.size.height / 2
        self.helpView.frame.size.width = self.view.frame.size.width - 20
        self.helpView.center = self.view.center
        self.helpView.backgroundColor = .none
        self.helpView.alpha = 0
        
        
        self.helpView.addSubview(self.helpTextLabel)
        self.helpTextLabel.translatesAutoresizingMaskIntoConstraints = false
        self.helpTextLabel.widthAnchor.constraint(equalToConstant: self.helpView.frame.size.width - 20).isActive = true
        self.helpTextLabel.heightAnchor.constraint(equalToConstant: self.helpView.frame.size.height
             - 10).isActive = true
        self.helpTextLabel.centerXAnchor.constraint(equalToSystemSpacingAfter: self.helpView.centerXAnchor, multiplier: 1).isActive = true
        self.helpTextLabel.centerYAnchor.constraint(equalToSystemSpacingBelow: self.helpView.centerYAnchor, multiplier: 1).isActive = true
        self.helpTextLabel.numberOfLines = 20
        self.helpTextLabel.textAlignment = .justified
        self.helpTextLabel.font = UIFont(name: "American Typewriter", size: 16.0)
        self.helpTextLabel.textColor = .white
    }
    
    
    //
    //IBAction functions
    //
    
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
    
    @IBAction func closeKeyboard(sender: UIBarButtonItem){ // left bar button item selected
        if sender.image == UIImage(systemName: "keyboard.chevron.compact.down"){ //down keyboard button
            self.view.endEditing(true)
        } else if sender.image == UIImage(systemName: "multiply.circle.fill"){ //close help button
            self.closeHelp()
        } else {//help asked
            self.showHelp(text: "To decrypt a message encrypted with your own public key, just copy and past the text in the field. Then click on the green key.\n\n A new window will be opened and will show the decrypted message. \n\n IMPORTANT : Be sure that the sender encrypted his message with your public key and be careful to copy the whole text. No more no less. Or it's gonna be wierd . . .")
        }
    }
    
    @IBAction func shareButtonHelp(sender: UIButton){
        self.showHelp(text: "Share your public key to your friend. Only this key can encrypt message that you'll be able to decrypt. \n\nUse an other key, including sender public key will return you an error if you try to decrypt the message.")
    }
    
    
 
    //
    // Text view Delegate func
    //
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.translatesAutoresizingMaskIntoConstraints = true
        self.helpBarButtonItem.image = UIImage(systemName: "keyboard.chevron.compact.down")
        self.leftItemButton.image = UIImage(systemName: "info.circle")
        self.leftItemButton.tintColor = .systemOrange
        
        textView.frame.origin.y = 10
        if textView.text == "Text to decrypt" {
            textView.text = ""
            textView.textColor = UIColor.white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView){
        textView.translatesAutoresizingMaskIntoConstraints = false
        self.helpBarButtonItem.image = UIImage(systemName: "info.circle")
        self.leftItemButton.image = nil
        
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
    
    func showHelp(text: String){
        self.helpBarButtonItem.image = UIImage(systemName: "multiply.circle.fill")
        self.helpView.layer.borderColor = UIColor.white.cgColor
        self.helpTextLabel.text = text
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
