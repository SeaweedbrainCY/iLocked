//
//  ExportKeys.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 27/07/2021.
//  Copyright © 2021 Nathan. All rights reserved.
//

import Foundation
import UIKit
import SwiftyRSA

class ExportKeys: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    //Help views
    @IBOutlet weak var helpTextLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var quitButton : UIButton!
    @IBOutlet weak var titleIcon : UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var blurBackground: UIVisualEffectView!
    @IBOutlet weak var activityIndicator : UIActivityIndicatorView!
    
    var tryingToDelete = 0 // number of times we tried to delete a file if this doesn't work. After 10 tries we give up
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell") //on associe la tableView au custom de Style/customeCelleTableView.swift
        //constructHelpView()
        self.activityIndicator.layer.cornerRadius = 10
        
    }
    
    
    

    @IBAction func closeHelpSelected(sender: UIButton){
        self.backgroundView.isHidden = true
        self.quitButton.isHidden = true
        self.titleLabel.isHidden = true
        self.titleIcon.isHidden = true
        self.blurBackground.isHidden = true
        self.helpTextLabel.isHidden = true
        
    }
    
    ///number of section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    /// Cells for each section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0 : return 3
        case 1 : return 3
        case 2 : return 2
        case 3 : return 2
        default : return 0
            
        }
    }
    
    ///Cells' name
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        
        cell.textLabel?.font = UIFont(name: "Arial Rounded MT Bold", size: 17)
        cell.backgroundColor = Colors.darkGray5.color
        cell.textLabel?.textColor = .white
        
        var accessoryView = UIView()
        if indexPath.section == 1 || indexPath.section == 0 {
            switch indexPath.row {
                case 0:
                cell.textLabel?.text = ".txt"
                accessoryView = UIImageView(image: UIImage(systemName: "square.and.arrow.up"))
                accessoryView.tintColor = .white
                case 1:
                    cell.textLabel?.text = "JSON"
                    accessoryView = UIImageView(image: UIImage(systemName: "square.and.arrow.up"))
                    accessoryView.tintColor = .white
                case 2 :
                    cell.textLabel?.text = "Human readable".localized()
                    accessoryView = UIImageView(image: UIImage(systemName: "square.and.arrow.up"))
                    accessoryView.tintColor = .white
                default:
                    cell.textLabel?.text = "ERROR"
                }
        } else if indexPath.section == 2 || indexPath.section == 3 {
            switch indexPath.row {
                case 0:
                    cell.textLabel?.text = "JSON"
                    accessoryView = UIImageView(image: UIImage(systemName: "square.and.arrow.up"))
                    accessoryView.tintColor = .white
                case 1 :
                    cell.textLabel?.text = "Human readable".localized()
                    accessoryView = UIImageView(image: UIImage(systemName: "square.and.arrow.up"))
                    accessoryView.tintColor = .white
                default:
                    cell.textLabel?.text = "ERROR"
                }
        }
        
        cell.accessoryView = accessoryView
        return cell
    }
    
    /// Sections' name
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerSectionLabel = UILabel()
        headerSectionLabel.textColor = .lightGray
        headerSectionLabel.font = UIFont(name: "Aveni Next Bold", size: 15)
        headerSectionLabel.numberOfLines = 0
        headerSectionLabel.textAlignment = .center
       
        switch section {
        case 0 : headerSectionLabel.text =  "PEM format and X.509 certificate for the public key".localized()
        case 1 : headerSectionLabel.text = "PEM format (wihtout X.509 certificate)".localized()
        case 2 : headerSectionLabel.text = "Base64 format and X.509 certificate for the public key".localized()
        case 3 : headerSectionLabel.text = "Base64 format (wihtout X.509 certificate)".localized()
        default : headerSectionLabel.text =  "ERROR"
        }
        headerSectionLabel.text = "        " + headerSectionLabel.text!
        return headerSectionLabel
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    

    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // cellule selctionnée
        self.activityIndicator.startAnimating()
        let publicKey = KeychainWrapper.standard.string(forKey: UserKeys.publicKey.tag)
        let privateKey = KeychainWrapper.standard.string(forKey: UserKeys.privateKey.tag)
        let keys = KeyId()
        if publicKey == nil || privateKey == nil {
            alert("Unable to retrieve your keys".localized(), message: "Please try again. If you see this message several time, please contact the developer".localized(withKey: "impossibleRetrieveErrorMessage"), quitMessage: "Ok")
        } else {
            if indexPath.section == 0{ // pem / X.509
                let public_formated = keys.export_pem_format(publicKey!, isPrivate: false)
                let private_formated = keys.export_pem_format(privateKey!, isPrivate: true)
                switch indexPath.row {
                case 0 : // .txt
                    if let fileURL = createFileWithKey(publicKey: public_formated, privateKey : private_formated){
                        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                        activityViewController.completionWithItemsHandler = {
                            (activity, success, items, error) in
                            self.destroyFile(fileURL)
                        }
                        present(activityViewController, animated: true, completion: {
                            self.activityIndicator.stopAnimating()
                        })
                    } // else a pop up is showed
                    
                case 1:// JSON
                    let json = shareWithJSON(privateKey: private_formated, publicKey: public_formated, format: ExportKeysJSON.format.pemX509)
                    let activityViewController = UIActivityViewController(activityItems: [json], applicationActivities: nil)
                    present(activityViewController, animated: true, completion: {
                        self.activityIndicator.stopAnimating()
                    })
                case 2 : // Human readable
                    let text = shareInHumanReadable(privateKey: private_formated, publicKey: public_formated, format: ExportKeysJSON.format.pemX509)
                    let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                    present(activityViewController, animated: true, completion: {
                        self.activityIndicator.stopAnimating()
                    })
                default:
                    break
                }
            } else if indexPath.section == 1 { // PEM
                let private_formated = keys.export_pem_format(privateKey!, isPrivate: true)
                let public_base64 = KeyId().extract_key(publicKey!)
                do {
                    let public_data = try PublicKey(base64Encoded: public_base64).data()
                    let public_stripped_data = try public_data.stripPublicKeyHeader()
                    let public_stripped = public_stripped_data.base64EncodedString()
                    let public_formated = keys.export_pem_format(public_stripped, isPrivate: false)
                    
                    switch indexPath.row {
                    case 0 : // .txt
                        if let fileURL = createFileWithKey(publicKey: public_formated, privateKey : private_formated){
                            let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                            activityViewController.completionWithItemsHandler = {
                                (activity, success, items, error) in
                                self.destroyFile(fileURL)
                            }
                            present(activityViewController, animated: true, completion: {
                                self.activityIndicator.stopAnimating()
                            })
                        } // else a pop up is showed
                    case 1:// JSON
                        let json = shareWithJSON(privateKey: private_formated, publicKey: public_formated, format: ExportKeysJSON.format.pem)
                        let activityViewController = UIActivityViewController(activityItems: [json], applicationActivities: nil)
                        present(activityViewController, animated: true, completion: {
                            self.activityIndicator.stopAnimating()
                        })
                    case 2 : // Human readable
                        let text = shareInHumanReadable(privateKey: private_formated, publicKey: public_formated, format: ExportKeysJSON.format.pem)
                        let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                        present(activityViewController, animated: true, completion: {
                            self.activityIndicator.stopAnimating()
                        })
                    default:
                        break
                    }
                } catch{
                    alert("Unable to retrieve your keys".localized(), message: "Please try again. If you see this message several time, please contact the developer".localized(withKey: "impossibleRetrieveErrorMessage"), quitMessage: "Ok")
                }
            } else if indexPath.section == 2 { // base 64 + X.509
                let private_formated = privateKey!
                let public_formated = KeyId().extract_key(publicKey!)
                switch indexPath.row {
                case 0:// JSON
                    let json = shareWithJSON(privateKey: private_formated, publicKey: public_formated, format: ExportKeysJSON.format.base64X509)
                    let activityViewController = UIActivityViewController(activityItems: [json], applicationActivities: nil)
                    present(activityViewController, animated: true, completion: {
                        self.activityIndicator.stopAnimating()
                    })
                case 1 : // Human readable
                    let text = shareInHumanReadable(privateKey: private_formated, publicKey: public_formated, format: ExportKeysJSON.format.base64X509)
                    let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                    present(activityViewController, animated: true, completion: {
                        self.activityIndicator.stopAnimating()
                    })
                default:
                    break
                }
            } else if indexPath.section == 3 {
                let private_formated = privateKey!
                let public_base64 = KeyId().extract_key(publicKey!)
                do {
                    let public_data = try PublicKey(base64Encoded: public_base64).data()
                    let public_stripped_data = try public_data.stripPublicKeyHeader()
                    let public_formated = public_stripped_data.base64EncodedString()
                    
                    switch indexPath.row {
                    case 0:// JSON
                        let json = shareWithJSON(privateKey: private_formated, publicKey: public_formated, format: ExportKeysJSON.format.base64)
                        let activityViewController = UIActivityViewController(activityItems: [json], applicationActivities: nil)
                        present(activityViewController, animated: true, completion: {
                            self.activityIndicator.stopAnimating()
                        })
                    case 1 : // Human readable
                        let text = shareInHumanReadable(privateKey: private_formated, publicKey: public_formated, format: ExportKeysJSON.format.base64)
                        let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                        present(activityViewController, animated: true, completion: {
                            self.activityIndicator.stopAnimating()
                        })
                    default:
                        break
                    }
                } catch{
                    alert("Unable to retrieve your keys".localized(), message: "Please try again. If you see this message several time, please contact the developer".localized(withKey: "impossibleRetrieveErrorMessage"), quitMessage: "Ok")
                }
                
            }
            
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0{
            return "X.509 PEM format : Format used by some of RSA encryptor (as openSSL). \niLocked supports this format for importation.".localized(withKey: "footerExportKeys0")
        } else if section == 1 {
            return "PEM format : Format used by some of RSA encryptor (as online encryptor). More flexible but doens't support the X.509 certificate which can cause error with other RSA encryptor".localized(withKey: "footerExportKeys1")
        } else if section == 2 {
            return "X.509 Base64 format : Format used by some of RSA encryptor (as online encryptor). T.\niLocked supports this format for importation.".localized(withKey: "footerExportKeys2")
        } else if section == 3 {
            return "Base64 format : Most usable and flexible format. It can be used with the most of RSA encryptor and can easly be converted into a PEM file. But, it doens't support the X.509 certificate which can cause error with other RSA encryptor.\niLocked supports this format for importation.".localized(withKey: "footerExportKeys3")
        }
        return nil
    }
    
    func alert(_ title: String, message: String, quitMessage: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: quitMessage, style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    /// Create a file with the two keys and returns the URL to it.
    func createFileWithKey(publicKey:String, privateKey:String) -> URL?{
        let file = "keys.txt" //this is the file. we will write to it
        let text = publicKey + "\n\n" + privateKey
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            //writing
            do {
                try text.write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {
                alert("Unable to convert your keys".localized(), message: "An error occured while adding your keys to a text file. Please verify you have enough space in your iDevice.\nIf it still doesn't work, try another format and contact the developer.".localized(withKey: "convertionErrorMessage"), quitMessage: "Ok")
            }
            return fileURL
        }
        alert("Unable to convert your keys".localized(), message: "An error occured while adding your keys to a text file. Please verify you have enough space in your iDevice. If it still doesn't work, try another format and contact the developer.".localized(withKey: "convertionErrorMessage"), quitMessage: "Ok")
        return nil
    }
    
    // This file contains the private key. For security reasons, we re-write the file and then delete it
    func destroyFile(_ url: URL){
        var text = ""
        let alphabet = "abcdefghijklmnopqrstuvwxyz0123456789"
        // random text
        for _ in 0 ..< Int.random(in: 100..<1000){
            text +=  String(alphabet[Int.random(in: 0..<alphabet.count)])
        }
            do {
                try text.write(to: url, atomically: false, encoding: .utf8)
                do {
                        let text2 = try String(contentsOf: url, encoding: .utf8)
                    print(text2)
                    }
                    catch {/* error handling here */}
                try FileManager.default.removeItem(at: url)
                self.tryingToDelete = 0
            }
            catch {
                print("FAIL N°\(self.tryingToDelete) TO DELETE PRIVATE KEY FROM FILE MANAGER")
                self.tryingToDelete += 1
                // try again
                if self.tryingToDelete <= 10{
                    destroyFile(url)
            }
        }
    }
    
    func shareWithJSON(privateKey:String, publicKey:String, format:String) -> String {
        let data = [ExportKeysJSON.type.key :"RSA-4096", ExportKeysJSON.format.key: format, ExportKeysJSON.publicKey.key: publicKey , ExportKeysJSON.privateKey.key: privateKey]
        return data.toJson()!
    }
    
    func shareInHumanReadable(privateKey:String, publicKey:String, format:String) -> String {
        return "\(ExportKeysJSON.humanTitle.str)\n[\(ExportKeysJSON.format.key)] : \(format)\n[\(ExportKeysJSON.publicKey.key)] : \(publicKey)\n[\(ExportKeysJSON.privateKey.key)] : \(privateKey)"
    }
}

enum ExportKeysJSON { // key of the dictionnary encoded in JSON
    case type
    case format
    case publicKey
    case privateKey
    case humanTitle
    
    var key:String {
        switch self {
        case .type:
            return "Type"
        case .format:
            return "Format"
        case .publicKey:
            return "Public key"
        case .privateKey:
            return "Private key"
        default:
            return ""
        }
    }
    
    var pemX509:String{
    switch self {
    case .format:
        return "PEM / X.509"
    default :
        return ""
    }
    }
    var pem : String {
        switch self {
        case .format:
            return "PEM"
        default :
            return ""
        }
    }
    
    var base64X509:String{
    switch self {
    case .format:
        return "Base64 / X.509"
    default :
        return ""
    }
    }
    var base64 : String {
        switch self {
        case .format:
            return "Base64"
        default :
            return ""
        }
    }
    
    var str : String {
        switch self {
        case .humanTitle:
            return "iLocked RSA-4096 keys:"
        default:
            return ""
        }
    }
    
}
