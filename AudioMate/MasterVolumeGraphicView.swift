//
//  MasterVolumeGraphicView.swift
//  AudioMate
//
//  Created by Ruben Nine on 08/05/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa

protocol MasterVolumeGraphicViewDelegate {

    func volumeViewScrolled(volumeView: MasterVolumeGraphicView, delta: CGFloat)

}


class MasterVolumeGraphicView: NSView {

    var delegate: MasterVolumeGraphicViewDelegate?

    private var needsLayerSetup: Bool = true
    private var maskLayer: CALayer?
    private var innerLayer: CALayer?

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

    var value: CGFloat = 0.0 {

        didSet {
            updateUI()
        }
    }

    override var allowsVibrancy: Bool { return true }

    override init(frame frameRect: NSRect) {

        super.init(frame: frameRect)
        wantsLayer = true
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidMoveToSuperview() {

        super.viewDidMoveToSuperview()

        if needsLayerSetup {
            setupLayers()
            needsLayerSetup = false
        }
    }

    override func scrollWheel(with theEvent: NSEvent) {

        super.scrollWheel(with: theEvent)
        delegate?.volumeViewScrolled(volumeView: self, delta: theEvent.deltaY)
    }

    override func draw(_ dirtyRect: NSRect) {

        super.draw(dirtyRect)

        updateUI()
    }

    // MARK: Public Functions

    func updateUI() {

        layer!.backgroundColor = (shouldHighlight ? NSColor.white.withAlphaComponent(0.16) : NSColor.labelColor.withAlphaComponent(0.16)).cgColor

        innerLayer?.backgroundColor = (shouldHighlight ? NSColor.white : NSColor.labelColor).cgColor

        let size = CGSize(width: bounds.size.width * value, height: bounds.size.height)
        innerLayer?.frame = CGRect(origin: .zero, size: size)
    }

    // MARK: Private Functions

    private func setupLayers() {

        assert(layer != nil, "We can not continue without a backing layer.")

        if let volumeControlImage = NSImage(named: "Volume-control") {
            maskLayer = CALayer()
            maskLayer?.frame = CGRect(origin: .zero, size: volumeControlImage.size)
            maskLayer?.contents = volumeControlImage

            innerLayer = CALayer()

            layer!.mask = maskLayer
            layer!.addSublayer(innerLayer!)
        }
    }
}
