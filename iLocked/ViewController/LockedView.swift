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
    
    var activityInProgress = false // if it's true, this view is dismissed and don't use a segue
    var firstTime = false
    
    override func viewDidLoad(){
        print("viewDidLoad called")
        super.viewDidLoad()
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        checkForKeys()
        
        //Call when the user re-open the app
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    ///This function check if their is already a key created
    func checkForKeys(){
        let retrievedString: String? = KeychainWrapper.standard.string(forKey: userPublicKeyId)
        print("view loaded")
        if retrievedString == nil || retrievedString == ""{
            firstTime = true
            loadWelcomeView()
        } else{
            lockView()
        }
    }
    
    //
    // Construction func :
    //
    
    //
    //TO DO : make a tutorial
    //
    ///This function load the welcome view that ask to create a public key
    func loadWelcomeView(){
        //On place les boutons assez loins pour l'animation
        self.titleLabel.frame.size.width = self.view.frame.size.width
        self.titleLabel.frame.origin = CGPoint(x: -500, y: self.view.frame.origin.y + 100)
        
        self.descriptionLabel.frame.size.width = self.view.frame.size.width - 70
        self.descriptionLabel.numberOfLines = 20
        self.descriptionLabel.frame.size.height = 300
        self.descriptionLabel.center = CGPoint(x: -500, y: self.view.center.y)
        self.actionButton.frame.size.width = self.view.frame.size.width
        self.actionButton.center = CGPoint(x: -500, y: self.descriptionLabel.frame.origin.y + self.descriptionLabel.frame.size.height + 50)
        //Affichage des views
        self.titleLabel.isHidden = false
        self.actionButton.isHidden = false
        self.descriptionLabel.isHidden = false
        
        
        //Instanciation des differents textes
        self.titleLabel.text = "Welcome !"
        self.descriptionLabel.text = "iLocked is a high secure app wich enable everyone to use strong encryption on any text, to send it and be sure that only you and the reciver can read it. \nThis app is 100% free and open source ! \n\nIf you enjoy this project, please be free of make any donation to the young and independent developer. Enjoy ;)"
        
        self.actionButton.setTitle("Generate my keys and start !", for: .normal)
        
        //Animation pour le chagement de couleur
        let animation = UIViewPropertyAnimator(duration: 5, dampingRatio: 0.7, animations: {
            self.logoImageView.layer.cornerRadius = self.logoImageView.frame.size.width / 2;
            self.logoImageView.clipsToBounds = true
            self.logoImageView.alpha = 0
            self.betaLaunchText.alpha = 0
            self.view.backgroundColor = .systemTeal //UIColor.init(red: 0.017, green: 0.579, blue: 0.961, alpha: 1)
            self.backFingerprint.alpha = 0.5
            self.backFingerprint.isHidden = false
            })
        animation.startAnimation()
        //Changement de la couleur de fond
        
        //animation pour faire venir les View
        let animationLabel = UIViewPropertyAnimator(duration: 3, curve: .easeInOut, animations: {
            self.titleLabel.center = CGPoint(x: self.view.center.x, y: self.view.frame.origin.y + 100)
            self.descriptionLabel.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
            self.actionButton.center = CGPoint(x: self.view.center.x, y: self.descriptionLabel.frame.origin.y + self.descriptionLabel.frame.size.height + 50)
            
        })
        animationLabel.startAnimation()
        
    }
    
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
        self.actionButton.setImage(UIImage(named: "empreinte"), for: .normal)
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
        let animationLabel = UIViewPropertyAnimator(duration: 2, dampingRatio: 3, animations: {
            self.titleLabel.center = CGPoint(x: self.view.center.x, y: self.view.frame.origin.y + 100)
            self.descriptionLabel.center = CGPoint(x: self.view.center.x, y: self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 50)
            self.actionButton.center = CGPoint(x: self.view.center.x, y: self.view.frame.size.height - self.actionButton.frame.size.height - 20)
            
        })
        animationLabel.startAnimation()
        if !activityInProgress {
            askForAuthentification()
        }
    }
    
    
    
    //
    //IBAction func
    //
    
    @IBAction func actionButtonSelected(sender: UIButton){
        if !firstTime {
            askForAuthentification()
        } else { // This is the button "start and go" when the app is open for the first time
            let animation = UIViewPropertyAnimator(duration: 5, dampingRatio: 0.7, animations: {
                self.view.backgroundColor = .black
                self.titleLabel.text = "Generating of your keys ..."
                self.descriptionLabel.text = "iLocked is generating your private and public keys...\n\nThat a crucial moment 😵"
            })
            animation.startAnimation()
            let keys = PublicPrivateKeys()
            if keys.generateAndStockKeyUser() {
                descriptionLabel.text = "Welcome ... "
                self.performSegue(withIdentifier: "HomePage", sender: self)
            } else {
                descriptionLabel.text = "Error occured while creating keys. Please restart the application"
            }
        }
        
        
    }
    
    //
    //Objective C function
    //
    
    ///This func is called to send or dismiss the current view controller
    @objc private func dismissCurrentView(){
        if !activityInProgress {
            performSegue(withIdentifier: "HomePage", sender: self)
        } else {
            dismiss(animated: true, completion: nil)
        }
       
    }
    
    @objc private func appMovedToForeground(){
        askForAuthentification()
    }
    
    //
    // User interaction func :
    //
    
    //
    // TO DO : tester les différentes erreurs pour laisser uniquement si aucun code n'a JAMAIS été activé
    //
    
    ///Func who ask to the user is Touch ID / Face ID / password and manages the response by call an internal function if success
    private func askForAuthentification() {
        var policy: LAPolicy!
        let context: LAContext!
        if #available(iOS 9.0, *) {
            policy = .deviceOwnerAuthentication
            context = .init()
            let error: NSErrorPointer! = NSErrorPointer.none
            guard context?.canEvaluatePolicy(policy, error: error) ?? false else {
            self.titleLabel.textColor = .systemRed
            self.titleLabel.text = "Your touchId or FaceId is not activated !"
                self.actionButton.setTitle("Continue without locked the app ? (dangerous)", for: .normal)
                return
            }
            
            let message = "Touch ID is required to use iLocked"
            context?.evaluatePolicy(policy!, localizedReason: message, reply: { (success, error) in
                DispatchQueue.main.async {
                    if success {
                        self.perform(#selector(self.dismissCurrentView))
                    }
                    guard success else {
                    guard let error = error else {
                        self.descriptionLabel.textColor = .systemRed
                        self.descriptionLabel.text = "I'm very sorry but an unexpected error just occur 🔒"
                        return
                    }
                    switch(error) {
                    case LAError.authenticationFailed:
                        self.descriptionLabel.textColor = .systemRed
                            self.descriptionLabel.text = "There was a problem verifying your identity 🧬"
                        
                    case LAError.userCancel:
                        self.descriptionLabel.textColor = .systemRed
                        self.descriptionLabel.text = "authentication canceled 🔒"
                        
                    // Fallback button was pressed and an extra login step should be implemented for iOS 8 users.
                    // By the other hand, iOS 9+ users will use the pasccode verification implemented by the own system.
                    case LAError.userFallback:
                        self.descriptionLabel.textColor = .systemRed
                        self.descriptionLabel.text = "You tapped the fallback button 🔒"
                        
                    case LAError.systemCancel:
                        self.descriptionLabel.textColor = .systemRed
                        self.descriptionLabel.text = "Authentication was canceled by your device. 🔒"
                        
                    case LAError.passcodeNotSet:
                        self.descriptionLabel.textColor = .systemRed
                        self.descriptionLabel.text = "You didn't set any password on for device. 🔒"
                       
                    case LAError.biometryNotAvailable:
                        self.descriptionLabel.textColor = .systemRed
                        self.descriptionLabel.text = "Touch ID or Face ID is not available on your device. 🚧"
                        
                    case LAError.biometryNotEnrolled:
                        self.descriptionLabel.textColor = .systemRed
                        self.descriptionLabel.text = "Touch ID or Face ID has no saved data 🔒"
                        
                    // iOS 9+ functions
                    case LAError.biometryLockout:
                        self.descriptionLabel.textColor = .systemRed
                        self.descriptionLabel.text = "There were too many failed  attempts and biometric sensor is now locked. 🔐"
                        
                    case LAError.appCancel:
                        self.descriptionLabel.textColor = .systemRed
                        self.descriptionLabel.text = "Authentication was canceled by application. 🔒"
                        
                    case LAError.invalidContext:
                        self.descriptionLabel.textColor = .systemRed
                        self.descriptionLabel.text = "LAContext passed to this call has been previously invalidated."
                        
                    default:
                        self.descriptionLabel.textColor = .systemRed
                        self.descriptionLabel.text = "Touch ID or Face ID may not be configured. 🔒"
                        break
                    }
                        return
                }
                }
                
            })
            
        } else {
            policy = .deviceOwnerAuthenticationWithBiometrics
            
        }
     
        
    }
    
   
}
