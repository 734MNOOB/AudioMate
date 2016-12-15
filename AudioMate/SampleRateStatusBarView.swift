//
//  SampleRateStatusBarView.swift
//  AudioMate
//
//  Created by Ruben Nine on 4/25/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa
import PureLayout
import AMCoreAudio

class SampleRateStatusBarView: AMTextField, StatusBarSubView {

    private var didSetupConstraints = false

    weak var representedObject: AnyObject? {

        didSet {
            setNeedsDisplay(bounds)
        }
    }

    var shouldHighlight: Bool = false {

        didSet {
            setNeedsDisplay(bounds)
        }
    }

    override var isEnabled: Bool {

        didSet {
            setNeedsDisplay(bounds)
        }
    }

    override var intrinsicContentSize: NSSize {

        return NSSize(width: 64, height: 18)
    }


    // MARK: - Lifecycle

    override init(frame frameRect: NSRect) {

        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Overrides

    override func draw(_ dirtyRect: NSRect) {

        updateUI()

        super.draw(dirtyRect)
    }

    override func updateConstraints() {

        if didSetupConstraints == false {
            didSetupConstraints = true

            autoCenterInSuperview()

            autoPinEdge(toSuperviewEdge: .left)
            autoPinEdge(toSuperviewEdge: .right)
        }

        super.updateConstraints()
    }

    
    // MARK: - Private functions

    private func updateUI() {

        if let device = representedObject as? AudioDevice {
            // Formatted sample rate
            let formattedSampleRate = device.nominalSampleRate()?.string(as: .sampleRate) ?? "N/A"
            let textColor: NSColor = shouldHighlight ? .white : .labelColor
            let font = NSFont.boldSystemFont(ofSize: 13)
            let attrs = [NSFontAttributeName: font, NSForegroundColorAttributeName: textColor]
            let attrString = NSMutableAttributedString(string: formattedSampleRate, attributes: attrs)

            attrString.setAlignment(NSTextAlignment.center, range: NSRange(location: 0, length: attrString.length))

            attributedStringValue = attrString
        }

        alphaValue = isEnabled ? 1 : 0.33
    }
}
