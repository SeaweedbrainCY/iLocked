//
//  ThirdTutoView.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 18/07/2021.
//  Copyright © 2021 Nathan. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

class ThirdTutoView : UIViewController {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var playButton : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        // set all views above the layer gradient
        for view in self.view.subviews {
            self.view.addSubview(view)
        }
        self.nextButton.layer.cornerRadius = 10
        self.backButton.layer.cornerRadius = 10
        self.playButton.layer.cornerRadius = 10
    }
    
    @IBAction func playSelected(sender: UIButton){
        guard let path = Bundle.main.path(forResource: "decryption", ofType:"MP4") else {
                    debugPrint("video.m4v not found")
                    return
                }
                let player = AVPlayer(url: URL(fileURLWithPath: path))
                let playerController = AVPlayerViewController()
                playerController.player = player
                present(playerController, animated: true) {
                    player.play()
                }
    }
    
    @IBAction func backButtonSelected(sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
}
