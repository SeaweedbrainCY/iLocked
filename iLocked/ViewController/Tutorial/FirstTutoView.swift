//
//  FirstTutoView.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 17/07/2021.
//  Copyright © 2021 Nathan. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation


class FirstTutoView: UIViewController, URLSessionDelegate{
    
    @IBOutlet weak var nextButton : UIButton!
    @IBOutlet weak var playButton : UIButton!
    @IBOutlet weak var descriptionButtonLabel : UILabel!
    @IBOutlet weak var activityIndicator : UIActivityIndicatorView!
    
    var isDownloading = false // not download yet
    var isDownloaded = false
    
    static let notificationOfVideoRecieved = Notification.Name("notificationOfVideoRecieved")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create a gradient layer.
        let gradientLayer = CAGradientLayer()
        // Set the size of the layer to be equal to size of the display.
        gradientLayer.frame = view.bounds
        // Set an array of Core Graphics colors (.cgColor) to create the gradient.
        // This example uses a Color Literal and a UIColor from RGB values.
        gradientLayer.colors = [UIColor.black.cgColor,Colors.darkGray5.color.cgColor]
        // Rasterize this static layer to improve app performance.
        gradientLayer.shouldRasterize = true
        // Apply the gradient to the backgroundGradientView.
        self.view.layer.addSublayer(gradientLayer)
        // set all views above the layer gradient
        for view in self.view.subviews {
            self.view.addSubview(view)
        }
        self.nextButton.layer.cornerRadius = 10
        self.playButton.layer.cornerRadius = 10
        self.playButton.titleLabel?.textAlignment = .center
        
        //Wait for user authentication
        NotificationCenter.default.addObserver(self, selector: #selector(videoRecieved), name: FirstTutoView.notificationOfVideoRecieved, object: nil)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let filePath = makeURLPath()
        if FileManager().fileExists(atPath: filePath) {
            self.isDownloaded = true
            self.isDownloading = false
        } else {
            downloadVideo()
        }
    }
    
    @IBAction func playSelected(sender: UIButton){
        let filePath = makeURLPath()
            print("[*] Custom filePath = \(filePath)")
            if isDownloaded == false && isDownloading == false {
                downloadVideo()
            } else if isDownloaded == true && isDownloading == false {
                if FileManager().fileExists(atPath: filePath) {
                    print("file exists")
                    let avAssest = AVAsset(url: URL(fileURLWithPath: filePath))
                    let playerItem = AVPlayerItem(asset: avAssest)
                    
                    let player = AVPlayer(playerItem: playerItem)
                    
                    let playerController = AVPlayerViewController()
                    playerController.player = player
                    present(playerController, animated: true) {
                        player.play()
                    }
                } else {
                    print("[*] File doesn't exist")
                    downloadVideo()
                }
        } else {
            showErrorVideo()
        }
        
       
        
        
        
        /*guard let path = Bundle.main.path(forResource: "addKey", ofType:"MP4") else {
                    debugPrint("video.m4v not found")
                    return
                }
                let player = AVPlayer(url: URL(fileURLWithPath: path))
                let playerController = AVPlayerViewController()
                playerController.player = player
                present(playerController, animated: true) {
                    player.play()
                }
 */
    }
    
    ///
    /// - Parameters :
    ///         - videoURL : web url of the wanted video (String)
    ///         - name : name of the video (for storing reason) (String)
    /// -  Returns :
    ///         None. Notification posted
    ///
    
    func downloadVideo() {
        self.isDownloading = true
        let videoURL = TutoVideo.addKey.url
        print("Download started")
        self.playButton.setTitle("", for: .normal)
        self.playButton.isEnabled = false
        self.activityIndicator.startAnimating()
        self.descriptionButtonLabel.isHidden = false
        
        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: videoURL),
                let data = NSData(contentsOf: url) {
                
                
                let filePath = self.makeURLPath()
                do {
                    try data.write(to: URL(fileURLWithPath: filePath))
                    print("[*] Saved. Path = \(filePath)")
                    DispatchQueue.main.async {
                    NotificationCenter.default.post(name: FirstTutoView.notificationOfVideoRecieved , object: nil, userInfo: ["fileURLString" : filePath, "success": "true"])
                    }
                } catch {
                    debugPrint(error)
                    debugPrint("[*] Impossible to write")
                    DispatchQueue.main.async {
                    NotificationCenter.default.post(name: FirstTutoView.notificationOfVideoRecieved, object: nil, userInfo: ["fileURLString" : "", "success": "false"])
                    }
                }
                
            } else{
                print("No data to extract")
            }
        }
    }
    
    
    
    @objc func videoRecieved(notification: Notification){
        
        let notificationData = notification.userInfo
        print("[*] Notification recieved = \(String(describing: notificationData))")
        let fileURLStringRecieved = notificationData?["fileURLString"] as? String
        let success = notificationData?["success"] as? String
        self.isDownloading = false
        if success != nil && fileURLStringRecieved != nil {
            self.isDownloaded = (success! == "true")
            if success! == "true" {
                print("[*] Data recieved & valid. Success")
                //let isSaved = save(data: try Data(contentsOf: URL(string: fileURLStringRecieved!)!))
                self.isDownloading = false
                self.isDownloaded = true
                self.showSuccessVideo()
                
            } else {
                print("[*] Save doesn't succeed")
                self.isDownloaded = false
                self.isDownloading = false
                self.showErrorVideo()
            }
        } else {
            self.isDownloaded = false
            self.isDownloading = false
            self.showErrorVideo()
        }
    }

    func showErrorVideo(){
        self.isDownloaded = false
        self.isDownloading = false
        self.activityIndicator.stopAnimating()
        self.playButton.isEnabled = true
        self.playButton.setTitle("Try again", for: .normal)
        self.playButton.backgroundColor = .systemOrange
        self.descriptionButtonLabel.text = "Error while downloading the video."
        self.descriptionButtonLabel.textColor = .systemOrange
    }
    
    func showSuccessVideo(){
        self.isDownloaded = true
        self.isDownloading = false
        self.activityIndicator.stopAnimating()
        self.playButton.isEnabled = true
        self.playButton.setTitle("           How to add a new public key", for: .normal)
        self.playButton.backgroundColor = .systemGreen
        self.descriptionButtonLabel.isHidden = true
    }
    
    func makeURLPath() -> String{
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
        return "\(documentsPath)/\(TutoVideo.addKey.name).mp4"
    }
}

public enum TutoVideo {
    case addKey
    case decryption
    case encryption
    
    var name : String {
        switch self {
        case .addKey: return "addKey"
        case .decryption :return "decryption"
        case .encryption : return "encryption"
        }
    }
    
    var url: String {
        switch self {
        case .addKey: return "https://devnathan.github.io/source/iLockedTutoVideo/addKey.MP4"
        case .decryption : return "https://github.com/DevNathan/DevNathan.github.io/upload/master/source/iLockedTutoVideo/encryption.MP4"
        case .encryption : return "https://github.com/DevNathan/DevNathan.github.io/upload/master/source/iLockedTutoVideo/decryption.MP4"

        }
    }
}
