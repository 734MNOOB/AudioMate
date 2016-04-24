//
//  NotificationPreferencesViewController.swift
//  AudioMate
//
//  Created by Ruben Nine on 4/24/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa

class NotificationPreferencesViewController: NSViewController {

    @IBOutlet var everytimeADeviceIsAddedOrRemovedButton: NSButton!
    @IBOutlet var everytimeADeviceVolumeChangesButton: NSButton!
    @IBOutlet var everytimeADeviceMuteStateChangesButton: NSButton!
    @IBOutlet var everytimeADeviceSampleRateChangesButton: NSButton!
    @IBOutlet var everytimeADeviceClockSourceChangesButton: NSButton!
    @IBOutlet var everytimeADeviceBecomesDefaultButton: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        preferences.notifications.shouldDisplayAddedAndRemovedDeviceChanges.map {
            $0 ? NSOnState : NSOffState
        }.bindTo(everytimeADeviceIsAddedOrRemovedButton.bnd_state)

        preferences.notifications.shouldDisplayVolumeChanges.map {
            $0 ? NSOnState : NSOffState
        }.bindTo(everytimeADeviceVolumeChangesButton.bnd_state)

        preferences.notifications.shouldDisplayMuteChanges.map {
            $0 ? NSOnState : NSOffState
        }.bindTo(everytimeADeviceMuteStateChangesButton.bnd_state)

        preferences.notifications.shouldDisplaySampleRateChanges.map {
            $0 ? NSOnState : NSOffState
        }.bindTo(everytimeADeviceSampleRateChangesButton.bnd_state)

        preferences.notifications.shouldDisplayClockSourceChanges.map {
            $0 ? NSOnState : NSOffState
        }.bindTo(everytimeADeviceClockSourceChangesButton.bnd_state)

        preferences.notifications.shouldDisplayDefaultDeviceChanges.map {
            $0 ? NSOnState : NSOffState
        }.bindTo(everytimeADeviceBecomesDefaultButton.bnd_state)
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        preferredContentSize = view.bounds.size
    }

    @IBAction func handleCheckButton(sender: AnyObject) {
        guard let button = sender as? NSButton else {
            return
        }

        let boolValue = button.state == NSOnState

        switch button {
        case everytimeADeviceIsAddedOrRemovedButton:
            preferences.notifications.shouldDisplayAddedAndRemovedDeviceChanges.value = boolValue
        case everytimeADeviceVolumeChangesButton:
            preferences.notifications.shouldDisplayVolumeChanges.value = boolValue
        case everytimeADeviceMuteStateChangesButton:
            preferences.notifications.shouldDisplayMuteChanges.value = boolValue
        case everytimeADeviceSampleRateChangesButton:
            preferences.notifications.shouldDisplaySampleRateChanges.value = boolValue
        case everytimeADeviceClockSourceChangesButton:
            preferences.notifications.shouldDisplayClockSourceChanges.value = boolValue
        case everytimeADeviceBecomesDefaultButton:
            preferences.notifications.shouldDisplayDefaultDeviceChanges.value = boolValue
        default:
            log.debug("Unhandled button: \(button)")
        }
    }
}
