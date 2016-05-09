//
//  VolumeControlMenuItemView.swift
//  AudioMate
//
//  Created by Ruben Nine on 06/04/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa

class VolumeControlMenuItemView: NSView {
    @IBOutlet var volumeSlider: NSSlider!
    @IBOutlet var muteCheckbox: NSButton!
    @IBOutlet var volumeLabel: NSTextField!

    private var didSetupConstraints: Bool = false

    override func updateConstraints() {
        if !didSetupConstraints {
            removeConstraints(constraints)
            autoSetDimension(.Height, toSize: 42)

            let sideMargin: CGFloat = 21.0

            volumeLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: sideMargin)
            volumeLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: sideMargin)
            volumeLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 0)

            muteCheckbox.autoPinEdge(.Top, toEdge: .Bottom, ofView: volumeLabel, withOffset: 4)
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
