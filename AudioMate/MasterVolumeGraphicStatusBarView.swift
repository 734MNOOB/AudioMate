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

    fileprivate var inVolumeLabel = AMTextField(forAutoLayout: ())
    fileprivate var outVolumeLabel = AMTextField(forAutoLayout: ())

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


    // MARK: - Lifecycle functions

    override init(frame frameRect: NSRect) {

        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Overrides

    override func draw(_ dirtyRect: NSRect) {

        super.draw(dirtyRect)

        updateUI()
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
            didSetupConstraints = true

            autoPinEdgesToSuperviewEdges(with: EdgeInsets(top: 2, left: 5, bottom: 2, right: 5))

            inVolumeView.autoSetDimensions(to: CGSize(width: 32.0, height: 8.0))
            inVolumeView.autoPinEdge(toSuperviewEdge: .top)
            inVolumeView.autoPinEdge(toSuperviewEdge: .left)

            inVolumeLabel.autoSetDimension(.height, toSize: 10)
            inVolumeLabel.autoPinEdge(.left, to: .right, of: inVolumeView, withOffset: 0.0)
            inVolumeLabel.autoAlignAxis(.horizontal, toSameAxisOf: inVolumeView)

            outVolumeView.autoSetDimensions(to: CGSize(width: 32.0, height: 8.0))
            outVolumeView.autoPinEdge(toSuperviewEdge: .bottom)
            outVolumeView.autoPinEdge(toSuperviewEdge: .left)

            outVolumeLabel.autoSetDimension(.height, toSize: 10)
            outVolumeLabel.autoPinEdge(.left, to: .right, of: outVolumeView, withOffset: 0.0)
            outVolumeLabel.autoAlignAxis(.horizontal, toSameAxisOf: outVolumeView)
        }
        
        super.updateConstraints()
    }


    // MARK: - Private functions

    private func updateUI() {

        if let device = representedObject as? AudioDevice {
            let inVolume = device.virtualMasterVolume(direction: .recording)
            let outVolume = device.virtualMasterVolume(direction: .playback)

            let inMuted = device.isMasterChannelMuted(direction: .recording)
            let outMuted = device.isMasterChannelMuted(direction: .playback)

            inVolumeLabel.attributedStringValue = attributedString(string: "IN")
            outVolumeLabel.attributedStringValue = attributedString(string: "OUT")

            inVolumeLabel.isEnabled = (inVolume == nil || inMuted == true || isEnabled == false) ? false : true
            outVolumeLabel.isEnabled = (outVolume == nil || outMuted == true || isEnabled == false) ? false : true

            inVolumeView.value = CGFloat(inVolume ?? 0.0)
            outVolumeView.value = CGFloat(outVolume ?? 0.0)

            inVolumeView.isEnabled = isEnabled ? (inMuted == false) : false
            outVolumeView.isEnabled = isEnabled ? (outMuted == false) : false

            inVolumeView.shouldHighlight = shouldHighlight
            outVolumeView.shouldHighlight = shouldHighlight
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
