//
//  SampleRateStatusBarView.swift
//  AudioMate
//
//  Created by Ruben Nine on 4/25/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa
import PureLayout_Mac
import AMCoreAudio

class SampleRateStatusBarView: AMTextField, StatusBarSubView {
    private var didSetupConstraints: Bool = false

    weak var representedObject: AnyObject? {
        didSet {
            updateUI()
        }
    }

    var shouldHighlight: Bool = false {
        didSet {
            updateUI()
        }
    }

    override var enabled: Bool {
        didSet {
            alphaValue = enabled ? 1.0 : 0.33
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
        maximumNumberOfLines = 1
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        if didSetupConstraints == false {
            autoPinEdgeToSuperviewEdge(.Left)
            autoPinEdgeToSuperviewEdge(.Right)
            autoCenterInSuperview()
            didSetupConstraints = true
        }

        super.updateConstraints()
    }
}
