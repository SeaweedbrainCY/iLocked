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
    @IBOutlet weak var errorImage : UIImageView!
    
    
    
    var encryptedText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.barView.layer.cornerCurve = .circular
        self.decryptedTextView.centerVertically()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        decryption()
        
    }
        
        
    
    //
    //@IBOutlet function
    //
    
    @IBAction func closButtonSelected(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
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
    
    //
    // Data
    //
    
    public func decryption(){
        let decryptMethod = Decryption()
        let clearTextResult = decryptMethod.decryptText(encryptedText)
        if (clearTextResult["state"] as! Bool) == true{
            self.decryptedTextView.text = (clearTextResult["message"] as! String)
        } else {
            let codeError = (clearTextResult["codeError"] as! Int)
            switch codeError {
            case decryptMethod.codeErrorFormatInvalid:
                self.errorImage.image = UIImage(systemName: "text.badge.xmark")
            case decryptMethod.codeErrorNoPrivateKey:
                self.errorImage.image = UIImage(systemName: "externaldrive.fill.badge.xmark")
            case decryptMethod.codeErrorKeyIncorrect:
                self.errorImage.image = UIImage(systemName: "lock.circle")
            default:
                self.errorImage.image = UIImage(systemName: "lock.circle")
            }
            self.errorImage.tintColor = .white
            self.errorImage.isHidden = false
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
    
}
