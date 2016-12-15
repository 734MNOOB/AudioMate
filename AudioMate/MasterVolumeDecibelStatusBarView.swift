//
//  MasterVolumeDecibelStatusBarView.swift
//  AudioMate
//
//  Created by Ruben Nine on 09/05/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa
import PureLayout
import AMCoreAudio

class MasterVolumeDecibelStatusBarView: NSView, StatusBarSubView {

    private var didSetupConstraints: Bool = false

    private var inVolumeLabel: AMTextField = {

        $0.isEditable = false
        $0.isBordered = false
        $0.drawsBackground = false
        $0.alignment = .center
        $0.maximumNumberOfLines = 1

        return $0
    }(AMTextField(forAutoLayout: ()))

    private var outVolumeLabel: AMTextField = {

        $0.isEditable = false
        $0.isBordered = false
        $0.drawsBackground = false
        $0.alignment = .center
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

    var isEnabled: Bool = true {

        didSet {
            alphaValue = isEnabled ? 1.0 : 0.33
        }
    }

    override var allowsVibrancy: Bool {

        return true
    }

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
            autoPinEdgesToSuperviewEdges(with: EdgeInsets(top: 1, left: 0, bottom: 1, right: 0))

            inVolumeLabel.autoPinEdgesToSuperviewEdges(with: EdgeInsets(), excludingEdge: ALEdge.bottom)
            outVolumeLabel.autoPinEdgesToSuperviewEdges(with: EdgeInsets(), excludingEdge: ALEdge.top)

            didSetupConstraints = true
        }

        super.updateConstraints()
    }

    // MARK: Public Functions

    func updateUI() {

        if let device = representedObject as? AudioDevice {
            let inVolume = device.virtualMasterVolumeInDecibels(direction: .recording)
            let outVolume = device.virtualMasterVolumeInDecibels(direction: .playback)

            let inMuted = device.isMasterChannelMuted(direction: .recording)
            let outMuted = device.isMasterChannelMuted(direction: .playback)

            let inString = inVolume == nil ? "N/A IN" : (inMuted == true ? "MUTED IN" : String(format: "%.1fdBFS IN", inVolume!))
            let outString = outVolume == nil ? "N/A OUT" : (outMuted == true ? "MUTED OUT" : String(format: "%.1fdBFS OUT", outVolume!))

            inVolumeLabel.attributedStringValue = attributedString(string: inString)
            outVolumeLabel.attributedStringValue = attributedString(string: outString)

            inVolumeLabel.alphaValue = (inVolume == nil || inMuted == true) ? 0.33 : 1.0
            outVolumeLabel.alphaValue = (outVolume == nil || outMuted == true) ? 0.33 : 1.0
        }
    }

    // MARK: Private Functions

    private func attributedString(string: String) -> NSAttributedString {

        let textColor: NSColor = shouldHighlight ? .white : .labelColor
        let font = NSFont.boldSystemFont(ofSize: 8.0)
        let attrs = [NSFontAttributeName: font, NSForegroundColorAttributeName: textColor]
        let attrString = NSMutableAttributedString(string: string, attributes: attrs)

        attrString.setAlignment(NSTextAlignment.center, range: NSRange(location: 0, length: attrString.length))

        return attrString.copy() as! NSAttributedString
    }
}
