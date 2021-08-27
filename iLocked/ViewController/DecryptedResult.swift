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
    @IBOutlet weak var errorMessage : UILabel!
    @IBOutlet weak var errorTitle: UILabel!
    
    
    
    var encryptedText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViewConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.contructView()
        decryption()
        print("Decryption view did appear")
    }
        
    
    func contructView(){
        print("cgframe = \(self.view.frame)")
        self.barView.layer.cornerCurve = .circular
        //self.decryptedTextView.centerVertically()
        print("Error message frame = \(self.errorMessage.frame)")
        self.errorMessage.translatesAutoresizingMaskIntoConstraints = true
        
        self.errorMessage.frame = CGRect(x: 0, y: 0, width: self.view.frame.width - 40, height: self.view.frame.height / 3)
        self.errorMessage.center = self.view.center
        print("Error message frame (new) = \(self.errorMessage.frame)")
        self.errorMessage.layer.borderColor = UIColor.red.cgColor
        self.errorMessage.layer.cornerRadius = 10
        self.errorMessage.layer.borderWidth = 1.5
        self.errorMessage.backgroundColor = UIColor(red: 251/255, green: 233/255, blue: 232/255, alpha: 1)
        self.errorMessage.layer.masksToBounds = true
        self.errorMessage.textColor = .black
        
        self.errorImage.translatesAutoresizingMaskIntoConstraints = true
        self.errorImage.frame.origin = CGPoint(x: self.errorMessage.frame.origin.x + 12, y: self.errorMessage.frame.origin.y - self.errorImage.frame.height / 2)
        self.errorImage.tintColor = .black
        
        self.errorTitle.translatesAutoresizingMaskIntoConstraints = true
        self.errorTitle.frame.origin = CGPoint(x: self.errorMessage.frame.origin.x + 10, y: self.errorMessage.frame.origin.y  - self.errorTitle.frame.height / 2)
        self.errorTitle.layer.cornerRadius = 10
        self.errorTitle.layer.borderColor = UIColor.red.cgColor
        self.errorTitle.layer.borderWidth = 1.5
        self.errorTitle.layer.masksToBounds = true
        self.errorTitle.backgroundColor = UIColor(red: 251/255, green: 233/255, blue: 232/255, alpha: 1)
        self.errorTitle.textColor = .black
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
            let clearText = (clearTextResult["message"] as! String)
            print("Clear text = \(clearText)")
            self.decryptedTextView.text = clearText
        } else {
            let codeError = (clearTextResult["codeError"] as! Int)
            let spaceBeforeTitle = "         "
            switch codeError {
            case decryptMethod.codeErrorFormatInvalid:
                self.errorImage.image = UIImage(systemName: "text.badge.xmark")
                self.errorTitle.text = spaceBeforeTitle + "Bad format".localized()
            case decryptMethod.codeErrorNoPrivateKey:
                self.errorImage.image = UIImage(systemName: "externaldrive.fill.badge.xmark")
                self.errorTitle.text = spaceBeforeTitle + "Bad key".localized()
            case decryptMethod.codeErrorKeyIncorrect:
                self.errorImage.image = UIImage(systemName: "lock.circle")
                self.errorTitle.text = spaceBeforeTitle + "Bad key".localized()
            default:
                self.errorImage.image = UIImage(systemName: "lock.circle")
            }
            self.errorMessage.text = (clearTextResult["message"] as! String)
            self.errorImage.isHidden = false
            self.errorTitle.isHidden = false
            self.errorMessage.isHidden = false
            self.decryptedTextView.isHidden = true
            self.bottomMessageLabel.text = "The message must be encrypted with your own public key and will be decrypted only with your private key.".localized(withKey: "infoEncryption")
            self.titleLabel.isHidden = true
            self.topBarView.isHidden = true
            
        }
    }
    
}
