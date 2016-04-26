//
//  SampleRateAndClockSourceStatusBarView.swift
//  AudioMate
//
//  Created by Ruben Nine on 26/04/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa
import PureLayout_Mac
import AMCoreAudio

class SampleRateAndClockSourceStatusBarView: NSView, StatusBarSubView {
    private var didSetupConstraints: Bool = false

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

    var enabled: Bool = true {
        didSet {
            alphaValue = enabled ? 1.0 : 0.33
        }
    }

    var sampleRateTextField: AMTextField = {
        $0.editable = false
        $0.bordered = false
        $0.drawsBackground = false
        $0.alignment = .Center
        $0.maximumNumberOfLines = 1

        return $0
    }(AMTextField(forAutoLayout: ()))

    var clockSourceTextField: AMTextField = {
        $0.editable = false
        $0.bordered = false
        $0.drawsBackground = false
        $0.alignment = .Center
        $0.maximumNumberOfLines = 1

        return $0
    }(AMTextField(forAutoLayout: ()))

    func updateUI() {
        if let device = representedObject as? AMAudioDevice {
            let formattedSampleRate = FormattingUtils.formatSampleRate(device.nominalSampleRate() ?? 0)

            let formattedClockSource = device.clockSourceForChannel(0, andDirection: .Playback) ?? NSLocalizedString("Internal Clock", comment: "")

            sampleRateTextField.attributedStringValue = attributedStringWithString(formattedSampleRate)
            clockSourceTextField.attributedStringValue = attributedStringWithString(formattedClockSource)
        }
    }

    private func attributedStringWithString(string: String) -> NSAttributedString {
        let textColor: NSColor = shouldHighlight ? .whiteColor() : .labelColor()
        let font = NSFont.boldSystemFontOfSize(9.0)
        let attrs = [NSFontAttributeName: font, NSForegroundColorAttributeName: textColor]
        let attrString = NSMutableAttributedString(string: string, attributes: attrs)

        attrString.setAlignment(NSTextAlignment.Center, range: NSRange(location: 0, length: attrString.length))

        return attrString.copy() as! NSAttributedString
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidMoveToSuperview() {
        addSubview(sampleRateTextField)
        addSubview(clockSourceTextField)
    }

    override func updateConstraints() {
        if didSetupConstraints == false {
            autoPinEdgesToSuperviewEdgesWithInsets(NSEdgeInsets())
            sampleRateTextField.autoPinEdgesToSuperviewEdgesWithInsets(NSEdgeInsets(), excludingEdge: .Bottom)
            clockSourceTextField.autoPinEdgesToSuperviewEdgesWithInsets(NSEdgeInsets(), excludingEdge: .Top)

            didSetupConstraints = true
        }
        
        super.updateConstraints()
    }
}
