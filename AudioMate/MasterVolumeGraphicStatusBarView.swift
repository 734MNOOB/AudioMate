//
//  MasterVolumeGraphicStatusBarView.swift
//  AudioMate
//
//  Created by Ruben Nine on 08/05/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa
import PureLayout
import AMCoreAudio

class MasterVolumeGraphicStatusBarView: NSView, StatusBarSubView {

    private var didSetupConstraints: Bool = false

    fileprivate lazy var inVolumeView: MasterVolumeGraphicView = {

        $0.delegate = self
        return $0
    }(MasterVolumeGraphicView(forAutoLayout: ()))

    fileprivate lazy var outVolumeView: MasterVolumeGraphicView = {

        $0.delegate = self
        return $0
    }(MasterVolumeGraphicView(forAutoLayout: ()))

    fileprivate var inVolumeLabel: AMTextField = {

        $0.isEditable = false
        $0.isBordered = false
        $0.drawsBackground = false
        $0.alignment = .center
        $0.maximumNumberOfLines = 1

        return $0
    }(AMTextField(forAutoLayout: ()))

    fileprivate var outVolumeLabel: AMTextField = {

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

            inVolumeView.shouldHighlight = shouldHighlight
            outVolumeView.shouldHighlight = shouldHighlight
        }
    }

    var isEnabled: Bool = true {

        didSet {
            alphaValue = isEnabled ? 1.0 : 0.33

            inVolumeView.isEnabled = isEnabled
            outVolumeView.isEnabled = isEnabled
        }
    }

    override var allowsVibrancy: Bool {

        return true
    }


    func updateUI() {

        if let device = representedObject as? AudioDevice {
            let inVolume = device.virtualMasterVolume(direction: .recording)
            let outVolume = device.virtualMasterVolume(direction: .playback)

            let inMuted = device.isMasterChannelMuted(direction: .recording)
            let outMuted = device.isMasterChannelMuted(direction: .playback)

            inVolumeLabel.attributedStringValue = attributedString(string: "IN")
            outVolumeLabel.attributedStringValue = attributedString(string: "OUT")

            inVolumeLabel.alphaValue = (inVolume == nil || inMuted == true) ? 0.33 : 1.0
            outVolumeLabel.alphaValue = (outVolume == nil || outMuted == true) ? 0.33 : 1.0

            inVolumeView.value = CGFloat(inVolume ?? 0.0)
            outVolumeView.value = CGFloat(outVolume ?? 0.0)

            inVolumeView.isEnabled = inMuted == false
            outVolumeView.isEnabled = outMuted == false
        }
    }

    private func attributedString(string: String) -> NSAttributedString {

        let textColor: NSColor = shouldHighlight ? .white : .labelColor
        let font = NSFont.boldSystemFont(ofSize: 7.0)
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
            autoPinEdgesToSuperviewEdges(with: EdgeInsets(top: 2, left: 5, bottom: 2, right: 5))

            inVolumeView.autoSetDimensions(to: CGSize(width: 32.0, height: 8.0))
            inVolumeView.autoPinEdge(toSuperviewEdge: .top)
            inVolumeView.autoPinEdge(toSuperviewEdge: .left)

            inVolumeLabel.autoPinEdge(.left, to: .right, of: inVolumeView, withOffset: 0.0)
            inVolumeLabel.autoAlignAxis(.horizontal, toSameAxisOf: inVolumeView)

            outVolumeView.autoSetDimensions(to: CGSize(width: 32.0, height: 8.0))
            outVolumeView.autoPinEdge(toSuperviewEdge: .bottom)
            outVolumeView.autoPinEdge(toSuperviewEdge: .left)

            outVolumeLabel.autoPinEdge(.left, to: .right, of: outVolumeView, withOffset: 0.0)
            outVolumeLabel.autoAlignAxis(.horizontal, toSameAxisOf: outVolumeView)

            didSetupConstraints = true
        }
        
        super.updateConstraints()
    }

    // PRAGMA MARK: Private Functions

    fileprivate func changeVolume(delta: Float, direction: Direction) {

        if let device = representedObject as? AudioDevice,
            let volume = device.virtualMasterVolume(direction: direction) {
            device.setVirtualMasterVolume(volume + Float32(delta), direction: direction)
        }
    }
}

extension MasterVolumeGraphicStatusBarView: MasterVolumeGraphicViewDelegate {

    func volumeViewScrolled(volumeView: MasterVolumeGraphicView, delta: CGFloat) {

        guard delta != 0 else { return }

        let volumeDelta: Float = delta > 0 ? -0.1 : 0.1

        switch volumeView {
        case inVolumeView:

            changeVolume(delta: volumeDelta, direction: .recording)

        case outVolumeView:

            changeVolume(delta: volumeDelta, direction: .playback)

        default:

            break

        }
    }
}
