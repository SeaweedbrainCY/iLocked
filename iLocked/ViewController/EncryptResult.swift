//
//  EncryptResult.swift
//  iLocked
//
//  Created by Nathan on 27/07/2019.
//  Copyright © 2019 Nathan. All rights reserved.
//

import Foundation
import UIKit

class EncryptedResult: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var background: UIView!
    
    var key = UIImageView()
    var keyName = UIImageView()
    var encryptedText = UITextView()
    var shareButton = UIButton()
    var infoLabel = UILabel()
    var copyButton = UIButton()
    var notificationView = UIButton()
    
    var clearTextTransmitted = ""
    var encryptedTextTransmitted = ""
    var keyNameTransmitted = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.delegate = self
        self.loadViews()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        //Call when the user tap once or twice on the home button
        let tap = UITapGestureRecognizer(target: self, action: #selector(copyButtonSelected))
            tap.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(tap)
    }
    
    
    
    //
    // Contruct view functions
    //
    
    func alert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func loadViews(){
        
        
        self.background.addSubview(self.encryptedText)
        self.encryptedText.translatesAutoresizingMaskIntoConstraints = false
        self.encryptedText.centerXAnchor.constraint(equalToSystemSpacingAfter: self.scrollView.centerXAnchor, multiplier: 1).isActive = true
        self.encryptedText.topAnchor.constraint(equalToSystemSpacingBelow: self.scrollView.topAnchor , multiplier: 2).isActive = true
        self.encryptedText.widthAnchor.constraint(equalToConstant: self.view.frame.size.width - 5).isActive = true
        self.encryptedText.heightAnchor.constraint(equalToConstant: 3*self.scrollView.frame.size.height / 5).isActive = true
        self.encryptedText.isEditable = false
        self.encryptedText.isSelectable = false
        self.encryptedText.textColor = .white
        self.encryptedText.text = self.encryptedTextTransmitted
        self.encryptedText.font = UIFont(name: "American Typewriter", size: 15)
        self.encryptedText.backgroundColor = Colors.darkGray6.color
        
        
        self.background.addSubview(self.shareButton)
        self.shareButton.translatesAutoresizingMaskIntoConstraints = false
        self.shareButton.widthAnchor.constraint(equalToConstant: self.view.frame.width*0.4).isActive = true
        self.shareButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        self.shareButton.rightAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -4).isActive=true
        self.shareButton.topAnchor.constraint(equalToSystemSpacingBelow: self.encryptedText.bottomAnchor, multiplier: 1).isActive = true
        self.shareButton.setImage(UIImage(systemName: "arrowshape.turn.up.right") , for: .normal)
        self.shareButton.backgroundColor = UIColor(red: 0.121, green: 0.13, blue: 0.142, alpha: 1)
        self.shareButton.setTitleColor(.white, for: .normal)
        self.shareButton.tintColor = .systemOrange
        self.shareButton.rondBorder()
        self.shareButton.addTarget(self, action: #selector(self.shareMainButtonSelected), for: .touchUpInside)
        
        self.view.addSubview(self.copyButton)
        self.copyButton.translatesAutoresizingMaskIntoConstraints = false
        self.copyButton.widthAnchor.constraint(equalToConstant: self.view.frame.width*0.4).isActive = true
        self.copyButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        self.copyButton.leftAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 4).isActive=true
        self.copyButton.topAnchor.constraint(equalToSystemSpacingBelow: self.encryptedText.bottomAnchor, multiplier: 1).isActive = true
        self.copyButton.setImage(UIImage(systemName: "doc.on.doc") , for: .normal)
        self.copyButton.backgroundColor = UIColor(red: 0.121, green: 0.13, blue: 0.142, alpha: 1)
        self.copyButton.setTitleColor(.white, for: .normal)
        self.copyButton.tintColor = .systemOrange
        self.copyButton.rondBorder()
        self.copyButton.addTarget(self, action: #selector(self.copyButtonSelected), for: .touchUpInside)
        
        self.background.addSubview(self.infoLabel)
        self.infoLabel.translatesAutoresizingMaskIntoConstraints = false
        self.infoLabel.centerXAnchor.constraint(equalToSystemSpacingAfter: self.scrollView.centerXAnchor, multiplier: 1).isActive = true
        self.infoLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.shareButton.bottomAnchor, multiplier: 4).isActive = true
        self.infoLabel.widthAnchor.constraint(equalToConstant: self.scrollView.frame.size.width - 60).isActive = true
        self.infoLabel.textAlignment = .center
        self.infoLabel.numberOfLines = 6
        self.infoLabel.textColor = .darkGray
        self.infoLabel.font = UIFont(name: "Baskerville", size: 17)
        self.infoLabel.text = "Your message is now encrypted with RSA-4096, a highly secure encryption.".localized()
        //self.infoLabel.text = "Your text is now encrypted with your friend's public key. Share this new text with him. Only his own PRIVATE key will be able to decrypt this text. Remember : to encrypt a message for someone, please use his personnal public key ! Not yours....."
        
        self.background.addSubview(self.notificationView)
        self.notificationView.translatesAutoresizingMaskIntoConstraints = false
        self.notificationView.centerXAnchor.constraint(equalToSystemSpacingAfter: self.view.centerXAnchor, multiplier: 1).isActive = true
        self.notificationView.topAnchor.constraint(equalToSystemSpacingBelow: self.scrollView.topAnchor, multiplier: 1).isActive = true
        self.notificationView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.notificationView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        self.notificationView.layer.borderWidth = 2
        self.notificationView.layer.cornerRadius = 20
        self.notificationView.backgroundColor = .white
        self.notificationView.setTitleColor(.black, for: .normal)
        self.notificationView.alpha = 0
        self.notificationView.setTitle("Copied".localized(), for: .normal)
        self.notificationView.addTarget(self, action: #selector(notificationViewSelected), for: .touchUpInside)
        
    }

    //
    //IBAction function
    //
    
    @IBAction func shareButtonSelected(sender: UIBarButtonItem){
        let activityViewController = UIActivityViewController(activityItems: ["\(self.encryptedText.text!)" as NSString], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
    }
    
    //
    // Objective C func
    //
    
    
    @objc private func shareMainButtonSelected(sender: UIButton){
        let activityViewController = UIActivityViewController(activityItems: ["\(self.encryptedText.text!)" as NSString], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
    }
    
    @objc private func copyButtonSelected(){
        UIPasteboard.general.string = self.encryptedText.text
        let animation = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.5, animations: {
            self.notificationView.alpha = 1
       })
       animation.startAnimation()
        perform(#selector(backToNormal), with: nil, afterDelay: 1.5)
    }
    
    @objc private func backToNormal(){ // reset the button
        let animation = UIViewPropertyAnimator(duration: 0.7, dampingRatio: 0.7, animations: {
            self.notificationView.alpha = 0
       })
       animation.startAnimation()
       
    }
    
    @objc private func notificationViewSelected(sender: UIButton){// If the notification is touched, we hide it
        backToNormal()
    }
    
    //
    // segue
    //
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "lockApp"{
            let lockedView = segue.destination as! LockedView
            lockedView.activityInProgress = true
        }
    }
    
}

