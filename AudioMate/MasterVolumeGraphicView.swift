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

    var enabled: Bool = true {
        didSet {
            alphaValue = enabled ? 1.0 : 0.33
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

    override func scrollWheel(theEvent: NSEvent) {
        super.scrollWheel(theEvent)
        delegate?.volumeViewScrolled(self, delta: theEvent.deltaY)
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        updateUI()
    }

    // MARK: Public Functions

    func updateUI() {
        layer!.backgroundColor = (shouldHighlight ? NSColor.whiteColor().colorWithAlphaComponent(0.16) : NSColor.labelColor().colorWithAlphaComponent(0.16)).CGColor

        innerLayer?.backgroundColor = (shouldHighlight ? NSColor.whiteColor() : NSColor.labelColor()).CGColor

        let size = CGSize(width: bounds.size.width * value, height: bounds.size.height)
        innerLayer?.frame = CGRect(origin: CGPointZero, size: size)
    }

    // MARK: Private Functions

    private func setupLayers() {
        assert(layer != nil, "We can not continue without a backing layer.")

        if let volumeControlImage = NSImage(named: "Volume-control") {
            maskLayer = CALayer()
            maskLayer?.frame = CGRect(origin: CGPointZero, size: volumeControlImage.size)
            maskLayer?.contents = volumeControlImage

            innerLayer = CALayer()

            layer!.mask = maskLayer
            layer!.addSublayer(innerLayer!)
        }
    }
}
