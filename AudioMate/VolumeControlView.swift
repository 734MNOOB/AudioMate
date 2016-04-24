//
//  VolumeControlView.swift
//  AudioMate
//
//  Created by Ruben Nine on 06/04/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa

class VolumeControlView: NSView {
    @IBOutlet var volumeSlider: NSSlider!
    @IBOutlet var muteCheckbox: NSButton!

    private var didSetupConstraints: Bool = false

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func updateConstraints() {
        if (!didSetupConstraints) {
            removeConstraints(constraints)
            autoSetDimension(.Height, toSize: 21)

            let sideMargin: CGFloat = 16.0

            muteCheckbox.autoPinEdgeToSuperviewEdge(.Top, withInset: 2)
            muteCheckbox.autoPinEdgeToSuperviewEdge(.Right, withInset: sideMargin)
            muteCheckbox.setContentHuggingPriority(NSLayoutPriorityRequired, forOrientation: NSLayoutConstraintOrientation.Horizontal)
            muteCheckbox.setContentCompressionResistancePriority(NSLayoutPriorityRequired, forOrientation: NSLayoutConstraintOrientation.Horizontal)

            volumeSlider.autoPinEdgeToSuperviewEdge(.Left, withInset: sideMargin)
            volumeSlider.autoPinEdge(.Right, toEdge: .Left, ofView: muteCheckbox, withOffset: -8.0)
            volumeSlider.autoAlignAxis(.Horizontal, toSameAxisOfView: muteCheckbox)
            volumeSlider.setContentHuggingPriority(NSLayoutPriorityDefaultLow, forOrientation: NSLayoutConstraintOrientation.Horizontal)
            volumeSlider.setContentCompressionResistancePriority(NSLayoutPriorityDefaultLow, forOrientation: NSLayoutConstraintOrientation.Horizontal)

            didSetupConstraints = true
        }

        super.updateConstraints()
    }
}
