//
//  SecondTutoView.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 18/07/2021.
//  Copyright © 2021 Nathan. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

class SecondTutoView : UIViewController {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var playButton : UIButton!
    @IBOutlet weak var descriptionButtonLabel : UILabel!
    @IBOutlet weak var activityIndicator : UIActivityIndicatorView!
    @IBOutlet weak var progressBar : UIProgressView!
    @IBOutlet weak var errorButton: UIButton!
    
    var isDownloading = false // not download yet
    var isDownloaded = false
    var isViewPresented = true // false if the download is started by another bien
    var dataTask: URLSessionTask?
    private var observation: NSKeyValueObservation?

      deinit {
        observation?.invalidate()
      }
    
    static let notificationOfVideoRecieved = Notification.Name("notificationOfVideoRecieved2")
    
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
        
        self.playButton.titleLabel?.textAlignment = .center
        
        //Wait //Wait for the video
        NotificationCenter.default.addObserver(self, selector: #selector(videoRecieved), name: SecondTutoView.notificationOfVideoRecieved, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //downloadVideo()
        self.isViewPresented = true
        let filePath = makeURLPath()
        if FileManager().fileExists(atPath: filePath) {
            self.isDownloaded = true
            self.isDownloading = false
            print("[*] Encryption file video already exists")
        } else {
            downloadVideo()
        }
    }
    
    //
    // IBAction func
    //
    
    
    @IBAction func backButtonSelected(sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func playSelected(sender: UIButton){
        let filePath = makeURLPath()
            print("[*] Custom filePath = \(filePath)")
            if isDownloaded == false && isDownloading == false {
                downloadVideo()
            } else if isDownloaded == true && isDownloading == false {
                if FileManager().fileExists(atPath: filePath) {
                    print("[*] File exists. Reading the video")
                    let avAssest = AVAsset(url: URL(fileURLWithPath: filePath))
                    let playerItem = AVPlayerItem(asset: avAssest)
                    
                    let player = AVPlayer(playerItem: playerItem)
                    
                    let playerController = AVPlayerViewController()
                    playerController.player = player
                    present(playerController, animated: true) {
                        player.play()
                        // If play, we start the download of the next video
                        let thirdTuto = ThirdTutoView()
                        let thirdUrl = thirdTuto.makeURLPath()
                        if !FileManager().fileExists(atPath: thirdUrl) {
                            thirdTuto.downloadVideo(isViewPresented: false)
                        }
                    }
                } else {
                    print("[*] File doesn't exist")
                    downloadVideo()
                }
        } else {
            showErrorVideo()
        }
    }
    
    @IBAction func errorButtonSelected(sender: UIButton){
        if isDownloading {
            let alert = UIAlertController(title: "The video is downloading".localized(), message: "The download isn't finished yet. Do you want to re-start the download ?".localized(withKey: "downloadingVideoMessage"), preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Keep downloading".localized(), style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Re-start the download".localized(), style: .default, handler: {_ in
                self.dataTask?.cancel()
                self.downloadVideo()
            }))
            alert.addAction(UIAlertAction(title: "Stop the download".localized(), style: UIAlertAction.Style.destructive, handler: {_ in
                self.dataTask?.cancel()
            }))
            self.present(alert, animated: true)
        } else {
            downloadVideo()
        }
        
    }
    
    //
    // Download video func
    //
    
    ///
    /// - Parameters :
    ///         - viewIsPresented : Default value : true. False if it's loaded by an other view, in preshot of the download
    /// -  Returns :
    ///         None. Notification posted
    ///
    
    func downloadVideo(isViewPresented : Bool = true) {
        self.isViewPresented = isViewPresented
        if isViewPresented {
            self.progressBar.progress = 0
            self.progressBar.isHidden = false
            self.isDownloading = true
            self.descriptionButtonLabel.textColor = .systemOrange
            self.errorButton.setTitle("Impossible to download the video ?".localized(), for: .normal)
            self.descriptionButtonLabel.text = "Loading the video (6 MO) ...".localized()
            self.playButton.setTitle("", for: .normal)
            self.playButton.isEnabled = false
            self.activityIndicator.startAnimating()
            self.descriptionButtonLabel.isHidden = false
        }
       
        let videoURL = TutoVideo.encryption.url
        print("Download started")
        
        //DispatchQueue.global(qos: .background).async {
            if let url = URL(string: videoURL) {
                let request = NSMutableURLRequest(url: url)
                self.dataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
                        defer {
                            self.showErrorVideo()
                        }
                        print("[*] Request sended")
                        if let error = error {
                            self.showErrorVideo(withErrorDescription: error.localizedDescription)
                        } else if
                            let data = data,
                            let response = response as? HTTPURLResponse,
                            response.statusCode == 200 {
                            let filePath = self.makeURLPath()
                            print("[*] Data recieved")
                            do {
                                print("[*] writing")
                                try data.write(to: URL(fileURLWithPath: filePath))
                                print("[*] Saved. Path = \(filePath)")
                                DispatchQueue.main.async {
                                    NotificationCenter.default.post(name: SecondTutoView.notificationOfVideoRecieved , object: nil, userInfo: ["fileURLString" : filePath, "success": "true"])
                                }
                            } catch {
                                debugPrint(error)
                                debugPrint("[*] Impossible to write")
                                self.showErrorVideo(withErrorDescription: error.localizedDescription)
                            }
                        }
                })
                if self.isViewPresented {
                    observation = dataTask!.progress.observe(\.fractionCompleted) { progress, _ in
                        //print("progress: ", progress.fractionCompleted)
                        DispatchQueue.main.async {
                            self.progressBar.progress = Float(progress.fractionCompleted)
                        }
                    }
                }
            } else {
                print("No data to extract")
            }
        //}
        print("dataTask resumed")
        dataTask?.resume()
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
    
    /// - parameters :
    ///     - isNameLocalized : by default true. If not it returns the name without translation
    
    func makeURLPath(isNameLocalized : Bool = true) -> String{
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
        var name = TutoVideo.encryption.name.localized() // not yet localized
        if !isNameLocalized {
            name = TutoVideo.encryption.name
        }
        return "\(documentsPath)/\(name).mp4"
    }
    
    //
    // Error func
    //
    
    func showErrorVideo(){
        if self.isViewPresented {
            DispatchQueue.main.async {
                self.isDownloaded = false
                self.isDownloading = false
                self.progressBar.isHidden = true
                self.activityIndicator.stopAnimating()
                self.playButton.isEnabled = true
                self.playButton.setTitle("Try again".localized(), for: .normal)
                self.playButton.backgroundColor = .systemOrange
                self.descriptionButtonLabel.text = "Error occured while downloading the video.".localized()
                self.descriptionButtonLabel.textColor = .systemOrange
                self.descriptionButtonLabel.textColor = .systemOrange
                self.errorButton.setTitle("Impossible to download the video ?".localized(), for: .normal)
            }
        }
    }
    
    func showErrorVideo(withErrorDescription error: String){
        if self.isViewPresented {
            DispatchQueue.main.async {
                self.isDownloaded = false
                self.isDownloading = false
                self.progressBar.isHidden = true
                self.activityIndicator.stopAnimating()
                self.playButton.isEnabled = true
                self.playButton.setTitle("Try again".localized(), for: .normal)
                self.playButton.backgroundColor = .systemOrange
                self.descriptionButtonLabel.text = error
                self.descriptionButtonLabel.textColor = .systemOrange
                self.errorButton.setTitle("Impossible to download the video ?".localized(), for: .normal)
                self.errorButton.setTitleColor(.systemOrange, for: .normal)
            }
        }
    }
    
    func showSuccessVideo(){
        if self.isViewPresented {
            DispatchQueue.main.async {
                self.isDownloaded = true
                self.isDownloading = false
                self.progressBar.isHidden = true
                self.activityIndicator.stopAnimating()
                self.playButton.isEnabled = true
                self.errorButton.setTitle("Impossible to watch the video ?".localized(), for: .normal)
                self.playButton.setTitle("           How to encrypt".localized(), for: .normal)
                self.errorButton.setTitleColor(.lightGray, for: .normal)
                self.playButton.backgroundColor = .systemGreen
                self.descriptionButtonLabel.isHidden = true
            }
        }
    }
    
    
    
}
