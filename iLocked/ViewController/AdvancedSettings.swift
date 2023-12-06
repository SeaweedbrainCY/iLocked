//
//  AdvancedSettings.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 17/02/2021.
//  Copyright © 2021 Nathan. All rights reserved.
//

import Foundation
import UIKit
import SwiftyRSA

class AdvancedSettings: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var successView : UIView!
    let inAppBrowserSwitch = UISwitch()
    let x509certificateSwitch = UISwitch()
    let x509CertificateForAllSwitch = UISwitch()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell") //on associe la tableView au custom de Style/customeCelleTableView.swift
        loadSettings()
        self.successView.layer.cornerRadius = 20
    }
    
    
    
    //
    // Pop up func
    //
    func alert(_ title: String, message: String, quitMessage: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: quitMessage, style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    //
    // Data related func
    //
    
    private func loadSettings() {
        inAppBrowserSwitch.addTarget(self, action: #selector(inAppBrowserSwitchChanged), for: .valueChanged)
        let settingsData = SettingsData()
        var settingDict = settingsData.getSetting()
        if let value = settingDict[SettingsName.inAppBrowser.key] {
            if value == "true" {
                inAppBrowserSwitch.setOn(true, animated: true)
            } else {
                inAppBrowserSwitch.setOn(false, animated: true)
            }
        } else { // By default
            settingDict.updateValue("true", forKey: SettingsName.inAppBrowser.key)
            settingsData.saveSetting(dict: settingDict)
            inAppBrowserSwitch.setOn(true, animated: true)
        }
        
        
        x509certificateSwitch.addTarget(self, action: #selector(x509SwitchChanged), for: .valueChanged)
        if let value = settingDict[SettingsName.X509Certificate.key] {
            if value == "true" {
                x509certificateSwitch.setOn(true, animated: true)
            } else {
                x509certificateSwitch.setOn(false, animated: true)
            }
        } else { // By default
            settingDict.updateValue("true", forKey: SettingsName.X509Certificate.key)
            settingsData.saveSetting(dict: settingDict)
            x509certificateSwitch.setOn(true, animated: true)
        }
    }

    //
    // Obj C functions
    //
    
    @objc private func inAppBrowserSwitchChanged(){
        alert("🔨 Feature coming soon !".localized(), message: "The iLocked application is still in development ! You will soon be able to open external links directly in app !\nYour choice is still saved and you will be notified when it becomes available.".localized(withKey: "featureComingSoonMessage"), quitMessage: "Ok")
        let settingsData = SettingsData()
        var settingDict = settingsData.getSetting()
        if self.inAppBrowserSwitch.isOn {
            settingDict.updateValue("true", forKey: SettingsName.inAppBrowser.key)
        } else {
            settingDict.updateValue("false", forKey: SettingsName.inAppBrowser.key)
        }
        settingsData.saveSetting(dict: settingDict)
        
    }
    
    @objc private func x509SwitchChanged(){
        let settingsData = SettingsData()
        var settingDict = settingsData.getSetting()
        if self.x509certificateSwitch.isOn{
            if let retrievedPublicKey: String = KeychainWrapper.standard.string(forKey: UserKeys.publicKey.tag){
                let publicKeyString : String?  = KeyId().extract_key(retrievedPublicKey)
                if publicKeyString == nil {
                    print("[*] Key retrieved but the value returned is nil")
                    keyRetrieveFailed(swicthIsOn: false)
                } else{
                    do {
                        let publicKey : Data = try PublicKey(base64Encoded: publicKeyString!).data()
                        let publicKeyPrepended = publicKey.prependx509Header()
                        let publicKeyPrepended64 = publicKeyPrepended.base64EncodedString()
                        let publicKeyPrependedString = KeyId().key_format(publicKeyPrepended64)
                        let isSaved = KeychainWrapper.standard.set(publicKeyPrependedString, forKey: UserKeys.publicKey.tag)
                        if isSaved{
                            settingDict.updateValue("true", forKey: SettingsName.X509Certificate.key)
                        } else {
                            print("[*] Key saving failed")
                            keyRetrieveFailed(swicthIsOn: false)
                        }
                    } catch {
                        print("[*] Prepend the key failed")
                        keyRetrieveFailed(swicthIsOn: false)
                    }
                }
            } else {
                print("[*] Impossible to retrieve the key")
                keyRetrieveFailed(swicthIsOn: false)
            }
        } else { // Swicth changed to off
            
            if let retrievedPublicKey: String = KeychainWrapper.standard.string(forKey: UserKeys.publicKey.tag){
                let publicKeyString : String?  = KeyId().extract_key(retrievedPublicKey)
                if publicKeyString == nil {
                    print("[*] Key retrieved but the value returned is nil")
                    keyRetrieveFailed(swicthIsOn: false)
                } else{
                    do {
                        let publicKey : PublicKey = try PublicKey(base64Encoded: publicKeyString!)
                        let public_data = try publicKey.data()
                        let publicKeyStripped = try public_data.stripPublicKeyHeader()
                        let publickeyStripped64 = publicKeyStripped.base64EncodedString()
                        let publicKeyStrippedString = KeyId().key_format(publickeyStripped64)
                        let isSaved = KeychainWrapper.standard.set(publicKeyStrippedString, forKey: UserKeys.publicKey.tag)
                        if isSaved{
                            settingDict.updateValue("false", forKey: SettingsName.X509Certificate.key)
                        } else{
                            print("[*] Key saving failed")
                            keyRetrieveFailed(swicthIsOn: true)
                        }
                    } catch {
                        print("[*] Strip the key failed")
                        keyRetrieveFailed(swicthIsOn: true)
                    }
                }
            } else {
                print("[*] Impossible to retrieve the key")
                keyRetrieveFailed(swicthIsOn: true)
            }
        }
        settingsData.saveSetting(dict: settingDict)
    }
    
    private func keyRetrieveFailed(swicthIsOn : Bool){
        alert("Fatal error".localized(), message: "Impossible to find this key. Please check you didn't make any mistake, install the last version of this application and be sure you have enough space on your iDevice.".localized(withKey: "keyRetrieveFailedMessage"), quitMessage: "Ok")
        self.x509certificateSwitch.isOn = swicthIsOn
    }
    
    func showSuccess(){
        let duration: TimeInterval = 0.8
        let waitTime: TimeInterval = 1.5
        let animation = UIViewPropertyAnimator(duration: duration, curve: .linear, animations: {
            self.successView.alpha = 1
        })
        animation.startAnimation()
        perform(#selector(hideSuccess), with: nil, afterDelay: duration + waitTime)
    }
    
    @objc func hideSuccess(){
        let animation = UIViewPropertyAnimator(duration: 0.5, curve: .linear, animations: {
            self.successView.alpha = 0
        })
        animation.startAnimation()
    }
    
    //
    // Table view func
    //
    
    ///number of section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    /// Cells for each section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0 : return 2
        case 1 : return 2
        case 2 : return 1
        default : return 0
            
        }
    }
    
    ///Cells' name
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        
        cell.textLabel?.font = UIFont(name: "Arial Rounded MT Bold", size: 17)
        cell.backgroundColor = Colors.darkGray5.color
        cell.textLabel?.textColor = .white
        let settingsData = SettingsData()
        let setting = settingsData.getSetting()
        var accessoryView = UIView()
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0 :
                self.inAppBrowserSwitch.onTintColor = .systemGray
                if setting[SettingsName.inAppBrowser.key ] == "false"{
                    self.inAppBrowserSwitch.isOn = false
                } else {
                    self.inAppBrowserSwitch.isOn = true
                }
                cell.textLabel?.text = "📲 Open external links in app".localized()
                accessoryView = self.inAppBrowserSwitch
            case 1 :
                cell.textLabel?.text = "🧹 " + "Delete the tuorial videos".localized()
            default :
                cell.textLabel?.text = "ERROR"
            }
        } else if indexPath.section == 1{
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "📚 Open Source Libraries".localized()
                accessoryView = UIImageView(image:Settings().externalLinkView)
                accessoryView.tintColor = .darkGray
            case 1 :
                cell.textLabel?.text = "🚧 " + "Open logs".localized()
                accessoryView = UIImageView(image: Settings().nextViewSettingImageView)
                accessoryView.tintColor = .darkGray
            default:
                cell.textLabel?.text = "ERROR"
            }
        } else if indexPath.section == 2{
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "🛂 Use X.509 certificate".localized()
                if setting[SettingsName.X509Certificate.key] == "false"{
                    self.inAppBrowserSwitch.isOn = false
                } else {
                    self.inAppBrowserSwitch.isOn = true
                }
                accessoryView = self.x509certificateSwitch
            default:
                cell.textLabel?.text = "Error"
            }
        } else {
            switch indexPath.row {
            default : cell.textLabel?.text = "ERROR"
            }
        }
        cell.accessoryView = accessoryView
        return cell
    }
    
    /// Sections' name
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0 : return "Application 📱"
        case 1 : return "Information 📌".localized()
        case 2 : return "Keys 🔑".localized()
        default : return "ERROR"
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // cellule selctionnée
        if indexPath.section == 0 {
            switch indexPath.row {
            case 1:
                let paths = [FirstTutoView().makeURLPath(isNameLocalized: false), SecondTutoView().makeURLPath(isNameLocalized: false), ThirdTutoView().makeURLPath(isNameLocalized: false), FirstTutoView().makeURLPath(), SecondTutoView().makeURLPath(), ThirdTutoView().makeURLPath()] // get all the possible path
                let fileManager = FileManager()
                for path in paths {
                    print("[*] path to delete = \(path)")
                    do {
                        try fileManager.removeItem(atPath: path)
                    } catch {
                        print("[*] Impossible to delete : error = \(error)")
                    }
                }
                showSuccess()
            default : break
            }
        } else if indexPath.section == 1{
            switch indexPath.row {
            case 0:
                UIApplication.shared.open(URL(string: "https://nathan.stchepinsky.net/source/iLocked/openSource.html")!, options: [:], completionHandler: nil)
            case 1 :
                performSegue(withIdentifier: "log", sender: self)
            default:
                break 
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 2{
            return "If you are having difficulty using your public key with other RSA encryptor try to turn off the X.509 certificate. You will be able to share your public key without certification header.\nNote : Turning off this option won't affect your public key as a RSA key. It will only change the encoding format of your key.\nBy default, the X509 certificate is used for your public key.".localized(withKey: "X509Description")
        }
        return nil
    }
    
    
}
