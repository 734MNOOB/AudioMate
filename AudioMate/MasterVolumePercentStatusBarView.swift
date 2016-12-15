//
//  MasterVolumePercentStatusBarView.swift
//  AudioMate
//
//  Created by Ruben Nine on 09/05/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa
import PureLayout
import AMCoreAudio

class MasterVolumePercentStatusBarView: NSView, StatusBarSubView {

    private var didSetupConstraints: Bool = false

    private var inVolumeLabel = AMTextField(forAutoLayout: ())
    private var outVolumeLabel = AMTextField(forAutoLayout: ())

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

    override var allowsVibrancy: Bool {

        return true
    }

    override var intrinsicContentSize: NSSize {

        return NSSize(width: 64.0, height: 18.0)
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

        super.draw(dirtyRect)

        updateUI()
    }

    override func viewDidMoveToSuperview() {

        addSubview(inVolumeLabel)
        addSubview(outVolumeLabel)
    }

    override func updateConstraints() {

        if didSetupConstraints == false {
            didSetupConstraints = true

            autoPinEdgesToSuperviewEdges(with: EdgeInsets(top: 1, left: 0, bottom: 1, right: 0))

            inVolumeLabel.autoPinEdgesToSuperviewEdges(with: EdgeInsets(), excludingEdge: .bottom)
            outVolumeLabel.autoPinEdgesToSuperviewEdges(with: EdgeInsets(), excludingEdge: .top)
        }
        
        super.updateConstraints()
    }


    // MARK: Private Functions

    private func updateUI() {

        if let device = representedObject as? AudioDevice {
            let inVolume = device.virtualMasterVolume(direction: .recording)
            let outVolume = device.virtualMasterVolume(direction: .playback)

            let inMuted = device.isMasterChannelMuted(direction: .recording)
            let outMuted = device.isMasterChannelMuted(direction: .playback)

            let inString = inVolume == nil ? "N/A IN" : (inMuted == true ? "MUTED IN" : String(format: "%.1f%% IN", inVolume! * 100))
            let outString = outVolume == nil ? "N/A OUT" : (outMuted == true ? "MUTED OUT" : String(format: "%.1f%% OUT", outVolume! * 100))

            inVolumeLabel.attributedStringValue = attributedString(string: inString)
            outVolumeLabel.attributedStringValue = attributedString(string: outString)

            inVolumeLabel.isEnabled = (inVolume == nil || inMuted == true || isEnabled == false) ? false : true
            outVolumeLabel.isEnabled = (outVolume == nil || outMuted == true || isEnabled == false) ? false : true
        }
    }

    private func attributedString(string: String) -> NSAttributedString {

        let textColor: NSColor = shouldHighlight ? .white : .labelColor
        let font = NSFont.boldSystemFont(ofSize: 8.0)
        let attrs = [NSFontAttributeName: font, NSForegroundColorAttributeName: textColor]
        let attrString = NSMutableAttributedString(string: string, attributes: attrs)

        attrString.setAlignment(NSTextAlignment.center, range: NSRange(location: 0, length: attrString.length))
        
        return attrString.copy() as! NSAttributedString
    }
}
