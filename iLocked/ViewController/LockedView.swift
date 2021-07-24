//
//  LockedView.swift
//  iLocked
//
//  Created by Nathan on 21/10/2019.
//  Copyright © 2019 Nathan. All rights reserved.
//
//
//   It's the first view load when the app is opened. It's also the view which lock the
//   session

import Foundation
import UIKit

import Swift
import LocalAuthentication
import Swift

class LockedView: UIViewController{
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var betaLaunchText: UILabel!
    @IBOutlet weak var backFingerprint: UIImageView!
    
    var activityInProgress = false // if it's true, this view is dismissed and doesn't use a segue
    var firstTime = false
    var password = true // password protection activated
    var voluntarilyLocked = false // If it's true, the user tap on a button in order to voluntarily lock the application. So the password/Face id/Touch id isn't automatically asked
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !voluntarilyLocked{
            //Call when the user re-open the app
                let notificationCenter = NotificationCenter.default
                notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        }
        checkForKeys()
        getSetting()
        if !firstTime{
            lockView()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if firstTime {
            performSegue(withIdentifier: "welcome", sender: self)
        }
        if  password && !firstTime {
            askForAuthentification()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        // for some reasons, observers aren't removed when the view is dismissed (??)
        print("[*] Observers removed")
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
    }
    
    deinit {
         print("Remove NotificationCenter Deinit")
        //NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
     }
    
    ///This function checks if there is already a key created
    func checkForKeys(){
        let retrievedString: String? = KeychainWrapper.standard.string(forKey:  UserKeys.publicKey.tag)
        print("view loaded, retrievedString = \(String(describing: retrievedString))")
        if retrievedString == nil || retrievedString == ""{
            firstTime = true
        } else{
            lockView()
        }
    }
    
    //
    // Construction func :
    //
    
    ///This function  appear every times that the app is closed or when the user do anything else that using the app
    func lockView(){
        //On place les boutons assez loins pour l'animation
        self.titleLabel.frame.size.width = self.view.frame.size.width
        self.titleLabel.center = CGPoint(x: self.view.center.x, y: 2000)
        
        self.descriptionLabel.frame.size.width = self.view.frame.size.width - 70
        self.descriptionLabel.numberOfLines = 20
        self.descriptionLabel.frame.size.height = 300
        self.descriptionLabel.center = CGPoint(x: self.view.center.x, y: 2000)
        
        self.actionButton.frame.size.width = 50
        self.actionButton.frame.size.height = 50
        self.actionButton.center = CGPoint(x: self.view.center.x, y: 2000)
        
        //Affichange des View
        self.titleLabel.isHidden = false
        self.descriptionLabel.isHidden = false
        self.actionButton.isHidden = false
        
        //Instanciation des differents textes
        self.titleLabel.text = "" // No title for now 
        self.descriptionLabel.text = ""
        self.actionButton.setImage(UIImage(systemName: "lock.shield.fill"), for: .normal)
        //self.actionButton.layer.cornerRadius = self.actionButton.frame.size.width / 2
        self.actionButton.clipsToBounds = true
            self.logoImageView.layer.cornerRadius = self.logoImageView.frame.size.width / 2;
            self.logoImageView.clipsToBounds = true
            self.logoImageView.alpha = 0
            self.betaLaunchText.alpha = 0
            self.view.backgroundColor = .black
            self.backFingerprint.alpha = 0.5
            self.backFingerprint.isHidden = false
        
        
        //animation pour faire venir les View
        var durationAnimation = 0.5
        if !voluntarilyLocked{ // No time to wait
            durationAnimation = 0
        }
        let animationLabel = UIViewPropertyAnimator(duration: durationAnimation, dampingRatio: 3, animations: {
            self.titleLabel.center = CGPoint(x: self.view.center.x, y: self.view.frame.origin.y + 100)
            self.descriptionLabel.center = CGPoint(x: self.view.center.x, y: self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 50)
            self.actionButton.center = CGPoint(x: self.view.center.x, y: self.view.frame.size.height - self.actionButton.frame.size.height - 20)
            
        })
        animationLabel.startAnimation()
    }
    
    @objc private func appMovedToForeground() {
        if !firstTime {
            if !self.isBeingDismissed {
                print("[*] App moved to foreground")
                if password {
                    askForAuthentification()
                } else {
                    self.perform(#selector(self.dismissCurrentView))
                }
        } else {
                print("[*] App moved to foreground but is not presented")
            }
        } // else app will deal with it alone
    }
    
    
    //
    //IBAction func
    //
    
    @IBAction func actionButtonSelected(sender: UIButton){
            if password {
                askForAuthentification()
            } else {
                self.perform(#selector(self.dismissCurrentView))
            }
            
    }
    
    //
    //Objective C function
    //
    
    ///This func is called to send or dismiss the current view controller
    @objc private func dismissCurrentView(){
        if !activityInProgress {
            print("Activity wasn't in progress")
            performSegue(withIdentifier: "HomePage", sender: self)
        } else {
            dismiss(animated: true, completion: nil)
        }
       
    }
    
    //
    // User interaction func :
    //
    
    //
    // TO DO : tester les différentes erreurs pour laisser uniquement si aucun code n'a JAMAIS été activé
    //
    ///Func who ask to the user is Touch ID / Face ID /
    ///password and manages the response by call an internal function if success
    private func askForAuthentification() {
        
        // first verify if a time before locking is set, and if yes, if it's necessary to ask password
        if isTimeBeforeLockingExceeded() {
        let context = LAContext()
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                let reason = "Your data are protected by a password."

                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
                    [weak self] success, authenticationError in
                    DispatchQueue.main.async {
                        if success {
                            self?.authenfiticationSucceed()
                        } else {
                            // error
                            print("[*] Error : Authentifcation failed")
                            self?.descriptionLabel.textColor = .systemRed
                            self?.descriptionLabel.text = "Authentication failed. 🔒"
                        }
                    }
                }
            } else {
                // no biometry
                print("[*] No indentification enabled : \(String(describing: error))")
            }
        } else { // Time didn't exceeded
            self.dismissCurrentView()
        }
    }
    
    //
    // Data
    //
    private func getSetting(){
        var json = ""
        do {
            json = try String(contentsOf: URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]).appendingPathComponent(settingsPath.appSettings.path), encoding: .utf8)
        } catch {
            print("***ATTENTION***\n\n ***ERROR***\n\nImpossible to retrieve data.\n\n***************")
        }
        let dict = json.jsonToDictionary() ?? ["":""]
        if dict[SettingsName.isPasswordActivated.key] == "false" {
            self.password = false
        } else {
            self.password = true
        }
    }
    
    private func authenfiticationSucceed(){
        print("[*] Authentification succeed")
        let settingsData = SettingsData()
        var dateInfos = settingsData.getLastTimeAppIsClosed()
        if dateInfos != nil{
            if dateInfos!.keys.contains(DateInfosName.hasBeenUnlocked.key){ // if not, no update needed
                dateInfos!.updateValue("true", forKey: DateInfosName.hasBeenUnlocked.key) // Update unlocked status
                settingsData.saveLastTimeAppIsClosed(timesInfo: dateInfos!)
            }
        }
        self.perform(#selector(self.dismissCurrentView))
    }
    
    
    public func isTimeBeforeLockingExceeded()-> Bool{
        let settingsData = SettingsData()
        let (_, (_, timeBeforeLocking)) = settingsData.checkIfHideScreenAndPassword()
        let lastDate = SettingsData().getLastTimeAppIsClosed()
        if lastDate != nil { // else do nothing
            if lastDate!.keys.contains(DateInfosName.dateOfClose.key) && lastDate!.keys.contains(DateInfosName.hasBeenUnlocked.key) { // else, an error occured so we do noting. It will be corrected the next time user quit app
                if lastDate![DateInfosName.hasBeenUnlocked.key] == "false"{ // else, no need to ask authentification again
                    let date = Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
                    
                    let lastDateString = lastDate![DateInfosName.dateOfClose.key]
                    let dateString  = dateFormatter.string(from: date)
                    print("date = \(dateString), lastDate = \(String(describing: lastDateString))")
                    let newDate = (dateFormatter.date(from: dateString))
                    let lastDate = dateFormatter.date(from: lastDateString!)
                    if newDate != nil && lastDate != nil {
                        let diffInMins = Calendar.current.dateComponents([.minute], from: lastDate!, to: newDate!).minute
                        print("[*] Distance = \(String(describing: diffInMins))")
                        if diffInMins ?? 0 >= timeBeforeLocking { // time exceeded
                            return true
                        }
                    }
                }
            }
        }
        return false
    }
    
    
}
