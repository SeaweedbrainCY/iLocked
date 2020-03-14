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



class Settings: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var logSwitch = UISwitch()
     
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell") //on associe la tableView au custom de Style/customeCelleTableView.swift
        
    }

    ///**Give the model of saved dict**
    func saveSetting(){
        let dict = ["":""]
        let dictExtension = DictionnaryExtension()
        let jsonString = dictExtension.dictionaryToJson(dict: dict)
        _ = FileManager.default.createFile(atPath: URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]).appendingPathComponent(settingPath).path, contents: "\(jsonString!)".data(using: String.Encoding.utf8), attributes: nil)
    }
    
    /// Simple pop-up with one cancel button
    func alert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }

    ///number of section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    /// Cells for each section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0 : return 2
        case 1 : return 2
        default : return 0
            
        }
    }
    
    ///Cells' name
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        
        cell.textLabel?.font = UIFont(name: "Arial Rounded MT Bold", size: 17)
        cell.backgroundColor = .black
        cell.textLabel?.textColor = .white
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Report a bug"
                cell.iconCell.image = UIImage(named: "Alerter")
            case 1 :
                cell.textLabel?.text = "View developer website"
                cell.iconCell.image = UIImage(named: "Site")
            default : cell.textLabel?.text = "ERROR"
            }
        } else {
            switch indexPath.row {
            default : cell.textLabel?.text = "ERROR"
            }
            
        }
        return cell
    }
    
    /// Sections' name
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0 : return "Developement 🔨"
        default : return "ERROR"
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // cellule selctionnée
        if indexPath.section == 0  {
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
                UIApplication.shared.open(URL(string: "https://nathanstchepinsky--nathans1.repl.co")!, options: [:], completionHandler: nil)
            default : break
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




