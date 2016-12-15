//
//  AMTextField.swift
//  AudioMate
//
//  Created by Ruben Nine on 26/04/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa

class AMTextField: NSTextField {

    override var allowsVibrancy: Bool {
        // Quite important to set this to true.
        // See http://stackoverflow.com/questions/29647815/swift-allowvibrancy

        return true
    }

    override var isEnabled: Bool {

        didSet {
            setNeedsDisplay(bounds)
        }
    }

    // MARK: - Lifecycle

    override init(frame frameRect: NSRect) {

        super.init(frame: frameRect)

        isEditable = false
        isBordered = false
        drawsBackground = false
        alignment = .center
        maximumNumberOfLines = 1
        wantsLayer = true
    }
    
    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Overrides

    override func draw(_ dirtyRect: NSRect) {

        alphaValue = isEnabled ? 1 : 0.33

        super.draw(dirtyRect)
    }
}
