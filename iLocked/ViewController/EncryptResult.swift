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
    
    var titleLabel = UILabel()
    
    var key = UIImageView()
    var keyName = UIImageView()
    var encryptedText = UITextView()
    var shareButton = UIButton()
    var infoLabel = UILabel()
    
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
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
                
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
        
        self.background.addSubview(self.titleLabel)
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.leftAnchor.constraint(equalToSystemSpacingAfter: self.scrollView.leftAnchor, multiplier: 2).isActive = true
        self.titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.scrollView.topAnchor, multiplier: 2).isActive = true
        self.titleLabel.font = UIFont(name: "Arial Rounded MT Bold", size: 25)
        self.titleLabel.textColor = .white
        self.titleLabel.text = "Encrypted text :"
        
        
        self.background.addSubview(self.encryptedText)
        self.encryptedText.translatesAutoresizingMaskIntoConstraints = false
        self.encryptedText.centerXAnchor.constraint(equalToSystemSpacingAfter: self.scrollView.centerXAnchor, multiplier: 1).isActive = true
        self.encryptedText.topAnchor.constraint(equalToSystemSpacingBelow: self.titleLabel.bottomAnchor, multiplier: 4).isActive = true
        self.encryptedText.widthAnchor.constraint(equalToConstant: self.scrollView.frame.size.width - 40).isActive = true
        self.encryptedText.heightAnchor.constraint(equalToConstant: 200).isActive = true
        self.encryptedText.isEditable = false
        self.encryptedText.rondBorder()
        self.encryptedText.layer.borderWidth = 2
        self.encryptedText.layer.borderColor = UIColor.systemRed.cgColor
        self.encryptedText.textColor = .systemOrange
        self.encryptedText.font = UIFont(name: "American Typewriter", size: 19)
        self.encryptedText.text = self.encryptedTextTransmitted
        
        self.background.addSubview(self.shareButton)
        self.shareButton.translatesAutoresizingMaskIntoConstraints = false
        self.shareButton.centerXAnchor.constraint(equalToSystemSpacingAfter: self.scrollView.centerXAnchor, multiplier: 1).isActive = true
        self.shareButton.topAnchor.constraint(equalToSystemSpacingBelow: self.encryptedText.bottomAnchor, multiplier: 4).isActive = true
        self.shareButton.widthAnchor.constraint(equalToConstant: self.view.frame.size.width - 40).isActive = true
        self.shareButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        if #available(iOS 13.0, *) {
            self.shareButton.setImage(UIImage(systemName: "square.and.arrow.up") , for: .normal)
        }
        self.shareButton.backgroundColor = UIColor(red: 0.121, green: 0.13, blue: 0.142, alpha: 1)
        self.shareButton.setTitleColor(.white, for: .normal)
        self.shareButton.setTitle("Share the encrypted text", for: .normal)
        self.shareButton.tintColor = .systemOrange
        self.shareButton.titleLabel?.font = UIFont(name: "Arial Rounded MT Bold", size: 17)
        self.shareButton.rondBorder()
        self.shareButton.addTarget(self, action: #selector(shareMainButtonSelected), for: .touchUpInside)
        
        self.background.addSubview(self.infoLabel)
        self.infoLabel.translatesAutoresizingMaskIntoConstraints = false
        self.infoLabel.centerXAnchor.constraint(equalToSystemSpacingAfter: self.scrollView.centerXAnchor, multiplier: 1).isActive = true
        self.infoLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.shareButton.bottomAnchor, multiplier: 4).isActive = true
        self.infoLabel.widthAnchor.constraint(equalToConstant: self.scrollView.frame.size.width - 60).isActive = true
        self.infoLabel.textAlignment = .center
        self.infoLabel.numberOfLines = 6
        self.infoLabel.font = UIFont(name: "Arial Rounded MT Bold", size: 15)
        self.infoLabel.textColor = .lightGray
        self.infoLabel.text = "Your text is now encrypted with your friend's public key. Share this new text with him. Only his own PRIVATE key will be able to decrypt this text. Remember : to encrypt a message for someone, please use his personnal public key ! Not yours....."
        
        
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
    
    /// Called by notification when the app is moves to background
    @objc private func appMovedToBackground(){
        performSegue(withIdentifier: "lockApp", sender: self)
    }
    
    @objc private func shareMainButtonSelected(sender: UIButton){
        let activityViewController = UIActivityViewController(activityItems: ["\(self.encryptedText.text!)" as NSString], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
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

