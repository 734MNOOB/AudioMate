//
//  VolumeStatusBarView.swift
//  AudioMate
//
//  Created by Ruben Nine on 08/05/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa
import PureLayout_Mac
import AMCoreAudio

class VolumeStatusBarView: NSView, StatusBarSubView {
    private var didSetupConstraints: Bool = false

    private var inVolumeView = VolumeView(forAutoLayout: ())
    private var outVolumeView = VolumeView(forAutoLayout: ())

    private var inVolumeLabel: AMTextField = {
        $0.editable = false
        $0.bordered = false
        $0.drawsBackground = false
        $0.alignment = .Center
        $0.maximumNumberOfLines = 1

        return $0
    }(AMTextField(forAutoLayout: ()))

    private var outVolumeLabel: AMTextField = {
        $0.editable = false
        $0.bordered = false
        $0.drawsBackground = false
        $0.alignment = .Center
        $0.maximumNumberOfLines = 1

        return $0
    }(AMTextField(forAutoLayout: ()))

    weak var representedObject: AnyObject? {
        didSet {
            updateUI()
        }
    }

    var shouldHighlight: Bool = false {
        didSet {
            updateUI()
            inVolumeView.shouldHighlight = shouldHighlight
            outVolumeView.shouldHighlight = shouldHighlight
        }
    }

    var enabled: Bool = true {
        didSet {
            alphaValue = enabled ? 1.0 : 0.33

            inVolumeView.enabled = enabled
            outVolumeView.enabled = enabled
        }
    }

    override var allowsVibrancy: Bool { return true }

    func updateUI() {
        if let device = representedObject as? AMAudioDevice {
            let inVolume = device.masterVolumeForDirection(.Recording)
            let outVolume = device.masterVolumeForDirection(.Playback)

            inVolumeLabel.attributedStringValue = attributedStringWithString("IN")
            outVolumeLabel.attributedStringValue = attributedStringWithString("OUT")

            inVolumeView.value = CGFloat(inVolume ?? 0.0)
            outVolumeView.value = CGFloat(outVolume ?? 0.0)
        }
    }

    private func attributedStringWithString(string: String) -> NSAttributedString {
        let textColor: NSColor = shouldHighlight ? .whiteColor() : .labelColor()
        let font = NSFont.boldSystemFontOfSize(7.0)
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
        addSubview(inVolumeView)
        addSubview(inVolumeLabel)
        addSubview(outVolumeView)
        addSubview(outVolumeLabel)
    }

    override var intrinsicContentSize: NSSize {
        return NSSize(width: 42.0, height: 18.0)
    }

    override func updateConstraints() {
        if didSetupConstraints == false {
            autoPinEdgesToSuperviewEdgesWithInsets(NSEdgeInsets(top: 2, left: 5, bottom: 2, right: 5))

            inVolumeView.autoSetDimensionsToSize(CGSize(width: 32.0, height: 8.0))
            inVolumeView.autoPinEdgeToSuperviewEdge(.Top)
            inVolumeView.autoPinEdgeToSuperviewEdge(.Left)

            inVolumeLabel.autoPinEdge(.Left, toEdge: .Right, ofView: inVolumeView, withOffset: 0.0)
            inVolumeLabel.autoAlignAxis(.Horizontal, toSameAxisOfView: inVolumeView)

            outVolumeView.autoSetDimensionsToSize(CGSize(width: 32.0, height: 8.0))
            outVolumeView.autoPinEdgeToSuperviewEdge(.Bottom)
            outVolumeView.autoPinEdgeToSuperviewEdge(.Left)

            outVolumeLabel.autoPinEdge(.Left, toEdge: .Right, ofView: outVolumeView, withOffset: 0.0)
            outVolumeLabel.autoAlignAxis(.Horizontal, toSameAxisOfView: outVolumeView)

            didSetupConstraints = true
        }
        
        super.updateConstraints()
    }
}
