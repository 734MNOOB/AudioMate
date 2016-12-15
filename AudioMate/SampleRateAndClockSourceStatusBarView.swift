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
    private var sampleRateTextField = AMTextField(forAutoLayout: ())
    private var clockSourceTextField = AMTextField(forAutoLayout: ())

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

    var isEnabled: Bool = true {

        didSet {
            setNeedsDisplay(bounds)
        }
    }

    override var intrinsicContentSize: NSSize {

        return NSSize(width: 82, height: 18)
    }


    // MARK: Lifecycle functions

    override init(frame frameRect: NSRect) {

        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }
    

    // MARK: Overrides

    override func draw(_ dirtyRect: NSRect) {

        updateUI()

        super.draw(dirtyRect)
    }

    override func viewDidMoveToSuperview() {

        addSubview(sampleRateTextField)
        addSubview(clockSourceTextField)
    }

    override func updateConstraints() {

        if didSetupConstraints == false {
            didSetupConstraints = true

            autoPinEdgesToSuperviewEdges(with: EdgeInsets(top: 1, left: 0, bottom: 1, right: 0))

            sampleRateTextField.autoPinEdge(toSuperviewEdge: .top)
            sampleRateTextField.autoAlignAxis(toSuperviewAxis: .vertical)

            clockSourceTextField.autoPinEdge(toSuperviewEdge: .bottom)
            clockSourceTextField.autoAlignAxis(toSuperviewAxis: .vertical)
        }
        
        super.updateConstraints()
    }


    // MARK: Private functions

    private func updateUI() {

        if let device = representedObject as? AudioDevice {

            let formattedSampleRate = device.nominalSampleRate()?.string(as: .sampleRate) ?? "N/A"
            let formattedClockSource = device.clockSourceName(channel: 0, direction: .playback) ?? NSLocalizedString("Internal Clock", comment: "")

            sampleRateTextField.attributedStringValue = attributedString(string: formattedSampleRate)
            clockSourceTextField.attributedStringValue = attributedString(string: formattedClockSource)
            sampleRateTextField.isEnabled = isEnabled
            clockSourceTextField.isEnabled = isEnabled
        }
    }
    
    private func attributedString(string: String) -> NSAttributedString {

        let textColor: NSColor = shouldHighlight ? .white : .labelColor
        let font = NSFont.boldSystemFont(ofSize: 9)
        let attrs = [NSFontAttributeName: font, NSForegroundColorAttributeName: textColor]
        let attrString = NSMutableAttributedString(string: string, attributes: attrs)

        attrString.setAlignment(NSTextAlignment.center, range: NSRange(location: 0, length: attrString.length))

        return attrString.copy() as! NSAttributedString
    }
}
