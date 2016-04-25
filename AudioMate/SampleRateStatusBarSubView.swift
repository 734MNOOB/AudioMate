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

    var representedObject: AnyObject? {
        didSet {
            updateUI()
        }
    }

    func updateUI() {
        if let device = representedObject as? AMAudioDevice {
            // Formatted sample rate
            let formattedSampleRate = FormattingUtils.formatSampleRate(device.nominalSampleRate() ?? 0)

            let font = NSFont.boldSystemFontOfSize(13.0)
            let attrs = [NSFontAttributeName: font]
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
