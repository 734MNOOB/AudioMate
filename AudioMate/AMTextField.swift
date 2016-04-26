//
//  AMTextField.swift
//  AudioMate
//
//  Created by Ruben Nine on 26/04/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa

class AMTextField: NSTextField {
    // Quite important to set this to true.
    // See http://stackoverflow.com/questions/29647815/swift-allowvibrancy
    override var allowsVibrancy: Bool { return true }
}
