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
                    clearedLog = "\(makeLog(message: "ERROR while reading the log file : \(error)"))"
                }
                guard let data: Data = clearedLog.data(using: .utf8) else {
                    throw Error.convertionFailed
                }
                
                do {
                    try data.write(to: url)
                } catch {
                    throw Error.writtingFailed
                }
            } else {
                print("Log file didn't exist")
                guard let data: Data = log.data(using: .utf8) else {
                    throw Error.convertionFailed
                }

                do {
                    try data.write(to:url)
                } catch {
                    throw Error.writtingFailed
                }
            }
    }
    
    private func makeURL() -> URL?{
        guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return url.appendingPathComponent(fileName)
    }
    
    func read() throws -> String  {
        guard let url = makeURL() else {
            throw Error.invalideDirectory
        }
        return try String.init(contentsOf: url)
    }
    
    func data() throws -> Data {
        guard let url = makeURL() else {
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
    
}




