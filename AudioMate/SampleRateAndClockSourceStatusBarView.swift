//
//  SampleRateAndClockSourceStatusBarView.swift
//  AudioMate
//
//  Created by Ruben Nine on 26/04/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa
import PureLayout
import AMCoreAudio

class SampleRateAndClockSourceStatusBarView: NSView, StatusBarSubView {

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

    var isEnabled: Bool = true {

        didSet {
            alphaValue = isEnabled ? 1.0 : 0.33
        }
    }

    var sampleRateTextField: AMTextField = {

        $0.isEditable = false
        $0.isBordered = false
        $0.drawsBackground = false
        $0.alignment = .center
        $0.maximumNumberOfLines = 1

        return $0
    }(AMTextField(forAutoLayout: ()))

    var clockSourceTextField: AMTextField = {

        $0.isEditable = false
        $0.isBordered = false
        $0.drawsBackground = false
        $0.alignment = .center
        $0.maximumNumberOfLines = 1

        return $0
    }(AMTextField(forAutoLayout: ()))

    func updateUI() {

        if let device = representedObject as? AudioDevice {

            let formattedSampleRate = device.nominalSampleRate()?.string(as: .sampleRate) ?? "N/A"
            let formattedClockSource = device.clockSourceName(channel: 0, direction: .Playback) ?? NSLocalizedString("Internal Clock", comment: "")

            sampleRateTextField.attributedStringValue = attributedString(string: formattedSampleRate)
            clockSourceTextField.attributedStringValue = attributedString(string: formattedClockSource)
        }
    }

    private func attributedString(string: String) -> NSAttributedString {

        let textColor: NSColor = shouldHighlight ? .white : .labelColor
        let font = NSFont.boldSystemFont(ofSize: 9.0)
        let attrs = [NSFontAttributeName: font, NSForegroundColorAttributeName: textColor]
        let attrString = NSMutableAttributedString(string: string, attributes: attrs)

        attrString.setAlignment(NSTextAlignment.center, range: NSRange(location: 0, length: attrString.length))

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
            autoPinEdgesToSuperviewEdges(with: EdgeInsets())
            sampleRateTextField.autoPinEdgesToSuperviewEdges(with: EdgeInsets(), excludingEdge: .bottom)
            clockSourceTextField.autoPinEdgesToSuperviewEdges(with: EdgeInsets(), excludingEdge: .top)

            didSetupConstraints = true
        }
        
        super.updateConstraints()
    }
}
