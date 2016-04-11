//
//  MenuItemView.swift
//  AudioMate
//
//  Created by Ruben Nine on 06/04/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa

class MenuItemView: NSView {

    var sampleRate: Double {
        get {
            return sampleRateTextField.doubleValue
        }

        set {
            sampleRateTextField.stringValue = FormattingUtils.formatSampleRate(newValue)
        }
    }

    var clockSource: String {
        get {
            return clockSourceTextField.stringValue
        }

        set {
            clockSourceTextField.stringValue = newValue
        }
    }

    var inputChannels: String {
        get {
            return inputChannelsTextField.stringValue
        }

        set {
            inputChannelsTextField.stringValue = newValue
        }
    }

    var outputChannels: String {
        get {
            return outputChannelsTextField.stringValue
        }

        set {
            outputChannelsTextField.stringValue = newValue
        }
    }

    var displayOutputDeviceIcon: Bool {
        get {
            return !outputDeviceImageView.hidden
        }

        set {
            outputDeviceImageView.hidden = !newValue
            updateDefaultDeviceConstraints()
        }
    }

    var displayInputDeviceIcon: Bool {
        get {
            return !inputDeviceImageView.hidden
        }

        set {
            inputDeviceImageView.hidden = !newValue
            updateDefaultDeviceConstraints()
        }
    }

    var displaySystemOuputDeviceIcon: Bool {
        get {
            return !systemOutputDeviceImageView.hidden
        }

        set {
            systemOutputDeviceImageView.hidden = !newValue
            updateDefaultDeviceConstraints()
        }
    }

    private var didSetupConstraints: Bool = false

    @IBOutlet var inputVolumeSlider: NSSlider!
    @IBOutlet var outputVolumeSlider: NSSlider!
    @IBOutlet var inputMuteCheckbox: NSButton!
    @IBOutlet var outputMuteCheckbox: NSButton!
    @IBOutlet private var sampleRateTextField: NSTextField!
    @IBOutlet private var clockSourceTextField: NSTextField!
    @IBOutlet private var inputChannelsTextField: NSTextField!
    @IBOutlet private var outputChannelsTextField: NSTextField!
    @IBOutlet private var outputDeviceImageView: NSImageView!
    @IBOutlet private var inputDeviceImageView: NSImageView!
    @IBOutlet private var systemOutputDeviceImageView: NSImageView!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func updateConstraints() {
        if (!didSetupConstraints) {
            removeConstraints(constraints)

            autoSetDimension(.Height, toSize: 38)

            inputMuteCheckbox.autoPinEdgeToSuperviewEdge(.Top, withInset: 2)
            inputMuteCheckbox.autoPinEdgeToSuperviewEdge(.Right, withInset: 22)
            inputMuteCheckbox.setContentHuggingPriority(NSLayoutPriorityRequired, forOrientation: NSLayoutConstraintOrientation.Horizontal)
            inputMuteCheckbox.setContentCompressionResistancePriority(NSLayoutPriorityRequired, forOrientation: NSLayoutConstraintOrientation.Horizontal)

            outputMuteCheckbox.autoPinEdge(.Top, toEdge: .Bottom, ofView: inputMuteCheckbox, withOffset: 6.0)
            outputMuteCheckbox.autoAlignAxis(.Vertical, toSameAxisOfView: inputMuteCheckbox)
            outputMuteCheckbox.setContentHuggingPriority(NSLayoutPriorityRequired, forOrientation: NSLayoutConstraintOrientation.Horizontal)
            outputMuteCheckbox.setContentCompressionResistancePriority(NSLayoutPriorityRequired, forOrientation: NSLayoutConstraintOrientation.Horizontal)

            inputVolumeSlider.autoSetDimension(.Width, toSize: 80)
            inputVolumeSlider.autoPinEdge(.Right, toEdge: .Left, ofView: inputMuteCheckbox, withOffset: -8.0)
            inputVolumeSlider.autoAlignAxis(.Horizontal, toSameAxisOfView: inputMuteCheckbox)
            inputVolumeSlider.setContentHuggingPriority(NSLayoutPriorityRequired, forOrientation: NSLayoutConstraintOrientation.Horizontal)
            inputVolumeSlider.setContentCompressionResistancePriority(NSLayoutPriorityRequired, forOrientation: NSLayoutConstraintOrientation.Horizontal)

            outputVolumeSlider.autoMatchDimension(.Width, toDimension: .Width, ofView: inputVolumeSlider)
            outputVolumeSlider.autoPinEdge(.Right, toEdge: .Left, ofView: outputMuteCheckbox, withOffset: -8.0)
            outputVolumeSlider.autoAlignAxis(.Horizontal, toSameAxisOfView: outputMuteCheckbox)
            outputVolumeSlider.setContentHuggingPriority(NSLayoutPriorityRequired, forOrientation: NSLayoutConstraintOrientation.Horizontal)
            outputVolumeSlider.setContentCompressionResistancePriority(NSLayoutPriorityRequired, forOrientation: NSLayoutConstraintOrientation.Horizontal)

            inputChannelsTextField.autoPinEdge(.Right, toEdge: .Left, ofView: inputVolumeSlider, withOffset: -8.0)
            inputChannelsTextField.autoAlignAxis(.Horizontal, toSameAxisOfView: inputVolumeSlider)
            inputChannelsTextField.setContentHuggingPriority(NSLayoutPriorityRequired, forOrientation: NSLayoutConstraintOrientation.Horizontal)
            inputChannelsTextField.setContentCompressionResistancePriority(NSLayoutPriorityRequired, forOrientation: NSLayoutConstraintOrientation.Horizontal)

            outputChannelsTextField.autoPinEdge(.Right, toEdge: .Left, ofView: outputVolumeSlider, withOffset: -8.0)
            outputChannelsTextField.autoAlignAxis(.Horizontal, toSameAxisOfView: outputVolumeSlider)
            outputChannelsTextField.setContentHuggingPriority(NSLayoutPriorityRequired, forOrientation: NSLayoutConstraintOrientation.Horizontal)
            outputChannelsTextField.setContentCompressionResistancePriority(NSLayoutPriorityRequired, forOrientation: NSLayoutConstraintOrientation.Horizontal)

            sampleRateTextField.autoPinEdge(.Right, toEdge: .Left, ofView: inputChannelsTextField, withOffset: -8.0)
            sampleRateTextField.autoPinEdge(.Left, toEdge: .Left, ofView: clockSourceTextField)
            sampleRateTextField.autoAlignAxis(.Horizontal, toSameAxisOfView: inputChannelsTextField)
            sampleRateTextField.setContentHuggingPriority(NSLayoutPriorityDefaultLow, forOrientation: NSLayoutConstraintOrientation.Horizontal)
            sampleRateTextField.setContentCompressionResistancePriority(NSLayoutPriorityDefaultLow, forOrientation: NSLayoutConstraintOrientation.Horizontal)

            clockSourceTextField.autoPinEdge(.Right, toEdge: .Left, ofView: outputChannelsTextField, withOffset: -8.0)
            clockSourceTextField.autoPinEdgeToSuperviewEdge(.Left, withInset: 62)
            clockSourceTextField.autoAlignAxis(.Horizontal, toSameAxisOfView: outputChannelsTextField)
            clockSourceTextField.setContentHuggingPriority(NSLayoutPriorityDefaultLow, forOrientation: NSLayoutConstraintOrientation.Horizontal)
            clockSourceTextField.setContentCompressionResistancePriority(NSLayoutPriorityDefaultLow, forOrientation: NSLayoutConstraintOrientation.Horizontal)

            updateDefaultDeviceConstraints(true)

            didSetupConstraints = true
        }

        super.updateConstraints()
    }

    private func updateDefaultDeviceConstraints(force: Bool = false) {
        if !didSetupConstraints && !force {
            return
        }

        inputDeviceImageView.autoPinEdge(.Right, toEdge: .Left, ofView: clockSourceTextField, withOffset: -8)
        inputDeviceImageView.autoPinEdgeToSuperviewEdge(.Top, withInset: 12)

        if inputDeviceImageView.hidden {
            outputDeviceImageView.autoPinEdge(.Right, toEdge: .Left, ofView: clockSourceTextField, withOffset: -8)
        } else {
            outputDeviceImageView.autoPinEdge(.Right, toEdge: .Left, ofView: inputDeviceImageView, withOffset: 0)
        }

        outputDeviceImageView.autoPinEdgeToSuperviewEdge(.Top, withInset: 12)

        if outputDeviceImageView.hidden {
            systemOutputDeviceImageView.autoPinEdge(.Right, toEdge: .Left, ofView: clockSourceTextField, withOffset: -8)
        } else {
            systemOutputDeviceImageView.autoPinEdge(.Right, toEdge: .Left, ofView: outputDeviceImageView, withOffset: 0)
        }

        systemOutputDeviceImageView.autoPinEdgeToSuperviewEdge(.Top, withInset: 12)
    }
}
