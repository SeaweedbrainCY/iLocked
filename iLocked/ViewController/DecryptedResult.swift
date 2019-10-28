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
    
    var encryptedText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.barView.layer.cornerCurve = .circular
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //Call when the user tap once or twice on the home button
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        let decryptMethod = Decryption()
        self.decryptedTextView.text = decryptMethod.decryptText(encryptedText)
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
