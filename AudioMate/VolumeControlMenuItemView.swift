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
            autoSetDimension(.height, toSize: 42)

            let sideMargin: CGFloat = 21.0

            volumeLabel.autoPinEdge(toSuperviewEdge: .left, withInset: sideMargin)
            volumeLabel.autoPinEdge(toSuperviewEdge: .right, withInset: sideMargin)
            volumeLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 0)

            muteCheckbox.autoPinEdge(.top, to: .bottom, of: volumeLabel, withOffset: 4)
            muteCheckbox.autoPinEdge(toSuperviewEdge: .right, withInset: sideMargin)
            muteCheckbox.setContentHuggingPriority(NSLayoutPriorityRequired, for: NSLayoutConstraintOrientation.horizontal)
            muteCheckbox.setContentCompressionResistancePriority(NSLayoutPriorityRequired, for: NSLayoutConstraintOrientation.horizontal)

            volumeSlider.autoPinEdge(toSuperviewEdge: .left, withInset: sideMargin)
            volumeSlider.autoPinEdge(.right, to: .left, of: muteCheckbox, withOffset: -8.0)
            volumeSlider.autoAlignAxis(.horizontal, toSameAxisOf: muteCheckbox)
            volumeSlider.setContentHuggingPriority(NSLayoutPriorityDefaultLow, for: NSLayoutConstraintOrientation.horizontal)
            volumeSlider.setContentCompressionResistancePriority(NSLayoutPriorityDefaultLow, for: NSLayoutConstraintOrientation.horizontal)

            didSetupConstraints = true
        }

        super.updateConstraints()
    }
}
