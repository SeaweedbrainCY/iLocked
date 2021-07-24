//
//  GenereKeysView.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 24/07/2021.
//  Copyright © 2021 Nathan. All rights reserved.
//

import Foundation
import UIKit

class GenerateKeysView: UIViewController {
    
    @IBOutlet weak var generateButton: UIButton!
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var waitingView: UIActivityIndicatorView!
    @IBOutlet weak var orLabel: UILabel!
    
    var retrievedString:String? = nil
    
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
        let ok = UIAlertAction(title: quitMessage, style: UIAlertAction.Style.destructive, handler: {_ in
            exit(-1)
        })
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func crashApp(){
        alert("Please re-start iLocked !", message: "Error occured while creating keys. Please restart the application", quitMessage: "Quit app")
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
        
    }
    
    @objc func generateKeys(){
        print("start generation")
        let keys = PublicPrivateKeys()
        let isSuccessful = keys.generateAndStockKeyUser()
        if isSuccessful {
            self.performSegue(withIdentifier: "HomePage", sender: self)
        } else {
            print("FATAL ERROR. APP IS GOING TO BE CRASHED BY USER.")
            crashApp()
        }
    }
}
