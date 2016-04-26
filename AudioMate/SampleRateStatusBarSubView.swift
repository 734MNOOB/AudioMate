//
//  IconStatusBarView.swift
//  AudioMate
//
//  Created by Ruben Nine on 4/25/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa
import PureLayout_Mac
import AMCoreAudio

class SampleRateStatusBarSubView: NSTextField, StatusBarSubView {
    private var didSetupConstraints: Bool = false

    // Quite important to set this to true. 
    // See http://stackoverflow.com/questions/29647815/swift-allowvibrancy
    override var allowsVibrancy: Bool { return true }

    var representedObject: AnyObject? {
        didSet {
            updateUI()
        }
    }

    var shouldHighlight: Bool = false {
        didSet {
            updateUI()
        }
    }

    func updateUI() {
        if let device = representedObject as? AMAudioDevice {
            // Formatted sample rate
            let formattedSampleRate = FormattingUtils.formatSampleRate(device.nominalSampleRate() ?? 0)

            let textColor: NSColor = shouldHighlight ? .whiteColor() : .labelColor()
            let font = NSFont.boldSystemFontOfSize(13.0)
            let attrs = [NSFontAttributeName: font, NSForegroundColorAttributeName: textColor]
            let attrString = NSMutableAttributedString(string: formattedSampleRate, attributes: attrs)

            attrString.setAlignment(NSTextAlignment.Center, range: NSRange(location: 0, length: attrString.length))

            self.attributedStringValue = attrString
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        editable = false
        bordered = false
        drawsBackground = false
        alignment = .Center
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        if didSetupConstraints == false {
            autoPinEdgeToSuperviewEdge(.Left, withInset: 8)
            autoPinEdgeToSuperviewEdge(.Right, withInset: 8)
            autoCenterInSuperview()
            didSetupConstraints = true
        }

        super.updateConstraints()
    }
}
