//
//  DecryptedResult.swift
//  iLocked
//
//  Created by Nathan on 21/10/2019.
//  Copyright © 2019 Nathan. All rights reserved.
//

import Foundation
import UIKit

class DecryptedResult : UIViewController{
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var closeButtonBackgroundView: UIView!
    @IBOutlet weak var decryptedTextView: UITextView!
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bottomMessageLabel: UILabel!
    @IBOutlet weak var topBarView: UIView!
    
    
    
    var encryptedText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.barView.layer.cornerCurve = .circular
        self.decryptedTextView.centerVertically()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //Call when the user tap once or twice on the home button
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        let decryptMethod = Decryption()
        let clearTextResult = decryptMethod.decryptText(encryptedText)
        if (clearTextResult["state"] as! Bool) == true{
            self.decryptedTextView.text = (clearTextResult["message"] as! String)
        } else {
            self.decryptedTextView.text = (clearTextResult["message"] as! String)
            self.decryptedTextView.textColor = .white
            self.decryptedTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true
            self.decryptedTextView.centerXAnchor.constraint(equalToSystemSpacingAfter: self.view.centerXAnchor, multiplier: 1).isActive = true
            self.decryptedTextView.centerYAnchor.constraint(equalToSystemSpacingBelow: self.view.centerYAnchor, multiplier: 1).isActive = true
            self.decryptedTextView.backgroundColor = .red
            self.decryptedTextView.layer.cornerRadius = 20
            self.decryptedTextView.layer.borderColor = UIColor.red.cgColor
            self.view.backgroundColor = .red
            self.decryptedTextView.layer.borderWidth = 2
            self.bottomMessageLabel.text = "The message must be encrypted with your own public key and will be decrypted only with your private key."
            self.titleLabel.isHidden = true
            self.topBarView.isHidden = true
            
        }
        
    }
        
        
    
    //
    //@IBOutlet function
    //
    
    @IBAction func closButtonSelected(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    //
    // Objective C func
    //
    
    /// Called by notification when the app is moves to background
    @objc private func appMovedToBackground(){
        performSegue(withIdentifier: "lockApp", sender: self)
    }
    
    //
    //segue
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "lockApp"{
            let lockedView = segue.destination as! LockedView
            lockedView.activityInProgress = true
        }
    }
    
}
