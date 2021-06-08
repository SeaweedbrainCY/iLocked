//
//  donationView.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 07/06/2021.
//  Copyright © 2021 Nathan. All rights reserved.
//

import Foundation
import UIKit

class Donation: UIViewController{
    
    @IBOutlet weak var donationButton: UIButton!
    @IBOutlet weak var donationScale: UISegmentedControl!
    @IBOutlet weak var developerLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var developerStickerImage: UIImageView!
    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var infosLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Round button
        self.donationButton.layer.cornerRadius = 20
        hideViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        showViews()
    }
    
    func hideViews(){ // Hide view below the content view
        donationButton.translatesAutoresizingMaskIntoConstraints = true
        donationScale.translatesAutoresizingMaskIntoConstraints = true
        developerLabel.translatesAutoresizingMaskIntoConstraints = true
        closeButton.translatesAutoresizingMaskIntoConstraints = true
        developerStickerImage.translatesAutoresizingMaskIntoConstraints = true
        helloLabel.translatesAutoresizingMaskIntoConstraints = true
        infosLabel.translatesAutoresizingMaskIntoConstraints = true
        
        donationButton.frame.origin.x = self.donationButton.frame.origin.x + 200
        donationScale.frame.origin.x = self.donationScale.frame.origin.x + 200
        developerLabel.frame.origin.x = self.developerLabel.frame.origin.x + 200
        closeButton.frame.origin.x = self.closeButton.frame.origin.x + 200
        developerStickerImage.frame.origin.x = self.developerStickerImage.frame.origin.x + 200
        helloLabel.frame.origin.x = self.helloLabel.frame.origin.x + 200
        infosLabel.frame.origin.x = self.infosLabel.frame.origin.x + 200
    }
    
    func showViews(){
        let animation = UIViewPropertyAnimator(duration: 1, curve: .linear, animations: {
            self.donationButton.translatesAutoresizingMaskIntoConstraints = false
            self.donationScale.translatesAutoresizingMaskIntoConstraints = false
            self.developerLabel.translatesAutoresizingMaskIntoConstraints = false
            self.closeButton.translatesAutoresizingMaskIntoConstraints = false
            self.developerStickerImage.translatesAutoresizingMaskIntoConstraints = false
            self.helloLabel.translatesAutoresizingMaskIntoConstraints = false
            self.infosLabel.translatesAutoresizingMaskIntoConstraints = false
        })
        animation.startAnimation()
    }
}
