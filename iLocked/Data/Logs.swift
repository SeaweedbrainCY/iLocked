//
//  Logs.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 25/08/2021.
//  Copyright © 2021 Nathan. All rights reserved.
//

import Foundation


class Logs {
    
    func storeLog(message: String) -> String{
        let file = Log.path.name
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            //writing
            do {
                let date = Date()
                let calendar = Calendar.current
                let hour = calendar.component(.hour, from: date)
                let minutes = calendar.component(.minute, from: date)
                let day = calendar.component(.day, from: date)
                let month = calendar.component(.month, from: date)
                let year = calendar.component(.year, from: date)
                let seconds = calendar.component(.second, from: date)
                print("[*] New log written")
                let log = "[*] \(day)/\(month)/\(year) \(hour):\(minutes):\(seconds) --" + message + "\n"
                let oldLogs = try String.init(contentsOf: fileURL)
                let splited = oldLogs.split(separator: "\n")
                var oldLog = ""
                if splited.count >= 500 {
                    for i in splited.count - 500 ..< splited.count {
                        oldLog += "\(splited[i])\n"
                    }
                    
                } else {
                    oldLog = oldLogs
                }
                let newLog = oldLog + log
                try newLog.write(to: fileURL, atomically: true, encoding: .utf8)
                
                let logs = try  String.init(contentsOf: fileURL)
                print(logs)
            }
            catch {
                print("[*] Error : \(error)")
                return "An error occured while adding your logs to a text file. Please verify you have enough space in your iDevice.\nIf it still doesn't work, try another format and contact the developer.".localized(withKey: "convertionErrorMessageLog")
            }
        } else {
            return "An error occured while adding your logs to a text file. Please verify you have enough space in your iDevice. If it still doesn't work, try another format and contact the developer.".localized(withKey: "convertionErrorMessageLog")
        }
        print("[*] Success logging")
        return "success"
    }
    
}

enum Log {
    case path
    
    var name : String {
        switch self {
        case .path :
            return "log.txt"
        }
    }
}


