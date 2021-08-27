//
//  Bundle.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 27/08/2021.
//  Copyright © 2021 Nathan. All rights reserved.
//

import Foundation


extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
