//
//  String.swift
//  iLocked
//
//  Created by Nathan on 30/07/2019.
//  Copyright © 2019 Nathan. All rights reserved.
//

import Foundation

extension String {
    func convertToDictionary(text: String!) -> [String: String]? {
        print("TEXT = \(text!)")
        if let data = text!.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
