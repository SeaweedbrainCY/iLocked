//
//  GenereKeysView.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 24/07/2021.
//  Copyright © 2021 Nathan. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class GenerateKeysView: UIViewController,MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var generateButton: UIButton!
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var waitingView: UIActivityIndicatorView!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var littleInfo : UILabel!
    @IBOutlet weak var reportBug: UIButton!
    
    var retrievedString:String? = nil
    let log = LogFile(fileManager: FileManager())
    let queue = DispatchQueue.global(qos: .background)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.generateButton.layer.cornerRadius = 10
        self.importButton.layer.cornerRadius = 10

        // Create a gradient layer.
        let gradientLayer = CAGradientLayer()
        // Set the size of the layer to be equal to size of the display.
        gradientLayer.frame = view.bounds
        // Set an array of Core Graphics colors (.cgColor) to create the gradient.
        // This example uses a Color Literal and a UIColor from RGB values.
        gradientLayer.colors = [UIColor.black.cgColor, Colors.darkGray5.color.cgColor]
                // Rasterize this static layer to improve app performance.
        gradientLayer.shouldRasterize = true
                // Apply the gradient to the backgroundGradientView.
        self.view.layer.addSublayer(gradientLayer)
        for view in self.view.subviews {
            self.view.addSubview(view)
        }
        self.retrievedString = KeychainWrapper.standard.string(forKey:  UserKeys.publicKey.tag)
        // if user already have a key, load homepageView
        if retrievedString != nil && retrievedString != ""{
            self.generateButton.isHidden = true
            self.importButton.isHidden = true
            self.orLabel.isHidden = true
            self.littleInfo.isHidden = true
            self.reportBug.isHidden = true
            self.waitingView.startAnimating()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if retrievedString != nil && retrievedString != ""{ // load Home Page view
            self.performSegue(withIdentifier: "HomePage", sender: self)
        }
    }
    
    @IBAction func generateButtonSelected(sender: UIButton){
        print("generate called")
        self.setUpWaitingViews()
        perform(#selector(generateKeys), with: nil, afterDelay: 0.5) // I want to be sure that views had enough time to be switched in transition mode. It's very import for user experience.
        
    }
    
    func alert(_ title: String, message: String, quitMessage: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: quitMessage, style: UIAlertAction.Style.destructive, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func crashApp(){
        alert("Please re-start iLocked !".localized(), message: "An error occured while creating keys. Please restart the application".localized(withKey: "crashAppMessageError"), quitMessage: "Quit app".localized())
    }
    
    func setUpWaitingViews(){
        self.waitingView.startAnimating()
        self.generateButton.backgroundColor = Colors.disabledBlueButton.color
        self.generateButton.setTitleColor(Colors.disabledWhiteButton.color, for: .normal)
        self.importButton.backgroundColor = Colors.disabledOrangeButton.color
        self.importButton.setTitleColor(Colors.disabledWhiteButton.color, for: .normal)
        self.generateButton.isEnabled = false
        self.orLabel.isHidden = true
        self.importButton.isEnabled = false
        self.littleInfo.isHidden = true
        
    }
    
    func stopWaitingView(){
        self.waitingView.stopAnimating()
        self.generateButton.backgroundColor = .systemBlue
        self.generateButton.setTitleColor(.white, for: .normal)
        self.importButton.backgroundColor = .systemOrange
        self.importButton.setTitleColor(.white, for: .normal)
        self.generateButton.isEnabled = true
        self.orLabel.isHidden = false
        self.importButton.isEnabled = true
        self.littleInfo.isHidden = false
    }
    
    @objc func generateKeys(){
        print("start generation")
        let keys = PublicPrivateKeys()
        let isSuccessful = keys.generateAndStockKeyUser()
        if isSuccessful {
            
            queue.async {
                do {
                    try self.log.write(message: "Key generated with success")
                } catch {
                    print("An error occured = \(error)")
                }
            }
            self.performSegue(withIdentifier: "HomePage", sender: self)
        } else {
            queue.async {
                //try? self.log.write(message: "⚠️ ERROR. Impossible to create the keys. See the above logs for more details.")
            }
            print("FATAL ERROR. APP IS GOING TO BE CRASHED BY USER.")
            alert("An error occured while creating keys. Please try again.".localized(withKey: "crashAppMessageError"), message: "", quitMessage: "Ok")
            
            //crashApp()
        }
    }
    
    
    @IBAction func reportBugButtonSelected(sender: UIButton){
        self.mailReport(subject: "iOS iLocked : Bug report".localized(), body: "********* Send by iLocked iOS app *********\nBug reported from the keys generation page\nLangage : English\n*****************************************\n\n\n".localized(withKey: "reportBugEmailGeneration"))
    }
    
    /// Send  mail method
    /// - Parameters:
    ///   - subject: subject of the email. Must be a short String
    ///   - body: body text of the email. Can be a HTML code.
    func mailReport(subject: String, body: String){
        let email = "nathanstchepinsky@gmail.com"
        var bodyText = body
        if MFMailComposeViewController.canSendMail() {
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            mailComposerVC.setToRecipients([email])
            mailComposerVC.setSubject(subject)
            let url = log.makeURL()
            if url == nil {
                bodyText.append("Impossible to create the log url. Invalide directory.")
            }
            let fileManager = FileManager()
            if fileManager.fileExists(atPath: url!.path){
                do {
                    let data: Data = try self.log.data()
                    mailComposerVC.addAttachmentData(data, mimeType: "text/plain", fileName: "log")
                } catch {
                    print("Impossible to attach log. Error = \(error)")
                    queue.async {
                        try? self.log.write(message: "⚠️ ERROR. Impossible to attach the log file. Error thrown : \(error)")
                    }
                    bodyText.append("The log file cannot be attached. Error : \(error)")
                }
            } else {
                bodyText.append("The log file cannot be attached. Last error : \(log.getLogError())")
            }
            mailComposerVC.setMessageBody(bodyText, isHTML: true)
            
            self.present(mailComposerVC, animated: true, completion: nil)
        } else {
            
            let coded = "mailto:\(email)?subject=\(subject)&body=\(bodyText)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            if let emailURL = URL(string: coded!){
                if UIApplication.shared.canOpenURL(emailURL){
                    UIApplication.shared.open(emailURL, options: [:], completionHandler: { (result) in
                        if !result {
                            self.alert("Error ! 🔨".localized(), message: "Impossible to use mail services".localized(withKey: "errorMail"), quitMessage: "Ok")
                        }
                    })
                }
            }
        }
    }
    
    /**
     Function called by **Delegate** when user ask for contact the developer
     - Parameter _ controller : Correpond to MFMail
     - Parameter result : Result of user's actions
     - Parameter error : **nil** if there is no error
     */
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Swift.Error?) {
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
        if error != nil { // S'il y a une erreur
            alert("An error occured".localized(), message: String(describing: error) + ". " + "Please try again".localized(), quitMessage: "Ok")
        }
    }
}
