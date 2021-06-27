//
//  Settings.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 15/02/2020.
//  Copyright © 2020 Nathan. All rights reserved.
//

import Foundation
import UIKit
import MessageUI



class Settings: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate  {
    
    @IBOutlet weak var tableView: UITableView!
    let protectionSwitch = UISwitch()
    let externalLinkView = UIImage(systemName: "arrow.up.right.square")
    let nextViewSettingImageView = UIImage(systemName: "chevron.forward")
    
    
    var lockAppButtonIsHit = false // True if the user tap on lockApp button
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell") //on associe la tableView au custom de Style/customeCelleTableView.swift
        protectionSwitch.addTarget(self, action: #selector(protectionSwitchChanged), for: .valueChanged)
        protectionSwitch.tintColor = .systemRed
        
        // Set up the setting icon:
        //self.externalLinkView.tintColor = .darkGray
    }
    
    //
    // View construction
    //
    
    
    
    
    
    /// Simple pop-up with one cancel button
    func alert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }

    ///number of section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    /// Cells for each section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0 : return 1
        case 1 : return 3
        case 2 : return 4
        case 3 : return 1
        default : return 0
            
        }
    }
    
    ///Cells' name
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        
        cell.textLabel?.font = UIFont(name: "Arial Rounded MT Bold", size: 17)
        cell.backgroundColor = .systemGray5
        cell.textLabel?.textColor = .white
        
        var accessoryView = UIView()
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "👨‍💻 Support the developer"
                cell.backgroundColor = .systemBlue
                accessoryView = UIImageView(image: UIImage(systemName: "info.circle"))
                accessoryView.tintColor = .white
            default:
                cell.textLabel?.text = "ERROR"
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0 :
                let settingData = SettingsData()
                var setting = settingData.getSetting()
                if (setting.keys).contains("password"){ // Check if the setting is already init
                    if setting["password"] == "false"{
                        self.protectionSwitch.isOn = false
                    } else {
                        self.protectionSwitch.isOn = true
                    }
                }else { // Not init. Se we do it
                    // default value
                    self.protectionSwitch.isOn = false
                    setting.updateValue("false", forKey: "password")
                    settingData.saveSetting(dict: setting)
                }
                cell.textLabel?.text = "🔑 Protect with a password"
                accessoryView = self.protectionSwitch
            case 1 :
                cell.textLabel?.text = "🔒 Lock application "
            case 2 :
                cell.textLabel?.text = "❌ Revoke your keys"
                cell.backgroundColor = .systemRed
            default :
                cell.textLabel?.text = "ERROR"
            }
        } else if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "🔎 Report a bug"
            case 1 :
                cell.textLabel?.text = "📱 Visit developer website"
                accessoryView = UIImageView(image: self.externalLinkView)
                accessoryView.tintColor = .darkGray
            case 2:
                cell.textLabel?.text = "🔨 Browse source code"
                //cell.imageAtEnd.image =  self.externalLinkView
                //cell.accessoryView = self.externalLinkView
                accessoryView = UIImageView(image: self.externalLinkView)
                accessoryView.tintColor = .darkGray
            case 3:
                cell.textLabel?.text = "🔏 Source code licence"
                accessoryView = UIImageView(image: self.externalLinkView)
                accessoryView.tintColor = .darkGray
                
            default : cell.textLabel?.text = "ERROR"
            }
        } else if indexPath.section == 3{
            switch indexPath.row {
            case 0 :
                cell.textLabel?.text = "⚙️ Advanced settings"
                accessoryView = UIImageView(image: self.nextViewSettingImageView)
                accessoryView.tintColor = .darkGray
            default :
                break
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
        case 0 : return "Developer 👨‍💻"
        case 1 : return "Security 🔐"
        case 2 : return "Developement 🔨"
        case 3 : return ""
        default : return "ERROR"
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // cellule selctionnée
        if indexPath.section == 0{
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "showDeveloper", sender: self)
            default:
                break
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 1 : // lock app
                lockAppButtonIsHit = true
                performSegue(withIdentifier: "lockApp", sender: self)
            case 2 : // revoke keys
                self.performSegue(withIdentifier: "showRevocationView", sender: self)
            default : break
            }
        } else if indexPath.section == 2  {
            switch indexPath.row {
            case 0 : // report a bug
                let alert = UIAlertController(title: "Report a bug", message: "Report a bug help the developer to upgrade this application and improve your experience", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Report a bug", style: .default) { _ in
                    self.mailReport(subject: "I found a bug in iLocked app !!", body: "[!] Send by iLocked iOS app [!]. \nBody text : \n\n\n")
                })
                alert.addAction(UIAlertAction(title: "Contact the developer", style: .default) { _ in
                    self.mailReport(subject: "Can I tell you something ?", body: "[!] Send by iLocked iOS app [!]. \nBody text : \n\n\n")
                })
                alert.addAction(UIAlertAction(title: "Annuler", style: UIAlertAction.Style.cancel, handler: nil)) // Retour
                present(alert, animated: true)
            case 1: // developer website
                UIApplication.shared.open(URL(string: "https://devnathan.github.io")!, options: [:], completionHandler: nil)
            case 2:
                UIApplication.shared.open(URL(string: "https://github.com/DevNathan/iLocked")!, options: [:], completionHandler: nil)
            case 3:
                UIApplication.shared.open(URL(string: "https://github.com/DevNathan/iLocked/blob/master/LICENSE")!, options: [:], completionHandler: nil)
            default : break
            }
        } else if indexPath.section == 3{
            switch indexPath.row {
            case 0:
                self.performSegue(withIdentifier: "advancedSettings", sender: self)
            default:
                break
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    /// Send  mail method
    /// - Parameters:
    ///   - subject: subject of the email. Must be a short String
    ///   - body: body text of the email. Can be a HTML code.
    func mailReport(subject: String, body: String){
        let email = "nathanstchepinsky@gmail.com"
        let bodyText = body
        if MFMailComposeViewController.canSendMail() {
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            mailComposerVC.setToRecipients([email])
            mailComposerVC.setSubject(subject)
            mailComposerVC.setMessageBody(bodyText, isHTML: true)
            self.present(mailComposerVC, animated: true, completion: nil)
        } else {
            let coded = "mailto:\(email)?subject=\(subject)&body=\(bodyText)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            if let emailURL = URL(string: coded!){
                if UIApplication.shared.canOpenURL(emailURL){
                    UIApplication.shared.open(emailURL, options: [:], completionHandler: { (result) in
                        if !result {
                            self.alert("Error ! 🔨", message: "Impossible to use mail services")
                        }
                    })
                }
            }
        }
    }
    
    internal override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "lockApp" {
            let lockedView = segue.destination as! LockedView
            lockedView.activityInProgress = true
            if lockAppButtonIsHit{
                lockedView.voluntarilyLocked = true // Explanations in LockedView.swift code 
                lockAppButtonIsHit = false // disable the tap
            }
        }
    }
    
    
    //
    // Obj C functions
    //
    
    @objc private func protectionSwitchChanged(){
        let settingData = SettingsData()
        var settingDict = settingData.getSetting()
        if self.protectionSwitch.isOn {
            settingDict.updateValue("true", forKey: "password")
        } else {
            settingDict.updateValue("false", forKey: "password")
        }
        settingData.saveSetting(dict: settingDict)
    }
    
    
    /**
     Function called by **Delegate** when user ask for contact the developer
     - Parameter _ controller : Correpond to MFMail
     - Parameter result : Result of user's actions
     - Parameter error : **nil** if there is no error
     */
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Swift.Error?) {
        
        
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
        if error != nil { // S'il y a une erreur
            alert("An error occured", message: "\(String(describing: error)). Please try again")
        }
    }
}




