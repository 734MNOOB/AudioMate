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

let log = XCGLogger.defaultInstance()

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private let statusBarViewController: StatusBarViewController? = {
        let mainStoryboard = NSStoryboard(name: "Main", bundle: nil)
        return mainStoryboard.instantiateControllerWithIdentifier("statusBarViewController") as? StatusBarViewController
    }()

    private let audioManager = AMCoreAudioManager.sharedManager

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Setup logger
        setupLogger()

        // Instantiate StatusBarViewController and add all known devices in the system
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
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application

        audioManager.delegate = nil
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    // MARK: - Private Functions

    private func setupLogger() {
        #if DEBUG
            log.setup(.Debug,
                      showThreadName: true,
                      showLogLevel: true,
                      showFileNames: true,
                      showLineNumbers: true,
                      writeToFile: nil
            )
        #else
            log.setup(.Warning,
                      showThreadName: true,
                      showLogLevel: true,
                      showFileNames: true,
                      showLineNumbers: true,
                      writeToFile: nil
            )
        #endif

        log.xcodeColors = [
            .Verbose: .darkGrey,
            .Debug: XCGLogger.XcodeColor(fg: (40, 160, 40)),
            .Info: XCGLogger.XcodeColor(fg: (60, 60, 80), bg: (220, 220, 255)),
            .Warning: .orange,
            .Error: .red,
            .Severe: .whiteOnRed
        ]
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
            dispatch_async(dispatch_get_main_queue()) {
                self.statusBarViewController?.addDevice(addedDevice)
            }
        }

        for removedDevice in removedDevices {
            dispatch_async(dispatch_get_main_queue()) {
                self.statusBarViewController?.removeDevice(removedDevice)
            }
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
