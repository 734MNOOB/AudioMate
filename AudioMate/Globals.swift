//
//  Globals.swift
//  AudioMate
//
//  Created by Ruben Nine on 12/14/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Foundation
import XCGLogger

let log: XCGLogger = {

    #if DEBUG
        $0.setup(level: .verbose,
                 showThreadName: true,
                 showLevel: true,
                 showFileNames: true,
                 showLineNumbers: true,
                 writeToFile: nil
        )
    #else
        $0.setup(level: .warning,
                 showThreadName: true,
                 showLevel: true,
                 showFileNames: true,
                 showLineNumbers: true,
                 writeToFile: nil
        )
    #endif
    
    return $0
}(XCGLogger())

let prefs = Preferences.sharedPreferences
