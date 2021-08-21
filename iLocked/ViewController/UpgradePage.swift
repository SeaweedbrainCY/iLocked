//
//  UpgradePage.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 12/08/2021.
//  Copyright © 2021 Nathan. All rights reserved.
//

import Foundation
import UIKit
import InAppPurchaseLib
import SPConfetti

class UpgradePage: UIViewController {
    
    @IBOutlet weak var  upgradeButton : UIButton!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var closeButton : UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var upgradeTitle: UILabel!
    @IBOutlet weak var upgradeDescription: UILabel!
    
    var upgradeButtonTitle = "Product unavailable".localized()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDesign()
        loadProducts()
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //logoImage.animationRepeatCount = 1
        //var gif = logoImage.loadGif(name: "animated_logo_high_gray")
        if InAppPurchase.hasActivePurchase(for: "nonConsumableId") {
            self.showPurchased()
        }
        loadGif()
        self.logoImage.image = UIImage(named: "animated_logo_high_gray_last_frame-1")
        
    }
    
    
    //
    // Design func
    //
    
    func setUpDesign(){
        self.upgradeButton.layer.cornerRadius = 10
        self.logoImage.layer.cornerRadius = 20
    }
    
    func loadGif(){
        self.logoImage.animationDuration = 2 // time in sec
        self.logoImage.animationRepeatCount = 1
        self.logoImage.animationImages = getSequence(gifNamed: "animated_logo_high_gray")
        logoImage.startAnimating()
        
    }
    
    func loadProducts(){
        self.upgradeButton.setTitleColor(.lightGray, for: .highlighted)
        self.restoreButton.setTitleColor(.lightGray, for: .highlighted)
        guard let product = InAppPurchase.getProductBy(identifier: "nonConsumableId") else {
            self.upgradeButton.setTitle("Product unavailable".localized(), for: .normal)
            self.upgradeButton.isEnabled = false
            return
          }
        
        self.upgradeButtonTitle = "Upgrade for ".localized() + "\(product.localizedPrice)"
        self.upgradeButton.setTitle(self.upgradeButtonTitle, for: .normal)
       
    }
    
    func alert(_ title: String, message: String, quitMessage: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: quitMessage, style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showPurchased(){
        SPConfetti.startAnimating(.fullWidthToDown, particles: [.triangle, .arc,. heart, .circle, .polygon], duration: 8)
        self.view.backgroundColor = UIColor(red: 204/255, green: 172/255, blue: 0, alpha: 1)
        self.upgradeTitle.text = "Thank you ! ❤️".localized()
        self.upgradeDescription.text = "Thanks for supporting the app and the developer ! Enjoy your premium app ! 🔥".localized()
        self.upgradeButton.isHidden = true
    }
    
    //
    // IBAction views
    //
    
    @IBAction func upgradeButtonSelected(sender: UIButton){
        self.activityIndicator.center = self.upgradeButton.center
        self.upgradeButton.setTitle("", for: .normal)
        self.activityIndicator.startAnimating()
        InAppPurchase.purchase(
              productIdentifier: "nonConsumableId",
              callback: { result in
                self.activityIndicator.stopAnimating()
                self.upgradeButton.setTitle(self.upgradeButtonTitle, for: .normal)
                switch result.state {
                case .purchased:
                    print("Product purchased successful.")
                    self.showPurchased()
                    // Do not process the purchase here
                    print(" has active subscription = \(InAppPurchase.hasActivePurchase(for: "nonConsumableId"))")
                case .failed:
                    
                    print("Purchase failed: \(String(describing: result.localizedDescription)).")
                    
                    self.alert("Purchase failed", message: result.localizedDescription ?? "An error occured. PLease try again.", quitMessage: "Ok")
                  case .cancelled:
                      print("The user canceled the payment request.")

                  case .deferred:
                      print("The purchase was deferred.")
                  }
          })
    }
    
    @IBAction func closeButtonSelected(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func restorePurchasesSelected(sender: UIButton){
        self.activityIndicator.center = self.restoreButton.center
        self.restoreButton.isHidden = true
        self.activityIndicator.startAnimating()
        InAppPurchase.restorePurchases(callback: { result in
            self.activityIndicator.stopAnimating()
            self.restoreButton.isHidden = false
              switch result.state {
              case .succeeded:
                  if result.addedPurchases > 0 {
                      print("Restore purchases successful.")
                  } else {
                      print("No purchase to restore.")
                    self.alert("No purchase to restore".localized(), message : "Please make sure you already purchased a product with your current Apple ID.".localized(withKey: "noRestaurationMessage"), quitMessage: "Ok")
                  }
              case .failed:
                  print("Restore purchases failed.")
                self.alert("Restore purchases failed.".localized(), message : "Please make sure you already purchased a product with your current Apple ID.".localized(withKey: "noRestaurationMessage"), quitMessage: "Ok")
              default :
                self.alert("No purchase to restore".localized(), message : "Please make sure you already purchased a product with your current Apple ID.".localized(withKey: "noRestaurationMessage"), quitMessage: "Ok")
              print("No result to share")
              }
            
          })
    }
    
    //
    // Gif func
    //
    
    // Convert gif in a UIImage sequence
    func getSequence(gifNamed: String) -> [UIImage]? {

        guard let bundleURL = Bundle.main
            .url(forResource: gifNamed, withExtension: "gif") else {
                print("This image named \"\(gifNamed)\" does not exist!")
                return nil
        }

        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("Cannot turn image named \"\(gifNamed)\" into NSData")
            return nil
        }

        let gifOptions = [
            kCGImageSourceShouldAllowFloat as String : true as NSNumber,
            kCGImageSourceCreateThumbnailWithTransform as String : true as NSNumber,
            kCGImageSourceCreateThumbnailFromImageAlways as String : true as NSNumber
            ] as CFDictionary

        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, gifOptions) else {
            debugPrint("Cannot create image source with data!")
            return nil
        }

        let framesCount = CGImageSourceGetCount(imageSource)
        var frameList = [UIImage]()

        for index in 0 ..< framesCount {

            if let cgImageRef = CGImageSourceCreateImageAtIndex(imageSource, index, nil) {
                let uiImageRef = UIImage(cgImage: cgImageRef)
                frameList.append(uiImageRef)
            }

        }

        return frameList // Your gif frames is ready
    }
}
