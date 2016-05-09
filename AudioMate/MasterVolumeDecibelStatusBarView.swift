//
//  MasterVolumeDecibelStatusBarView.swift
//  AudioMate
//
//  Created by Ruben Nine on 09/05/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa
import PureLayout_Mac
import AMCoreAudio

class MasterVolumeDecibelStatusBarView: NSView, StatusBarSubView {
    private var didSetupConstraints: Bool = false

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
        }
    }

    var enabled: Bool = true {
        didSet {
            alphaValue = enabled ? 1.0 : 0.33
        }
    }

    override var allowsVibrancy: Bool { return true }

    override var intrinsicContentSize: NSSize {
        return NSSize(width: 72.0, height: 18.0)
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidMoveToSuperview() {
        addSubview(inVolumeLabel)
        addSubview(outVolumeLabel)
    }

    override func updateConstraints() {
        if didSetupConstraints == false {
            autoPinEdgesToSuperviewEdgesWithInsets(NSEdgeInsets(top: 1, left: 0, bottom: 1, right: 0))

            inVolumeLabel.autoPinEdgesToSuperviewEdgesWithInsets(NSEdgeInsets(), excludingEdge: ALEdge.Bottom)
            outVolumeLabel.autoPinEdgesToSuperviewEdgesWithInsets(NSEdgeInsets(), excludingEdge: ALEdge.Top)

            didSetupConstraints = true
        }

        super.updateConstraints()
    }

    // MARK: Public Functions

    func updateUI() {
        if let device = representedObject as? AMAudioDevice {
            let inVolume = device.masterVolumeInDecibelsForDirection(.Recording)
            let outVolume = device.masterVolumeInDecibelsForDirection(.Playback)

            let inMuted = device.isMasterVolumeMutedForDirection(.Recording)
            let outMuted = device.isMasterVolumeMutedForDirection(.Playback)

            let inString = inVolume == nil ? "N/A IN" : (inMuted == true ? "MUTED IN" : String(format: "%.1fdBFS IN", inVolume!))
            let outString = outVolume == nil ? "N/A OUT" : (outMuted == true ? "MUTED OUT" : String(format: "%.1fdBFS OUT", outVolume!))

            inVolumeLabel.attributedStringValue = attributedStringWithString(inString)
            outVolumeLabel.attributedStringValue = attributedStringWithString(outString)

            inVolumeLabel.alphaValue = inVolume == nil ? 0.33 : 1.0
            outVolumeLabel.alphaValue = outVolume == nil ? 0.33 : 1.0
        }
    }

    // MARK: Private Functions

    private func attributedStringWithString(string: String) -> NSAttributedString {
        let textColor: NSColor = shouldHighlight ? .whiteColor() : .labelColor()
        let font = NSFont.boldSystemFontOfSize(8.0)
        let attrs = [NSFontAttributeName: font, NSForegroundColorAttributeName: textColor]
        let attrString = NSMutableAttributedString(string: string, attributes: attrs)

        attrString.setAlignment(NSTextAlignment.Center, range: NSRange(location: 0, length: attrString.length))

        return attrString.copy() as! NSAttributedString
    }
}
