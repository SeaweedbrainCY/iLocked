//
//  Revoke.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 21/12/2020.
//  Copyright © 2020 Nathan. All rights reserved.
//

import Foundation
import UIKit
import LocalAuthentication

class Revoke: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var revokeButton: UIButton!
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet var warningImage: UIView!
    
    static let notificationOfAuthenticationName = Notification.Name("notificationOfAuthenticationResult")
    
    var timer: Timer!
    var timerWarning :Timer!
    var second = 0 //Count the number of seconds passed
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cancelButton.layer.cornerRadius = 10
        self.revokeButton.layer.cornerRadius = 10
        
        //Wait for user authentication
        NotificationCenter.default.addObserver(self, selector: #selector(editKeyResult), name: Revoke.notificationOfAuthenticationName, object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //Start the timer
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        timerWarning = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimeWarning), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        timerWarning.invalidate()
    }
    
    /// Simple pop-up with one cancel button
    func alert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: {_ in
            self.dismiss(animated: true, completion: nil)
        })
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func updateTime(){
        self.second += 1
        if self.second >= 5{ // Button is now enabled
            timer.invalidate()
            self.revokeButton.setTitle("REVOKE".localized(), for: .normal)
            self.revokeButton.isEnabled = true
            self.revokeButton.backgroundColor = .systemRed
        }else if self.second < 0 {
            timer.invalidate()
            second = 0
            self.dismiss(animated: true, completion: nil)
        } else{
            self.revokeButton.setTitle("REVOKE".localized() + "(\(5 - self.second)s)", for: .normal)
        }
    }
    
    @objc private func updateTimeWarning(){
        print("[*] Timer warning")
        self.warningImage.isHidden = !self.warningImage.isHidden
    }
    
    @IBAction func closeView(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func revokeKeys(sender:UIButton){
        askForPassword()
    }
    
    /// Ask password to confirm the selection
    /// - return: true means there is no password or the identification is Ok. Else, it's false
    private func askForPassword(){
        var policy: LAPolicy!
        let context: LAContext!
        if #available(iOS 9.0, *) {
            policy = .deviceOwnerAuthentication
            context = .init()
            let error: NSErrorPointer! = NSErrorPointer.none
            var succeed = false
            guard context?.canEvaluatePolicy(policy, error: error) ?? false else {
                //iDevice doesn't have any password
                succeed = true
                return
            }
            if succeed{
                print("No authentication needed. authentication succeed")
                NotificationCenter.default.post(name: ShowKey.notificationOfModificationName, object: nil, userInfo: ["Result" : true])
            } else {
                let message = "confirm keys revocation".localized()
            context?.evaluatePolicy(policy!, localizedReason: message, reply: { (success, error) in
                DispatchQueue.main.async {
                    if success {
                        NotificationCenter.default.post(name: Revoke.notificationOfAuthenticationName, object: nil, userInfo: ["Result" : true])
                        return
                    }
                    guard success else {
                        guard error != nil else {
                            succeed = true
                            print("Authentication succeed")
                            NotificationCenter.default.post(name: Revoke.notificationOfAuthenticationName, object: nil, userInfo: ["Result" : true])
                        return
                    }
                        print("Authentication failed")
                        NotificationCenter.default.post(name: Revoke.notificationOfAuthenticationName, object: nil, userInfo: ["Result" : false])
                        return
                }
                }
                
            })
            }
        } else {
            print("This iOS version is not supported. authentication failed")
            NotificationCenter.default.post(name: ShowKey.notificationOfModificationName, object: nil, userInfo: ["Result" : false])
        }
    }
    
    /// Called if authentication after revocation demand succeed
    private func destroyKey(){
        KeychainWrapper.standard.removeObject(forKey:  UserKeys.publicKey.tag)
        KeychainWrapper.standard.removeObject(forKey:  UserKeys.privateKey.tag)
        self.performSegue(withIdentifier: "lockApp", sender: self)
    }
    
    /// Called if authentication succeed after revocation demand failed
    private func fail(){
        alert("Authentication failed".localized(), message: "You must authenticate yourself to revoke your keys. Please, try Again".localized(withKey: "authErrorRevoke"))
    }

    
    // Called when authentification process is finished
    @objc private func editKeyResult(notification: Notification){
        print("Authentication notification received")
        let notificationData = notification.userInfo
        let hasSucceed = notificationData?["Result"] as! Bool
        if hasSucceed {
            self.destroyKey()
        } else {
            self.fail()
        }
    }
}
