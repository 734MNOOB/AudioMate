//
//  AppDelegate.swift
//  AudioMate
//
//  Created by Ruben Nine on 18/01/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa
import AMCoreAudio
import XCGLogger

let mainStoryboard = NSStoryboard(name: "Main", bundle: nil)

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private let statusBarViewController: StatusBarViewController? = {

        return mainStoryboard.instantiateController(withIdentifier: "statusBarViewController") as? StatusBarViewController
    }()

    // Instantiate our app status bar item
    private let appStatusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)


    func applicationDidFinishLaunching(_ notification: Notification) {

        // Upon 1st launch, present a welcome panel
        if prefs.general.isFirstLaunch.value == true {
            prefs.general.isFirstLaunch.value = false
        }

        // Subscribe to events
        NotificationCenter.defaultCenter.subscribe(self, eventType: AudioHardwareEvent.self, dispatchQueue: .main)
        NotificationCenter.defaultCenter.subscribe(self, eventType: AudioDeviceEvent.self, dispatchQueue: .main)
        NotificationCenter.defaultCenter.subscribe(self, eventType: AudioStreamEvent.self, dispatchQueue: .main)

        // Instantiate StatusBarViewController and add all known devices in the system
        if let sbvc = statusBarViewController {
            sbvc.loadView()
            sbvc.statusItem = appStatusItem

            for device in AudioDevice.allDevices() {
                sbvc.addDevice(device: device)
            }
        }

        // Set NSUserNotificationCenter delegate to self
        NSUserNotificationCenter.default.delegate = self
    }

    func applicationWillTerminate(_ notification: Notification) {

        // Unsubscribe from events
        NotificationCenter.defaultCenter.unsubscribe(self, eventType: AudioHardwareEvent.self)
        NotificationCenter.defaultCenter.unsubscribe(self, eventType: AudioDeviceEvent.self)
        NotificationCenter.defaultCenter.unsubscribe(self, eventType: AudioStreamEvent.self)

        UserDefaults.standard.synchronize()
    }
}

extension AppDelegate: NSUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {

        return true
    }
}

// MARK: - AMEventSubscriber Protocol Implementation

extension AppDelegate : EventSubscriber {

    func eventReceiver(_ event: Event) {

        let dispatcher = UserNotificationDispatcher.sharedDispatcher

        switch event {
        case let event as AudioDeviceEvent:

            switch event {
            case .nominalSampleRateDidChange(let audioDevice):

                if prefs.notifications.shouldDisplaySampleRateChanges.value {
                    dispatcher.samplerateChangeNotification(audioDevice: audioDevice)
                }

            case .clockSourceDidChange(let audioDevice, let channel, let direction):

                if prefs.notifications.shouldDisplayClockSourceChanges.value {
                    dispatcher.clockSourceChangeNotification(audioDevice: audioDevice,
                                                             channelNumber: channel,
                                                             direction: direction)
                }

            case .volumeDidChange(let audioDevice, _, let direction):

                if prefs.notifications.shouldDisplayVolumeChanges.value {
                    dispatcher.volumeChangeNotification(audioDevice: audioDevice, direction: direction)
                }

            case .muteDidChange(let audioDevice, _, let direction):

                if prefs.notifications.shouldDisplayMuteChanges.value {
                    dispatcher.muteChangeNotification(audioDevice: audioDevice, direction: direction)
                }

            default:

                break

            }
        case let event as AudioHardwareEvent:

            switch event {
            case .deviceListChanged(let addedDevices, let removedDevices):

                if prefs.notifications.shouldDisplayAddedAndRemovedDeviceChanges.value {
                    dispatcher.deviceListChangeNotification(addedDevices: addedDevices, removedDevices: removedDevices)
                }

            case .defaultInputDeviceChanged(let audioDevice):

                if prefs.notifications.shouldDisplayDefaultDeviceChanges.value {
                    dispatcher.defaultInputDeviceChangeNotification(audioDevice: audioDevice)
                }

            case .defaultOutputDeviceChanged(let audioDevice):

                if prefs.notifications.shouldDisplayDefaultDeviceChanges.value {
                    dispatcher.defaultOutputDeviceChangeNotification(audioDevice: audioDevice)
                }

            case .defaultSystemOutputDeviceChanged(let audioDevice):

                if prefs.notifications.shouldDisplayDefaultDeviceChanges.value {
                    dispatcher.defaultSystemOutputDeviceChangeNotification(audioDevice: audioDevice)
                }
            }

        default:

            break

        }
    }
}
