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
let preferences = Preferences.sharedPreferences

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    private let statusBarViewController: StatusBarViewController? = {
        let mainStoryboard = NSStoryboard(name: "Main", bundle: nil)
        return mainStoryboard.instantiateControllerWithIdentifier("statusBarViewController") as? StatusBarViewController
    }()

    // Instantiate our audio hardware object
    private let audioHardware = AMAudioHardware.sharedInstance
    // Instantiate our app status bar item
    private let appStatusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Setup logger
        setupLogger()

        // Log bundle info
        if let buildInfo = BundleInfo.buildInfo() {
            log.info(buildInfo)
        }

        if let amCoreAudioBuildInfo = AMCoreAudio.BundleInfo.buildInfo() {
            log.info("Using \(amCoreAudioBuildInfo)")
        }

        // Upon 1st launch, present a welcome panel
        if preferences.general.isFirstLaunch.value == true {
            log.debug("This is the 1st launch!")
            preferences.general.isFirstLaunch.value = false
        }

        // Enable device monitoring
        audioHardware.enableDeviceMonitoring()

        // Subscribe to events
        AMNotificationCenter.defaultCenter.subscribe(self, eventType: AMAudioHardwareEvent.self, dispatchQueue: dispatch_get_main_queue())
        AMNotificationCenter.defaultCenter.subscribe(self, eventType: AMAudioDeviceEvent.self, dispatchQueue: dispatch_get_main_queue())
        AMNotificationCenter.defaultCenter.subscribe(self, eventType: AMAudioStreamEvent.self, dispatchQueue: dispatch_get_main_queue())

        // Instantiate StatusBarViewController and add all known devices in the system
        if let sbvc = statusBarViewController {
            sbvc.loadView()
            sbvc.statusItem = appStatusItem

            for device in AMAudioDevice.allDevices() {
                sbvc.addDevice(device)
            }
        }

        // Set NSUserNotificationCenter delegate to self
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application

        // Unsubscribe from events
        AMNotificationCenter.defaultCenter.unsubscribe(self, eventType: AMAudioHardwareEvent.self)
        AMNotificationCenter.defaultCenter.unsubscribe(self, eventType: AMAudioDeviceEvent.self)
        AMNotificationCenter.defaultCenter.unsubscribe(self, eventType: AMAudioStreamEvent.self)

        audioHardware.disableDeviceMonitoring()

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

// MARK: - AMEventSubscriber Protocol Implementation
extension AppDelegate : AMEventSubscriber {

    func eventReceiver(event: AMEvent) {
        let dispatcher = UserNotificationDispatcher.sharedDispatcher

        switch event {
        case let event as AMAudioDeviceEvent:
            switch event {
            case .NominalSampleRateDidChange(let audioDevice):
                if preferences.notifications.shouldDisplaySampleRateChanges.value {
                    dispatcher.samplerateChangeNotification(audioDevice)
                }
            case .ClockSourceDidChange(let audioDevice, let channel, let direction):
                if preferences.notifications.shouldDisplayClockSourceChanges.value {
                    dispatcher.clockSourceChangeNotification(audioDevice,
                                                                                    channelNumber: channel,
                                                                                    direction: direction)
                }
            case .VolumeDidChange(let audioDevice, _, let direction):
                if preferences.notifications.shouldDisplayVolumeChanges.value {
                    dispatcher.volumeChangeNotification(audioDevice, direction: direction)
                }
            case .MuteDidChange(let audioDevice, _, let direction):
                if preferences.notifications.shouldDisplayMuteChanges.value {
                    dispatcher.muteChangeNotification(audioDevice, direction: direction)
                }
            default:
                break
            }
        case let event as AMAudioHardwareEvent:
            switch event {
            case .DeviceListChanged(let addedDevices, let removedDevices):
                if preferences.notifications.shouldDisplayAddedAndRemovedDeviceChanges.value {
                    dispatcher.deviceListChangeNotification(addedDevices, removedDevices: removedDevices)
                }
            case .DefaultInputDeviceChanged(let audioDevice):
                if preferences.notifications.shouldDisplayDefaultDeviceChanges.value {
                    dispatcher.defaultInputDeviceChangeNotification(audioDevice)
                }
            case .DefaultOutputDeviceChanged(let audioDevice):
                if preferences.notifications.shouldDisplayDefaultDeviceChanges.value {
                    dispatcher.defaultOutputDeviceChangeNotification(audioDevice)
                }
            case .DefaultSystemOutputDeviceChanged(let audioDevice):
                if preferences.notifications.shouldDisplayDefaultDeviceChanges.value {
                    dispatcher.defaultSystemOutputDeviceChangeNotification(audioDevice)
                }
            }
        default:
            break
        }
    }
}
