//
//  AppDelegate.swift
//  AudioMate
//
//  Created by Ruben Nine on 18/01/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa
import AMCoreAudio

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private let statusBarViewController: StatusBarViewController? = {
        let mainStoryboard = NSStoryboard(name: "Main", bundle: nil)
        return mainStoryboard.instantiateControllerWithIdentifier("statusBarViewController") as? StatusBarViewController
    }()

    private let audioManager = AMCoreAudioManager.sharedManager
    private var previousActiveApplication: NSRunningApplication?

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        if let sbvc = statusBarViewController {
            sbvc.loadView()

            for device in audioManager.allKnownDevices {
                sbvc.addDevice(device)
            }
        }

        // Set CoreAudioManager delegate to self
        audioManager.delegate = self

        // Set NSUserNotificationCenter delegate to self
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self

        // Subscribe to some NSWorkspace notifications
        NSWorkspace.sharedWorkspace().notificationCenter.addObserver(self,
            selector: #selector(AppDelegate.applicationDidActivate(_:)),
            name: NSWorkspaceDidActivateApplicationNotification,
            object: nil
        )

        // Subscribe to application did deactivate notificaiton
        NSWorkspace.sharedWorkspace().notificationCenter.addObserver(self,
            selector: #selector(AppDelegate.applicationDidDeactivate(_:)),
            name: NSWorkspaceDidDeactivateApplicationNotification,
            object: nil
        )
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application

        audioManager.delegate = nil

        NSWorkspace.sharedWorkspace().notificationCenter.removeObserver(self)
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    @objc func applicationDidActivate(notification: NSNotification) {
        // We want to ensure that saveOriginalActiveApplication:
        // initializes previouslyActiveApplication
        // before saveActiveApplication: does, so we return
        // until previouslyActiveApplication
        // is initialized by saveOriginalActiveApplication:

        if previousActiveApplication == nil {
            return
        }

        if NSRunningApplication.currentApplication().active {
            if let activeApplication = notification.userInfo?[NSWorkspaceApplicationKey] as? NSRunningApplication {
                previousActiveApplication = activeApplication
            }
        }
    }

    @objc func applicationDidDeactivate(notification: NSNotification) {
        // This method will be called exactly once when
        // NSWorkspaceDidDeactivateApplicationNotification is fired
        // so we have the chance to capture the original active app when the app launched

        // Remove observer (we only want this method to fire once)
        NSWorkspace.sharedWorkspace().notificationCenter.removeObserver(self,
            name: NSWorkspaceDidDeactivateApplicationNotification,
            object: nil
        )

        // Update previous active application
        self.previousActiveApplication = notification.userInfo?[NSWorkspaceApplicationKey] as? NSRunningApplication
    }
}

extension AppDelegate: NSUserNotificationCenterDelegate {

    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
}

extension AppDelegate: AMCoreAudioManagerDelegate {

    func hardwareDeviceListChangedWithAddedDevices(addedDevices: [AMCoreAudioDevice], andRemovedDevices removedDevices: [AMCoreAudioDevice]) {
        EventNotifier.sharedEventNotifier.deviceListChangeNotification(addedDevices, removedDevices: removedDevices)

        for addedDevice in addedDevices {
            statusBarViewController?.addDevice(addedDevice)
        }

        for removedDevice in removedDevices {
            statusBarViewController?.removeDevice(removedDevice)
        }
    }

    func hardwareDefaultInputDeviceChanged(audioDevice: AMCoreAudioDevice) {
        //
    }

    func hardwareDefaultOutputDeviceChanged(audioDevice: AMCoreAudioDevice) {
        //
    }

    func hardwareDefaultSystemDeviceChanged(audioDevice: AMCoreAudioDevice) {
        //
    }

    func audioDeviceListDidChange(audioDevice: AMCoreAudioDevice) {
        //
    }

    func audioDeviceNameDidChange(audioDevice: AMCoreAudioDevice) {
        //
    }

    func audioDeviceNominalSampleRateDidChange(audioDevice: AMCoreAudioDevice) {
        EventNotifier.sharedEventNotifier.samplerateChangeNotification(audioDevice)
    }

    func audioDeviceClockSourceDidChange(audioDevice: AMCoreAudioDevice, forChannel channel: UInt32, andDirection direction: Direction) {
        EventNotifier.sharedEventNotifier.clockSourceChangeNotification(audioDevice, channelNumber: channel, direction: direction)
    }

    func audioDeviceVolumeDidChange(audioDevice: AMCoreAudioDevice, forChannel channel: UInt32, andDirection direction: Direction) {
        EventNotifier.sharedEventNotifier.volumeChangeNotification(audioDevice, direction: direction)
    }

    func audioDeviceMuteDidChange(audioDevice: AMCoreAudioDevice, forChannel channel: UInt32, andDirection direction: Direction) {
        EventNotifier.sharedEventNotifier.muteChangeNotification(audioDevice, direction: direction)
    }

    func audioDeviceIsAliveDidChange(audioDevice: AMCoreAudioDevice) {
        // NO-OP
    }
}
