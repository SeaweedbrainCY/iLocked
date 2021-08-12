//
//  BartyCrouch.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 26/07/2021.
//  Copyright © 2021 Nathan. All rights reserved.
//

//  This file is required in order for the `transform` task of the translation helper tool BartyCrouch to work.
//  See here for more details: https://github.com/Flinesoft/BartyCrouch

// Run the following command in the app dir 'bartycrouch update'

import Foundation

enum BartyCrouch {
    enum SupportedLanguage: String {
        // TODO: remove unsupported languages from the following cases list & add any missing languages
        case french = "fr"
    }

    static func translate(key: String, translations: [SupportedLanguage: String], comment: String? = nil) -> String {
        let typeName = String(describing: BartyCrouch.self)
        let methodName = #function

        print(
            "Warning: [BartyCrouch]",
            "Untransformed \(typeName).\(methodName) method call found with key '\(key)' and base translations '\(translations)'.",
            "Please ensure that BartyCrouch is installed and configured correctly."
        )

        // fall back in case something goes wrong with BartyCrouch transformation
        return "BC: TRANSFORMATION FAILED!"
    }
}
