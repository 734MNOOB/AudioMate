//
//  NotificationPreferencesViewController.swift
//  AudioMate
//
//  Created by Ruben Nine on 4/24/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa
import ReactiveKit

class NotificationPreferencesViewController: NSViewController {

    @IBOutlet var everytimeADeviceIsAddedOrRemovedButton: NSButton!
    @IBOutlet var everytimeADeviceVolumeChangesButton: NSButton!
    @IBOutlet var everytimeADeviceMuteStateChangesButton: NSButton!
    @IBOutlet var everytimeADeviceSampleRateChangesButton: NSButton!
    @IBOutlet var everytimeADeviceClockSourceChangesButton: NSButton!
    @IBOutlet var everytimeADeviceBecomesDefaultButton: NSButton!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {

        super.viewDidLoad()

        // Do view setup here.

        prefs.notifications.shouldDisplayAddedAndRemovedDeviceChanges.map {
            $0 ? NSOnState : NSOffState
        }.observeNext { (value) in
            self.everytimeADeviceIsAddedOrRemovedButton.state = value
        }.disposeIn(disposeBag)

        prefs.notifications.shouldDisplayVolumeChanges.map {
            $0 ? NSOnState : NSOffState
        }.observeNext { (value) in
            self.everytimeADeviceVolumeChangesButton.state = value
        }.disposeIn(disposeBag)

        prefs.notifications.shouldDisplayMuteChanges.map {
            $0 ? NSOnState : NSOffState
        }.observeNext { (value) in
            self.everytimeADeviceMuteStateChangesButton.state = value
        }.disposeIn(disposeBag)

        prefs.notifications.shouldDisplaySampleRateChanges.map {
            $0 ? NSOnState : NSOffState
        }.observeNext { (value) in
            self.everytimeADeviceSampleRateChangesButton.state = value
        }.disposeIn(disposeBag)

        prefs.notifications.shouldDisplayClockSourceChanges.map {
            $0 ? NSOnState : NSOffState
        }.observeNext { (value) in
            self.everytimeADeviceClockSourceChangesButton.state = value
        }.disposeIn(disposeBag)

        prefs.notifications.shouldDisplayDefaultDeviceChanges.map {
            $0 ? NSOnState : NSOffState
        }.observeNext { (value) in
            self.everytimeADeviceBecomesDefaultButton.state = value
        }.disposeIn(disposeBag)
    }

    override func viewWillAppear() {

        super.viewWillAppear()

        preferredContentSize = view.bounds.size
    }

    @IBAction func handleCheckButton(_ sender: AnyObject) {

        guard let button = sender as? NSButton else { return }

        let boolValue = button.state == NSOnState

        switch button {
        case everytimeADeviceIsAddedOrRemovedButton:

            prefs.notifications.shouldDisplayAddedAndRemovedDeviceChanges.value = boolValue

        case everytimeADeviceVolumeChangesButton:

            prefs.notifications.shouldDisplayVolumeChanges.value = boolValue

        case everytimeADeviceMuteStateChangesButton:

            prefs.notifications.shouldDisplayMuteChanges.value = boolValue

        case everytimeADeviceSampleRateChangesButton:

            prefs.notifications.shouldDisplaySampleRateChanges.value = boolValue

        case everytimeADeviceClockSourceChangesButton:

            prefs.notifications.shouldDisplayClockSourceChanges.value = boolValue

        case everytimeADeviceBecomesDefaultButton:

            prefs.notifications.shouldDisplayDefaultDeviceChanges.value = boolValue

        default:

            log.debug("Unhandled button: \(button)")

        }
    }
}
