//
//  FirstWelcomeView.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 13/07/2021.
//  Copyright © 2021 Nathan. All rights reserved.
//

import Foundation
import UIKit

class FirstWelcomeView: UIViewController{
    
    @IBOutlet weak var encryptedTextLabel : UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var mainDescriptionLabel: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var secondDescriptionLabel: UILabel!
    @IBOutlet weak var clearLabel: UILabel!
    @IBOutlet weak var unsafeImage: UIImageView!
    @IBOutlet weak var unsafeLabel: UILabel!
    @IBOutlet weak var safeImage: UIImageView!
    @IBOutlet weak var safeLabel: UILabel!
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startButton.layer.cornerRadius = 10
        // Create a gradient layer.
        let gradientLayer = CAGradientLayer()
        // Set the size of the layer to be equal to size of the display.
        gradientLayer.frame = view.bounds
        // Set an array of Core Graphics colors (.cgColor) to create the gradient.
        // This example uses a Color Literal and a UIColor from RGB values.
        gradientLayer.colors = [UIColor.black.cgColor, UIColor(red: 6/255, green: 15/255, blue: 71/255, alpha: 1).cgColor]
                // Rasterize this static layer to improve app performance.
        gradientLayer.shouldRasterize = true
                // Apply the gradient to the backgroundGradientView.
        self.view.layer.addSublayer(gradientLayer)
        self.encryptedTextLabel.superview?.addSubview(self.encryptedTextLabel)
        
        for view in self.view.subviews {
            self.view.addSubview(view)
        }
    }
    
    @IBAction func startButtonSelected(sender: UIButton){
        let viewToMoveArray = [self.encryptedTextLabel,self.startButton,self.welcomeLabel,self.mainDescriptionLabel,self.logoImage, self.secondDescriptionLabel, self.clearLabel, self.unsafeImage, self.unsafeImage, self.safeLabel, self.unsafeLabel, self.safeImage]
        let delay : Double = 2
        let animation = UIViewPropertyAnimator(duration: delay, dampingRatio: 0.7, animations: {
            for viewToMove in viewToMoveArray {
                //viewToMove!.translatesAutoresizingMaskIntoConstraints = true
                //viewToMove!.frame = CGRect(x: -400, y: viewToMove!.frame.origin.y, width: viewToMove!.frame.width, height: viewToMove!.frame.height)
                viewToMove!.alpha = 0
            }
            self.progressBar.progress = 0.5
        })
        animation.startAnimation()
        
        //let timer = Timer(timeInterval: delay, target: self, selector: #selector(performSegueWithDelay), userInfo: nil, repeats: false)
        //timer.fire()
        self.perform(#selector(performSegueWithDelay), with: nil, afterDelay: 1)
        print("timer fired")
        
    }
    
    // performed after a delay
    @objc private func performSegueWithDelay(){
        print("func call")
        performSegue(withIdentifier: "secondWelcomeView", sender: self)
    }
    
}
