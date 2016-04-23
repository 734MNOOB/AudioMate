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

    // Instantiate our audio hardware object
    private let audioHardware = AMAudioHardware.sharedInstance

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        audioHardware.enableDeviceMonitoring()

        // Subscribe to events
        AMNotificationCenter.defaultCenter.subscribe(self, eventType: AMAudioHardwareEvent.self, dispatchQueue: dispatch_get_main_queue())
        AMNotificationCenter.defaultCenter.subscribe(self, eventType: AMAudioDeviceEvent.self, dispatchQueue: dispatch_get_main_queue())
        AMNotificationCenter.defaultCenter.subscribe(self, eventType: AMAudioStreamEvent.self, dispatchQueue: dispatch_get_main_queue())

        // Setup logger
        setupLogger()

        // Instantiate StatusBarViewController and add all known devices in the system
        if let sbvc = statusBarViewController {
            sbvc.loadView()

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
        switch event {
        case let event as AMAudioDeviceEvent:
            switch event {
            case .NominalSampleRateDidChange(let audioDevice):
                EventNotifier.sharedEventNotifier.samplerateChangeNotification(audioDevice)
            case .AvailableNominalSampleRatesDidChange(let audioDevice):
                if let nominalSampleRates = audioDevice.nominalSampleRates() {
                    log.debug("\(audioDevice) nominal sample rates changed to \(nominalSampleRates)")
                }
            case .ClockSourceDidChange(let audioDevice, let channel, let direction):
                EventNotifier.sharedEventNotifier.clockSourceChangeNotification(audioDevice,
                                                                                channelNumber: channel,
                                                                                direction: direction)
            case .NameDidChange(let audioDevice):
                log.debug("\(audioDevice) name changed to \(audioDevice.deviceName())")
            case .ListDidChange(let audioDevice):
                log.debug("\(audioDevice) owned devices list changed")
            case .VolumeDidChange(let audioDevice, _, let direction):
                EventNotifier.sharedEventNotifier.volumeChangeNotification(audioDevice, direction: direction)
            case .MuteDidChange(let audioDevice, _, let direction):
                EventNotifier.sharedEventNotifier.muteChangeNotification(audioDevice, direction: direction)
            default:
                break
            }
        case let event as AMAudioHardwareEvent:
            switch event {
            case .DeviceListChanged(let addedDevices, let removedDevices):
                EventNotifier.sharedEventNotifier.deviceListChangeNotification(addedDevices, removedDevices: removedDevices)
            case .DefaultInputDeviceChanged(let audioDevice):
                EventNotifier.sharedEventNotifier.defaultInputDeviceChangeNotification(audioDevice)
            case .DefaultOutputDeviceChanged(let audioDevice):
                EventNotifier.sharedEventNotifier.defaultOutputDeviceChangeNotification(audioDevice)
            case .DefaultSystemOutputDeviceChanged(let audioDevice):
                EventNotifier.sharedEventNotifier.defaultSystemOutputDeviceChangeNotification(audioDevice)
            }
        case let event as AMAudioStreamEvent:
            switch event {
            case .PhysicalFormatDidChange(let audioStream):
                log.debug("physical format did change in \(audioStream.streamID), owner: \(audioStream.owningDevice), format: \(audioStream.physicalFormat)")
            default:
                break
            }
        default:
            break
        }
    }
}
