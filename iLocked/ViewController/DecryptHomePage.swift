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
    @IBOutlet weak var textToDecryptView: UITextView!
    @IBOutlet weak var decryptButton: UIButton!
    @IBOutlet weak var pasteButton : UIButton!
    @IBOutlet weak var dismissKeyboardButton : UIButton!
    
    
    //Help views
    let helpTextView = UITextView()
    let helpView = UIView()
    let quitButton = UIButton()
    let backgroundInfo = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.dark))
    var closeHelpButtonView = UIButton() // cover the background info view, and close help if touched
    
    var textToDecryptViewErrorMessage = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewConstruction()
        self.textToDecryptView.delegate = self
        
        // Is called when the keyboard will show
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let settings = SettingsData()
        settings.shouldAskForReview()
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
        
        
        
        self.textToDecryptViewErrorMessage.center = textToDecryptView.center
        self.textToDecryptViewErrorMessage.frame.size = self.textToDecryptView.frame.size
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
        self.helpTextView.showsVerticalScrollIndicator = true
        
        // paste button
        self.pasteButton.layer.cornerRadius = 15
        // round some button :
        self.dismissKeyboardButton.layer.cornerRadius = 10
        self.decryptButton.layer.cornerRadius = 10
        
        // textToDecrypt
        self.textToDecryptView.text = "Text to decrypt".localized()
    }
    
    
    //
    //IBAction functions
    //
    
    @IBAction func decryptButton(_ sender: UIButton) {
        var isOk = true
        if textToDecryptView.text == "" || textToDecryptView.text == "Text to decrypt".localized(){
            isOk = false
            alert("Please, enter an encrypted text".localized(), message: "", quitMessage: "Ok")
        }
        
        if isOk {
            //Tests passé, on passe au décryptage:
            performSegue(withIdentifier: "showDecryptedText", sender: self)
        }
    }
    
    @IBAction func closeKeyboard(sender: UIButton){ //down keyboard button
            self.view.endEditing(true)
    }
    
    
    @IBAction func pasteButtonSelected(sender: UIButton){
        let content = UIPasteboard.general.string
        if content == "" || content == nil{
            shakeAnimation(view: self.pasteButton,text: "Paste".localized())
        } else {
            self.textViewDidBeginEditing(self.textToDecryptView)
            self.textToDecryptView.text = content!
            self.textViewDidEndEditing(self.textToDecryptView)
            self.decryptButton(self.decryptButton)
        }
        
    }
    
    @IBAction func infoButtonSelected(_ sender: Any) {
        if self.helpBarButtonItem.image == UIImage(systemName: "info.circle"){
            let helpText = """
                ⚠️ CONFIDENTIALITY : iLocked NEVER (never) keeps or shares your messages.
                That is why, the app doesn't require any internet connection to encrypt, decrypt or store a key ! What's in your iPhone, stays in your iPhone.
                
                
                
                
                📨 To decrypt a message encrypted with your own public key, just copy and past the text in the field. Then click on the decrypt button.
                
                A new window will be opened and will show the decrypted message.
                
                🙇 IMPORTANT : Be sure that the sender encrypted his message with your public key and be careful to copy the whole text. No more no less. Or it's gonna be wierd . . .
                """.localized(withKey: "helpText")
            self.showHelp(text: helpText)
        } else {
            closeHelp()
        }
    }
    
 
    //
    // Text view Delegate func
    //
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Text to decrypt".localized(){
            textView.text = ""
            textView.textColor = UIColor.white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView){
        self.dismissKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        self.decryptButton.translatesAutoresizingMaskIntoConstraints = false
        if textView.text == "" {
            textView.text = "Text to decrypt".localized()
            textView.textColor = .darkGray
        }
    }
    
    //
    // Objetctive C call func
    //
    
    @objc private func textToDecryptErrorMessageSelected(sender: UIButton){
        self.flip(firstView: textToDecryptViewErrorMessage, secondView: self.textToDecryptView)
    }
    
    @objc func keyboardWillHide(_ notification : Notification){
        self.dismissKeyboardButton.isHidden = true
        self.dismissKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        self.decryptButton.translatesAutoresizingMaskIntoConstraints = false
        expandTextView()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.dismissKeyboardButton.translatesAutoresizingMaskIntoConstraints = true
            
            self.decryptButton.translatesAutoresizingMaskIntoConstraints = true
            let decryptButton_x = self.dismissKeyboardButton.frame.origin.x + self.dismissKeyboardButton.frame.width + 20
            let decryptButton_y = self.view.frame.height - keyboardHeight - self.decryptButton.frame.height - 10
            let decryptButton_width = self.view.frame.width - self.dismissKeyboardButton.frame.width - 60 // 60 because the button is at 20 pt from the right border, 20 pt from the dismissKeyboard button, which is at 20 pt from the left border
            self.decryptButton.frame = CGRect(x: decryptButton_x, y: decryptButton_y, width: decryptButton_width, height: self.decryptButton.frame.height)
            
            self.dismissKeyboardButton.frame.origin.y = self.view.frame.height - keyboardHeight - self.dismissKeyboardButton.frame.height - 10
            self.dismissKeyboardButton.isHidden = false
            
            
            reduceTextView(keyboardHeight: keyboardHeight)
        }
    }
    
    @objc func closeHelpSelected(sender: UIButton){
        closeHelp()
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
    
    func shakeAnimation(view: UIButton, text : String){
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: view.center.x - 10, y: view.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: view.center.x + 10, y: view.center.y))
        
        let titleChange = UIViewPropertyAnimator(duration: 0.28, dampingRatio: 0.7, animations: {
            view.setTitle(text, for: .normal)
        })
        view.layer.add(animation, forKey: "position")
        titleChange.startAnimation()
    }
    
    /// Expand the height of textToEncrypt view, it was reduced to fit with the keyboard heigth
    func expandTextView(){
        self.textToDecryptView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// Reduce the height of textToEncrypt view, to fit with the keyboard height
    func reduceTextView(keyboardHeight:CGFloat){
        self.textToDecryptView.translatesAutoresizingMaskIntoConstraints = true
        let height = self.view.frame.height - keyboardHeight - self.decryptButton.frame.height - self.textToDecryptView.frame.origin.y - 20
        self.textToDecryptView.frame = CGRect(x: self.textToDecryptView.frame.origin.x, y: self.textToDecryptView.frame.origin.y, width: self.textToDecryptView.frame.width, height: height)
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
            decryptedResultView.encryptedText = self.textToDecryptView.text
        }
    }
}
