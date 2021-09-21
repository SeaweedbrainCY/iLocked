//
//  QRCodeView.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 29/08/2021.
//  Copyright © 2021 Nathan. All rights reserved.
//

import Foundation
import UIKit
import QRCode

class QRCodeViewController: UIViewController {
    
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var qrCodeImage: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var waitView: UIActivityIndicatorView!
    @IBOutlet weak var waitLabel: UILabel!
    @IBOutlet weak var descriptionLabel:UILabel!
    
    var titleStr: String = "Error ! 🔨".localized()
    var text: String = ""
    var brightness: CGFloat = 0.5
    var background = DispatchQueue.global(qos: .background)
    var log = LogFile(fileManager: FileManager())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpConstraint()
        self.setUpDesign()
        print("title = \(titleStr)")
        //QRCodeView.layerClass.add(gl)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.loadQRCode()
        self.brightness = UIScreen.main.brightness
        UIScreen.main.brightness = 1
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        UIScreen.main.brightness = self.brightness
    }
    
    //
    // IBACtion func
    //
    
    @IBAction func closeButtonSelected(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    //
    // Design func
    //
    
    func setUpConstraint(){
        self.qrCodeImage.translatesAutoresizingMaskIntoConstraints = false
        self.qrCodeImage.widthAnchor.constraint(equalToConstant: self.view.frame.width - 80).isActive = true
        self.qrCodeImage.heightAnchor.constraint(equalToConstant:  self.view.frame.width - 80).isActive = true
        self.qrCodeImage.centerXAnchor.constraint(equalToSystemSpacingAfter: self.view.centerXAnchor, multiplier: 1).isActive = true
        self.qrCodeImage.centerYAnchor.constraint(equalToSystemSpacingBelow: self.view.centerYAnchor, multiplier: 1).isActive = true
    }
    
    func setUpDesign(){
        self.titleLabel.text = titleStr
        
        let colorTop = UIColor(red: 230/255 , green: 63/255, blue: 38/255, alpha: 1)
        let colorBottom = UIColor(red: 8/255, green: 57/255, blue: 243/255, alpha: 1)
        let gl = CAGradientLayer()
        gl.colors = [colorTop, colorBottom]
        gl.locations = [0.0, 1.0]
        //gl.startPoint = CGPoint(x: 0.0, y: 0.0)
        //gl.endPoint = CGPoint(x: 1.0, y: 1.0)
        self.view.layer.addSublayer(gl)
       
        //self.view.addSubview(qrCodeImage)
        //self.view.addSubview(titleLabel)
        //self.view.addSubview(closeButton)
    }
    
    func loadQRCode(){
        
        self.waitLabel.isHidden = false
        var qrCode = QRCode(string: text)
        qrCode?.size = CGSize(width: self.view.frame.width - 80, height: self.view.frame.width - 80)
        qrCode?.color =  .black //UIColor(red: 8/255, green: 57/255, blue: 243/255, alpha: 1)
        do {
            self.qrCodeImage.image = try qrCode?.image()
        } catch {
            self.qrCodeImage.image = UIImage(systemName: "exclamationmark.triangle.fill")
            self.qrCodeImage.tintColor = .systemOrange
            self.titleStr = "Error ! 🔨".localized()
            self.descriptionLabel.text = "Impossible to generate the QRCode. ".localized() + error.localizedDescription
            self.descriptionLabel.textColor = .systemRed
            background.async {
                try? self.log.write(message: "⚠️ ERROR. An error occured when generating a QRCode. Error thrown = \(error). Operation aborted and error message displayed.")
            }
        }
    }
}
