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
import InAppPurchaseLib


class Settings: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate  {
    
    @IBOutlet weak var tableView: UITableView!
    let protectionSwitch = UISwitch()
    let externalLinkView = UIImage(systemName: "arrow.up.right.square")
    let nextViewSettingImageView = UIImage(systemName: "chevron.forward")
    let hideScreenSwitcher = UISwitch()
    let timeBeforeLockingLabel = UILabel()
    
    
    var lockAppButtonIsHit = false // True if the user tap on lockApp button
    var isPremium = false
    
    let log = LogFile(fileManager: FileManager())
    let queue = DispatchQueue.global(qos: .background)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("[*] Settings just load")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell") //on associe la tableView au custom de Style/customeCelleTableView.swift
        protectionSwitch.addTarget(self, action: #selector(protectionSwitchChanged), for: .valueChanged)
        protectionSwitch.tintColor = .systemRed
        hideScreenSwitcher.addTarget(self, action: #selector(hideScreenSwitchChanged), for: .valueChanged)
        self.isPremium =  InAppPurchase.hasActivePurchase(for: "nonConsumableId")
        // Set up the setting label:
        
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
        return 5
    }
    
    /// Cells for each section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        
        case 0 :
            if self.isPremium{
                return 1
            } else {
                return 2
            }
        case 1 : return 2
        case 2 :
            let settingsData = SettingsData()
            let settings = settingsData.getSetting()
            if (settings.keys).contains(SettingsName.isPasswordActivated.key) && settings[SettingsName.isPasswordActivated.key] == "false" {
                return 2
            } else {
                return 3
            }
        case 3 : return 3
        case 4 : return 1
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
        let settingData = SettingsData()
        var setting = settingData.getSetting()
        if indexPath.section == 0 {
            if self.isPremium{
                cell.textLabel?.text = "✨ iLocked upgraded version ✨".localized()
                cell.textLabel?.font  = UIFont(name: "Avenir Next Bold", size: 20)
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.textColor = UIColor(red: 204/255, green: 172/255, blue: 0, alpha: 1)
                cell.backgroundColor = Colors.darkGray6.color
                cell.textLabel?.numberOfLines = 0
            } else {
                switch indexPath.row {
                case 0:
                    cell.textLabel?.text = "👨‍💻 Support the developer".localized()
                    accessoryView = UIImageView(image: UIImage(systemName: "info.circle"))
                    accessoryView.tintColor = .white
                case 1 :
                    cell.textLabel?.text = "🔥 Premium version".localized()
                    cell.backgroundColor = .systemBlue
                    accessoryView = UIImageView(image: UIImage(systemName: "info.circle"))
                    accessoryView.tintColor = .white
                default:
                    cell.textLabel?.text = "ERROR"
                }
            }
        } else if indexPath.section == 1{
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "🔑 Export your keys".localized()
                accessoryView = UIImageView(image: self.nextViewSettingImageView)
                accessoryView.tintColor = .darkGray
            case 1:
                cell.textLabel?.text = "❌ Revoke your keys".localized()
                cell.backgroundColor = .systemRed
            default:
                cell.textLabel?.text = "ERROR"
            }

        } else if indexPath.section == 2 {
            switch indexPath.row {
            case 0 :
                if (setting.keys).contains(SettingsName.isPasswordActivated.key){ // Check if the setting is already init
                    if setting[SettingsName.isPasswordActivated.key] == "false"{
                        self.protectionSwitch.isOn = false
                    } else {
                        self.protectionSwitch.isOn = true
                    }
                }else { // Not init. Se we do it
                    // default value
                    self.protectionSwitch.isOn = true
                    setting.updateValue("true", forKey: SettingsName.isPasswordActivated.key)
                    settingData.saveSetting(dict: setting)
                }
                cell.textLabel?.text = "🔐 Protect with a password".localized()
                accessoryView = self.protectionSwitch
            case 1 :
                if (setting.keys).contains(SettingsName.hideScreen.key){ // Check if the setting is already init
                    if setting[SettingsName.hideScreen.key] == "false"{
                        self.hideScreenSwitcher.isOn = false
                    } else {
                        self.hideScreenSwitcher.isOn = true
                    }
                }else { // Not init. Se we do it
                    // default value
                    self.hideScreenSwitcher.isOn = false
                    setting.updateValue("false", forKey: SettingsName.hideScreen.key)
                    settingData.saveSetting(dict: setting)
                }
                cell.textLabel?.text = "📲 Hide screen in App Switcher".localized()
                cell.textLabel?.numberOfLines = 0
                accessoryView = self.hideScreenSwitcher
            case 2 :
                if (setting.keys).contains(SettingsName.timeBeforeLocking.key){ // Check if the setting is already init
                    if let time = Int(setting[SettingsName.timeBeforeLocking.key]!){
                        if time == 0{
                            self.timeBeforeLockingLabel.text = "Immediatly".localized()
                        } else {
                            self.timeBeforeLockingLabel.text = "\(time) min"
                        }
                    } else{
                        self.timeBeforeLockingLabel.text = "Immediatly"
                        setting.updateValue("0", forKey: SettingsName.timeBeforeLocking.key)
                        settingData.saveSetting(dict: setting)
                    }
                }else { // Not init. Se we do it
                    // default value
                    self.timeBeforeLockingLabel.text = "Immediatly"
                    setting.updateValue("0", forKey: SettingsName.timeBeforeLocking.key)
                    settingData.saveSetting(dict: setting)
                }
                cell.textLabel?.text = "🕐 Lock app".localized()
                self.timeBeforeLockingLabel.textColor = .lightGray
                self.timeBeforeLockingLabel.textAlignment = .right
                accessoryView = self.timeBeforeLockingLabel
                accessoryView.frame = CGRect(x: accessoryView.frame.origin.x, y: accessoryView.frame.origin.y, width: 140, height: 20)
                
            //case 3 :
                //cell.textLabel?.text = "🔒 Lock application now"
            default :
                cell.textLabel?.text = "ERROR"
            }
        } else if indexPath.section == 3 {
            switch indexPath.row {
            case 0 :
                cell.textLabel?.text = "🕹 Show tutorial again".localized()
            case 1:
                cell.textLabel?.text = "🔎 Report a bug".localized()
            case 2 :
                cell.textLabel?.text = "📱 Visit developer website".localized()
                accessoryView = UIImageView(image: self.externalLinkView)
                accessoryView.tintColor = .darkGray
                
            default : cell.textLabel?.text = "ERROR"
            }
        } else if indexPath.section == 4{
            switch indexPath.row {
            case 0 :
                cell.textLabel?.text = "⚙️ Advanced settings".localized()
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
        
        case 0 :
            if self.isPremium {
                return ""
            } else {
                return "Developer 👨‍💻".localized()
            }
        case 1 : return "Keys 🔑".localized()
        case 2 : return "Security 🔐".localized()
        case 3 : return "Application 📱"
        case 4 : return ""
        default : return "ERROR"
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // cellule selctionnée
        if indexPath.section == 0{
            if self.isPremium {
                performSegue(withIdentifier: "upgrade", sender: self)
            } else {
                switch indexPath.row {
                case 0:
                    performSegue(withIdentifier: "showDeveloper", sender: self)
                case 1:
                    performSegue(withIdentifier: "upgrade", sender: self)
                
                default:
                    break
                }
            }
            
        } else if indexPath.section == 1{
            switch indexPath.row {
            case 0 :
                self.performSegue(withIdentifier: "showExportKeys", sender: self)
            case 1 : // revoke keys
                self.performSegue(withIdentifier: "showRevocationView", sender: self)
            default : break
            }
        } else if indexPath.section == 2{
            switch indexPath.row {
            case 2 : // time before locking
                let alert = UIAlertController(title: "Time before locking the app with your password".localized(), message: "", preferredStyle: .actionSheet)
                let settingsData = SettingsData()
                var settings = settingsData.getSetting()
                alert.addAction(UIAlertAction(title: "1 minute", style: .default) { _ in
                    settings.updateValue("1", forKey: SettingsName.timeBeforeLocking.key)
                    settingsData.saveSetting(dict: settings)
                    self.tableView.reloadData()
                })
                alert.addAction(UIAlertAction(title: "5 minutes", style: .default) { _ in
                    settings.updateValue("5", forKey: SettingsName.timeBeforeLocking.key)
                    settingsData.saveSetting(dict: settings)
                    self.tableView.reloadData()
                })
                alert.addAction(UIAlertAction(title: "30 minutes", style: .default) { _ in
                    settings.updateValue("30", forKey: SettingsName.timeBeforeLocking.key)
                    settingsData.saveSetting(dict: settings)
                    self.tableView.reloadData()
                })
                alert.addAction(UIAlertAction(title: "Immediatly".localized(), style: .default) { _ in
                    settings.updateValue("0", forKey: SettingsName.timeBeforeLocking.key)
                    settingsData.saveSetting(dict: settings)
                    self.tableView.reloadData()
                })
                alert.addAction(UIAlertAction(title: "Cancel".localized(), style: UIAlertAction.Style.cancel, handler: nil)) // Retour
                present(alert, animated: true)
            case 3://lock app
                lockAppButtonIsHit = true
                performSegue(withIdentifier: "lockApp", sender: self)
            default:
                break
            }
        } else if indexPath.section == 3  {
            var textVersion = ""
            if let version = Bundle.main.releaseVersionNumber {
                print("version = \(version)")
                textVersion += "Version : \(version)"
            } else {
                textVersion += "Version unknown"
            }
            
            if let build = Bundle.main.buildVersionNumber {
                print("build = \(build)")
                textVersion += " (\(build))"
            } else {
                textVersion += " (Unknown)"
                
            }
            switch indexPath.row {
            case 0: // tuto
                performSegue(withIdentifier: "tuto", sender: self)
            case 1 : // report a bug
                let alert = UIAlertController(title: "Report a bug".localized(), message: "Report a bug help the developer to upgrade this application and improve your experience".localized(withKey: "ReportBugMessage"), preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Report a bug".localized(), style: .default) { _ in
                    self.mailReport(subject: "iOS iLocked : Bug report".localized(), body: "********* Send by iLocked iOS app *********\nBug reported from the settings page\nLangage : English".localized(withKey: "reportBugEmailSetting") + " \n\(textVersion)\n" + "\n*****************************************\n\n\n", attachLog: true)
                })
                alert.addAction(UIAlertAction(title: "Contact the developer".localized(), style: .default) { _ in
                    self.mailReport(subject: "iOS iLocked : Request contact".localized(), body: "********* Send by iLocked iOS app *********\nContact requested from the settings page\nLangage : English".localized(withKey: "contactEmail") + " \n\(textVersion)\n" + "\n*****************************************\n\n\n", attachLog: false)
                    
                })
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)) // Retour
                present(alert, animated: true)
            case 2: // developer website
                UIApplication.shared.open(URL(string: "https://nathan.stchepinsky.net")!, options: [:], completionHandler: nil)
            default : break
            }
        } else if indexPath.section == 4{
            switch indexPath.row {
            case 0:
                self.performSegue(withIdentifier: "advancedSettings", sender: self)
            default:
                break
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
   
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 5 {
            let footerLabelView = UILabel()
            footerLabelView.textColor = .lightGray
            footerLabelView.font = UIFont(name: "Avenir Next Bold", size: 15)
            footerLabelView.numberOfLines = 2
            footerLabelView.textAlignment = .center
            var text = ""
            if let version = Bundle.main.releaseVersionNumber {
                print("version = \(version)")
                text += "Version \(version)"
            } else {
                print("no version")
            }
            
            if let build = Bundle.main.buildVersionNumber {
                print("build = \(build)")
                text += "\nBuild \(build)"
            } else {
                print("no build")
                
            }
            print("footerText = '\(text)'")
            footerLabelView.text = text
            return footerLabelView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 5 {
            return 100
        }
        return 20
        
    }
    
    
    
    /// Send  mail method
    /// - Parameters:
    ///   - subject: subject of the email. Must be a short String
    ///   - body: body text of the email. Can be a HTML code.
    func mailReport(subject: String, body: String, attachLog: Bool){
        let email = "nathanstchepinsky@gmail.com"
        var bodyText = body
        if MFMailComposeViewController.canSendMail() {
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            mailComposerVC.setToRecipients([email])
            mailComposerVC.setSubject(subject)
            let url = log.makeURL()
            if url == nil {
                bodyText.append("Impossible to create the log url. Invalide directory.")
            }
            let fileManager = FileManager()
            if attachLog {
                if  fileManager.fileExists(atPath: url!.path){
                    do {
                        let data: Data = try self.log.data()
                        mailComposerVC.addAttachmentData(data, mimeType: "text/plain", fileName: "log")
                    } catch {
                        print("Impossible to attach log. Error = \(error)")
                        queue.async {
                            try? self.log.write(message: "⚠️ ERROR. Impossible to attach the log file. Error thrown : \(error)")
                        }
                        bodyText.append("The log file cannot be attached. Error : \(error)")
                    }
                } else {
                    bodyText.append("The log file cannot be attached. Last error : \(log.getLogError())")
                }
            }
            mailComposerVC.setMessageBody(bodyText, isHTML: true)
            
            self.present(mailComposerVC, animated: true, completion: nil)
        } else {
            let coded = "mailto:\(email)?subject=\(subject)&body=\(bodyText)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            if let emailURL = URL(string: coded!){
                if UIApplication.shared.canOpenURL(emailURL){
                    UIApplication.shared.open(emailURL, options: [:], completionHandler: { (result) in
                        if !result {
                            self.alert("Error ! 🔨".localized(), message: "Impossible to use mail services".localized(withKey: "errorMail"))
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
            settingDict.updateValue("true", forKey: SettingsName.isPasswordActivated.key)
        } else {
            settingDict.updateValue("false", forKey: SettingsName.isPasswordActivated.key)
        }
        settingData.saveSetting(dict: settingDict)
        self.tableView.reloadData()
    }
    
    @objc private func hideScreenSwitchChanged(){
        let settingData = SettingsData()
        var settingDict = settingData.getSetting()
        if self.hideScreenSwitcher.isOn {
            settingDict.updateValue("true", forKey: SettingsName.hideScreen.key)
        } else {
            settingDict.updateValue("false", forKey: SettingsName.hideScreen.key)
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
            alert("An error occured".localized(), message: String(describing: error) + ". " + "Please try again".localized())
        }
    }
}




