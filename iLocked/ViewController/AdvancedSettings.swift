//
//  AdvancedSettings.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 17/02/2021.
//  Copyright © 2021 Nathan. All rights reserved.
//

import Foundation
import UIKit

class AdvancedSettings: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView : UITableView!
    let inAppBrowserSwitch = UISwitch()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell") //on associe la tableView au custom de Style/customeCelleTableView.swift
        inAppBrowserSwitch.addTarget(self, action: #selector(inAppBrowserSwitchChanged), for: .valueChanged)
        //
        // Charge settings
        //
        let settingDict = getSetting()
        if let value = settingDict["inAppBrowser"] {
            if value == "true" {
                inAppBrowserSwitch.setOn(true, animated: true)
            } else {
                inAppBrowserSwitch.setOn(false, animated: true)
            }
        } else { // By default
            inAppBrowserSwitch.setOn(true, animated: true)
        }
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
    // Obj C functions
    //
    
    @objc private func inAppBrowserSwitchChanged(){
        var settingDict = getSetting()
        if self.inAppBrowserSwitch.isOn {
            settingDict.updateValue("true", forKey: "inAppBrowser")
        } else {
            settingDict.updateValue("false", forKey: "inAppBrowser")
        }
        saveSetting(dict: settingDict)
        alert("🔨 Feature coming soon !", message: "The iLocked application is still in development ! You will soon be able to open external links directly in app !\nYour choice is still saved and you will be notified when it becomes available.", quitMessage: "Ok")
    }
    
    //
    // Table view func
    //
    
    ///number of section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    /// Cells for each section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0 : return 1
        case 1 : return 1
        default : return 0
            
        }
    }
    
    ///Cells' name
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        
        cell.textLabel?.font = UIFont(name: "Arial Rounded MT Bold", size: 17)
        cell.backgroundColor = .systemGray5
        cell.textLabel?.textColor = .white
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0 :
                let setting = getSetting()
                if setting["inAppBrowser"] == "false"{
                    self.inAppBrowserSwitch.isOn = false
                } else {
                    self.inAppBrowserSwitch.isOn = true
                }
                cell.textLabel?.text = "📲 Open external links in app"
                cell.accessoryView = self.inAppBrowserSwitch
            default :
                cell.textLabel?.text = "ERROR"
            }
        } else if indexPath.section == 1{
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "📚 Open Source Libraries"
            default:
                cell.textLabel?.text = "ERROR"
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
        case 0 : return "Application 📱"
        case 1 : return "Informations 📌"
        default : return "ERROR"
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // cellule selctionnée
        if indexPath.section == 0 {
            switch indexPath.row {
            default : break
            }
        } else if indexPath.section == 1{
            switch indexPath.row {
            case 0:
                UIApplication.shared.open(URL(string: "https://github.com/DevNathan/iLocked/blob/master/OpenSourceLibrary.md#open-source-libraries")!, options: [:], completionHandler: nil)
            default:
                break 
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //
    // Settings data
    //
    
    func getSetting() -> [String: String]{
        var json = ""
        do {
            json = try String(contentsOf: URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]).appendingPathComponent(settingPath), encoding: .utf8)
            
        } catch {
           print("***ATTENTION***\n\n ***ERROR***\n\nImpossible to retrieve data.\n\n***************")
        }
        let dict = json.jsonToDictionary() ?? ["":""]
        return dict
    }
    
    
    ///**Give the model of saved dict**
    func saveSetting(dict: [String:String]){
        let dictExtension = DictionnaryExtension()
        let jsonString = dictExtension.dictionaryToJson(dict: dict)
        _ = FileManager.default.createFile(atPath: URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]).appendingPathComponent(settingPath).path, contents: "\(jsonString!)".data(using: String.Encoding.utf8), attributes: nil)
    }
    
    
}
