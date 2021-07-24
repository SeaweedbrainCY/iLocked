//
//  SecondWelcomeView.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 15/07/2021.
//  Copyright © 2021 Nathan. All rights reserved.
//

import Foundation
import UIKit

class SecondWelcomeView: UIViewController{
    
    @IBOutlet weak var tutoButton : UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var progressView: UIProgressView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tutoButton.layer.cornerRadius = 10
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
        
        let viewToMoveArray = [self.titleLabel, self.tutoButton, self.startButton, self.orLabel, self.backButton]
        for viewToMove in viewToMoveArray {
            //viewToMove!.translatesAutoresizingMaskIntoConstraints = false
            //viewToMove!.frame = CGRect(x: -500, y: viewToMove!.frame.origin.y, width: viewToMove!.frame.width, height: viewToMove!.frame.height)
            viewToMove!.alpha = 1
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let viewToMoveArray = [self.titleLabel, self.tutoButton, self.startButton, self.orLabel, self.backButton]
        let delay : Double = 1
        let animation = UIViewPropertyAnimator(duration: delay, dampingRatio: 0.7, animations: {
            for viewToMove in viewToMoveArray {
                viewToMove!.alpha = 1
            }
        })
        //animation.startAnimation()
        let progressViewAnimation = UIViewPropertyAnimator(duration: 2, dampingRatio: 0.7, animations: {
            self.progressView.progress = 0.5
        })
        //progressViewAnimation.startAnimation()
    }
    
    
}
