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
    private var maskLayer: CALayer!
    private var innerLayer: CALayer!

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

    var value: CGFloat = 0.0 {

        didSet {
            setNeedsDisplay(bounds)
        }
    }

    override var allowsVibrancy: Bool { return true }


    // MARK: Lifecycle Functions

    override init(frame frameRect: NSRect) {

        super.init(frame: frameRect)

        wantsLayer = true
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Overrides

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
    

    // MARK: Private Functions

    private func updateUI() {

        guard let layer = layer else { return }

        layer.backgroundColor = contentColor().copy(alpha: 0.16)
        innerLayer.backgroundColor = contentColor()

        let size = CGSize(width: bounds.width * value, height: bounds.height)
        innerLayer.frame = CGRect(origin: .zero, size: size)
    }
    
    private func setupLayers() {

        guard let layer = layer else { return }

        if let volumeControlImage = NSImage(named: "Volume-control") {
            maskLayer = CALayer()
            maskLayer.frame = CGRect(origin: .zero, size: volumeControlImage.size)
            maskLayer.contents = volumeControlImage

            innerLayer = CALayer()

            layer.mask = maskLayer
            layer.addSublayer(innerLayer)
        }
    }

    private func contentColor() -> CGColor {

        let color = (shouldHighlight ? NSColor.white : NSColor.labelColor).cgColor

        return isEnabled ? color : color.copy(alpha: 0.33)!
    }
}
