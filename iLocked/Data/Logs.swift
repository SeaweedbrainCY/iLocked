//
//  Logs.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 25/08/2021.
//  Copyright © 2021 Nathan. All rights reserved.
//

import Foundation


class LogFile {
    
    enum Error : Swift.Error {
        case fileAlreadyExists
        case invalideDirectory
        case writtingFailed
        case convertionFailed
        case readingFailed
        case fileDoesntExist
    }
    
    let fileManager: FileManager
    let fileName = "log.txt"
    
    
    init(fileManager: FileManager = .default){
        self.fileManager = fileManager
    }
    
    func write(message: String) throws {
        
            guard let url = makeURL() else {
                saveLogError(message: "badURL (write)")
                throw Error.invalideDirectory
            }
        print("url = \(url)")
            let log = makeLog(message: message)
            
            if fileManager.fileExists(atPath: url.path){
                print("log file existed")
                var clearedLog = ""
                do {
                    let oldLog = try String.init(contentsOf: url)
                    clearedLog = clearLog(log: oldLog)
                    clearedLog += makeLog(message: message)
                    print("oldLog = \(oldLog)")
                    print("clearedLog = \(clearedLog)")
                } catch {
                    saveLogError(message: "ERROR while reading the log file : \(error)")
                    clearedLog = "\(makeLog(message: "ERROR while reading the log file : \(error)"))"
                }
                guard let data: Data = clearedLog.data(using: .utf8) else {
                    saveLogError(message: "Impossible to convert the text in data. (write + exists)")
                    throw Error.convertionFailed
                }
                
                do {
                    try data.write(to: url)
                } catch {
                    saveLogError(message: "Error while writting (exists). Error = \(error)")
                    throw Error.writtingFailed
                }
            } else {
                print("Log file didn't exist")
                guard let data: Data = log.data(using: .utf8) else {
                    saveLogError(message: "Impossible to convert the text in data. (write + doesn't exist)")
                    throw Error.convertionFailed
                }

                do {
                    try data.write(to:url)
                } catch {
                    saveLogError(message: "Error while writting (didn't exist). Error = \(error)")
                    throw Error.writtingFailed
                }
            }
    }
    
    func makeURL() -> URL?{
        guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return url.appendingPathComponent(fileName)
    }
    
    func read() throws -> String  {
        guard let url = makeURL() else {
            saveLogError(message: "Error while reading")
            throw Error.invalideDirectory
        }
        return try String.init(contentsOf: url)
    }
    
    func data() throws -> Data {
        guard let url = makeURL() else {
            saveLogError(message: "Error while conerting the data. URL invalide.")
            throw Error.invalideDirectory
        }
        return try Data.init(contentsOf: url)
    }
    
    // Append the lof format to the given message
    func makeLog(message:String) -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        let currentDate = formatter.string(from: date)
        print("[*] New log written")
        return "[*] \(currentDate) : \(message)\n"
    }
    
    // Strip the oldest logs if there are more than 500
    func clearLog(log: String) -> String {
        let lines = log.split(separator: "\n")
        if lines.count > 500{
            var newLog = ""
            for i in lines.count - 500 ..< lines.count {
                newLog += "\(lines[i])\n"
            }
            return newLog
        } else {
            return log
        }
    }
    
    private func saveLogError(message: String){ // If saving a log failed, we save it
        _ = FileManager.default.createFile(atPath: URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]).appendingPathComponent(settingsPath.logError.path).path, contents: "[*] Last log error : \(makeLog(message: message))".data(using: String.Encoding.utf8), attributes: nil)
    }
    
    public func getLogError()-> String {
        var errors :String? = nil
        
        errors = try? String(contentsOf: URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]).appendingPathComponent(settingsPath.logError.path), encoding: .utf8)
        if errors == nil {
            return ""
        } else {
            return errors!
        }
       
    }
    
}




