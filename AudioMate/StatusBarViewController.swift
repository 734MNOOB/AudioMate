//
//  StatusBarViewController.swift
//  AudioMate
//
//  Created by Ruben Nine on 22/01/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa
import AMCoreAudio

class StatusBarViewController: NSViewController {

    private var audioDevices = [AMCoreAudioDevice]()
    private var mainMenu = NSMenu()

    private lazy var statusBarView: StatusBarView? = {
        return self.view as? StatusBarView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        mainMenu.delegate = self

        mainMenu.addItem(NSMenuItem.separatorItem())

        let preferencesMenuItem = NSMenuItem()

        preferencesMenuItem.title = NSLocalizedString("Preferences…", comment: "")
        preferencesMenuItem.target = self
        preferencesMenuItem.action = #selector(foo(_:))
        preferencesMenuItem.keyEquivalent = ","
        preferencesMenuItem.keyEquivalentModifierMask = Int(NSEventModifierFlags.CommandKeyMask.rawValue)

        mainMenu.addItem(preferencesMenuItem)

        mainMenu.addItem(NSMenuItem.separatorItem())

        let quitMenuItem = NSMenuItem()

        quitMenuItem.title = NSLocalizedString("Quit AudioMate", comment: "")
        quitMenuItem.target = NSApp
        quitMenuItem.action = #selector(NSApp.terminate(_:))
        quitMenuItem.keyEquivalent = "q"
        quitMenuItem.keyEquivalentModifierMask = Int(NSEventModifierFlags.CommandKeyMask.rawValue)

        mainMenu.addItem(quitMenuItem)

        statusBarView?.setMainMenu(mainMenu)
    }

    // MARK: - Public Functions

    func addDevice(device: AMCoreAudioDevice) {
        log.debug("Adding \(device) to menu.")

        audioDevices.append(device)

        // Create menu item for device with submenu
        let menuItem = NSMenuItem()
        menuItem.title = device.deviceName()
        menuItem.image = transportTypeImageForDevice(device)
        menuItem.representedObject = device
        menuItem.tag = Int(device.deviceID)

        buildSubmenuForMenuItem(menuItem)

        // Create detail menu item for device
        let detailMenuItem = NSMenuItem()
        detailMenuItem.representedObject = device

        buildDeviceDetailMenuItem(detailMenuItem)

        // Insert both the menu item and the detail menu item in the menu
        mainMenu.insertItem(detailMenuItem, atIndex: 0)
        mainMenu.insertItem(menuItem, atIndex: 0)
    }

    func removeDevice(device: AMCoreAudioDevice) {
        log.debug("Removing \(device) from menu.")

        if let idx = audioDevices.indexOf(device) {
            audioDevices.removeAtIndex(idx)
        }

        let itemIdx = mainMenu.indexOfItemWithTag(Int(device.deviceID))

        if itemIdx != -1 {
            mainMenu.removeItemAtIndex(itemIdx)

            let detailIdx = mainMenu.indexOfItemWithRepresentedObject(device)

            if detailIdx != -1 {
                mainMenu.removeItemAtIndex(detailIdx)
            }
        }
    }

    // MARK: - Private Functions

    private func buildDeviceDetailMenuItem(item: NSMenuItem) {
        guard let device = item.representedObject as? AMCoreAudioDevice else {
            return
        }

        if let menuItemView: MenuItemView = instantiateViewFromNibNamed("MenuItemView") as? MenuItemView {
            // Set sample rate
            menuItemView.sampleRate = device.nominalSampleRate() ?? 0

            // Set clock source
            let clockSource = device.clockSourceForChannel(0, andDirection: .Playback)
            menuItemView.clockSource = clockSource ?? NSLocalizedString("Internal Clock", comment: "")

            // Set input and output channel count
            let outChannels = device.channelsForDirection(.Playback) ?? 0
            let inChannels = device.channelsForDirection(.Recording) ?? 0

            menuItemView.inputChannels = String(format:inChannels == 1 ? NSLocalizedString("%d in", comment: "") : NSLocalizedString("%d ins", comment: ""), inChannels)
            menuItemView.outputChannels = String(format:outChannels == 1 ? NSLocalizedString("%d out", comment: "") : NSLocalizedString("%d outs", comment: ""), outChannels)

            // Set volume slide ranges
            menuItemView.inputVolumeSlider.minValue = 0.0
            menuItemView.inputVolumeSlider.maxValue = 1.0
            menuItemView.outputVolumeSlider.minValue = 0.0
            menuItemView.outputVolumeSlider.maxValue = 1.0

            // Set input volume slider and mute checkbox values
            if let inVolume = device.masterVolumeForDirection(.Recording) {
                menuItemView.inputVolumeSlider.floatValue = inVolume
                menuItemView.inputVolumeSlider.enabled = true
                menuItemView.inputMuteCheckbox.enabled = true

                menuItemView.inputMuteCheckbox.state = device.isMasterVolumeMutedForDirection(.Recording) ?? false ? NSOnState : NSOffState
            } else {
                menuItemView.inputVolumeSlider.floatValue = 1.0
                menuItemView.inputVolumeSlider.enabled = false
                menuItemView.inputMuteCheckbox.enabled = false
                menuItemView.inputMuteCheckbox.state = NSOffState
            }

            // Set output volume slider and mute checkbox values
            if let outVolume = device.masterVolumeForDirection(.Playback) {
                menuItemView.outputVolumeSlider.floatValue = outVolume
                menuItemView.outputVolumeSlider.enabled = true
                menuItemView.outputMuteCheckbox.enabled = true

                menuItemView.outputMuteCheckbox.state = device.isMasterVolumeMutedForDirection(.Playback) ?? false ? NSOnState : NSOffState
            } else {
                menuItemView.outputVolumeSlider.floatValue = 1.0
                menuItemView.outputVolumeSlider.enabled = false
                menuItemView.outputMuteCheckbox.enabled = false
                menuItemView.outputMuteCheckbox.state = NSOffState
            }

            menuItemView.displayOutputDeviceIcon = AMCoreAudioDevice.defaultOutputDevice()?.deviceID == device.deviceID
            menuItemView.displayInputDeviceIcon = AMCoreAudioDevice.defaultInputDevice()?.deviceID == device.deviceID
            menuItemView.displaySystemOuputDeviceIcon = AMCoreAudioDevice.defaultSystemOutputDevice()?.deviceID == device.deviceID

            item.view = menuItemView
        } else {
            item.title = device.deviceName()
        }
    }

    private func buildSubmenuForMenuItem(item: NSMenuItem) {
        guard let device = item.representedObject as? AMCoreAudioDevice else {
            return
        }

        // Create submenu
        item.submenu = NSMenu()
        item.submenu?.autoenablesItems = false

        // Create `Set sample rate` item and submenu
        let sampleRateItem = NSMenuItem(title: NSLocalizedString("Set sample rate", comment: ""), action: #selector(foo(_:)), keyEquivalent: "")

        sampleRateItem.submenu = NSMenu()
        sampleRateItem.submenu?.autoenablesItems = false

        for sampleRate in device.nominalSampleRates()! {
            let item = NSMenuItem(title: FormattingUtils.formatSampleRate(sampleRate), action: #selector(foo(_:)), keyEquivalent: "")
            item.enabled = device.nominalSampleRate() != sampleRate
            item.state = !item.enabled ? NSOnState : NSOffState
            sampleRateItem.submenu?.addItem(item)
        }

        item.submenu?.addItem(sampleRateItem)

        // Create `Set clock source` item and submenu
        let clockSourceItem = NSMenuItem(title: NSLocalizedString("Set clock source", comment: ""), action: #selector(foo(_:)), keyEquivalent: "")

        clockSourceItem.submenu = NSMenu()
        clockSourceItem.submenu?.autoenablesItems = false

        if let clockSources = device.clockSourcesForChannel(0, andDirection: .Playback) {
            let activeClockSource = device.clockSourceForChannel(0, andDirection: .Playback)

            for clockSource in clockSources {
                let item = NSMenuItem(title: "\(clockSource)", action: #selector(foo(_:)), keyEquivalent: "")

                item.enabled = clockSource != activeClockSource
                item.state = !item.enabled ? NSOnState : NSOffState
                clockSourceItem.submenu?.addItem(item)
            }
        } else {
            let internalClockItem = NSMenuItem(title: NSLocalizedString("Internal Clock", comment: ""), action: nil, keyEquivalent: "")
            internalClockItem.enabled = false
            clockSourceItem.submenu?.addItem(internalClockItem)
        }

        item.submenu?.addItem(clockSourceItem)

        // Add separator item
        item.submenu?.addItem(NSMenuItem.separatorItem())

        // Add menu items that allow changing the default output, system output, and input device.
        // Only the options that make sense for each device are added here.
        if device.channelsForDirection(.Playback) > 0 {
            let useForSoundOutputItem = NSMenuItem(title: NSLocalizedString("Use this device for sound output", comment: ""), action: #selector(foo(_:)), keyEquivalent: "")

            useForSoundOutputItem.image = NSImage(named: "DefaultOutput")

            if AMCoreAudioDevice.defaultOutputDevice()?.deviceID == device.deviceID {
                useForSoundOutputItem.enabled = false
                useForSoundOutputItem.state = NSOnState
            }

            item.submenu?.addItem(useForSoundOutputItem)

            let useForSystemOutputItem = NSMenuItem(title: NSLocalizedString("Play alerts and sound effects through this device", comment: ""), action: #selector(foo(_:)), keyEquivalent: "")

            useForSystemOutputItem.image = NSImage(named: "SystemOutput")

            if AMCoreAudioDevice.defaultSystemOutputDevice()?.deviceID == device.deviceID {
                useForSystemOutputItem.enabled = false
                useForSystemOutputItem.state = NSOnState
            }

            item.submenu?.addItem(useForSystemOutputItem)
        } else if device.channelsForDirection(.Recording) > 0 {
            let useForSoundInputItem = NSMenuItem(title: NSLocalizedString("Use this device for sound input", comment: ""), action: #selector(foo(_:)), keyEquivalent: "")

            useForSoundInputItem.image = NSImage(named: "DefaultInput")

            if AMCoreAudioDevice.defaultInputDevice()?.deviceID == device.deviceID {
                useForSoundInputItem.enabled = false
                useForSoundInputItem.state = NSOnState
            }

            item.submenu?.addItem(useForSoundInputItem)
        }

        // Add separator item
        item.submenu?.addItem(NSMenuItem.separatorItem())

        // Add `Configure Actions…` item
        item.submenu?.addItem(NSMenuItem(title: NSLocalizedString("Configure actions…", comment: ""), action: #selector(foo(_:)), keyEquivalent: ""))
    }

    private func instantiateViewFromNibNamed(nibName: String) -> NSView? {
        var topLevelObjects: NSArray?
        NSBundle.mainBundle().loadNibNamed(nibName, owner: self, topLevelObjects: &topLevelObjects)

        if let topLevelObjects = topLevelObjects {
            for object in topLevelObjects {
                if let view = object as? NSView {
                    return view
                }
            }
        }

        return nil
    }

    private func transportTypeImageForDevice(device: AMCoreAudioDevice) -> NSImage {
        if let transportType = device.transportType() {
            let outChannels = device.channelsForDirection(.Playback) ?? 0
            let inChannels = device.channelsForDirection(.Recording) ?? 0

            switch transportType {
            case .BuiltIn:
                if outChannels > 0 && inChannels == 0 {
                    return NSImage(named: "SpeakerIcon")!
                } else if inChannels > 0 && outChannels == 0 {
                    return NSImage(named: "Microphone")!
                } else {
                    return NSImage(named: "Built-in")!
                }
            case .Aggregate:
                return NSImage(named: "Aggregate")!
            case .Virtual:
                return NSImage(named: "Virtual")!
            case .PCI:
                return NSImage(named: "PCI")!
            case .USB:
                return NSImage(named: "USB")!
            case .FireWire:
                return NSImage(named: "FireWire")!
            case .Bluetooth:
                fallthrough
            case .BluetoothLE:
                return NSImage(named: "Bluetooth")!
            case .HDMI:
                return NSImage(named: "HDMI")!
            case .DisplayPort:
                return NSImage(named: "DisplayPort")!
            case .AirPlay:
                return NSImage(named: "Airplay")!
            case .AVB:
                return NSImage(named: "AVBHeader")!
            case .Thunderbolt:
                return NSImage(named: "Thunderbolt")!
            default:
                break
            }
        }

        return NSImage(named: "Unknown")!
    }

    // MARK: - Actions

    @objc func foo(sender: AnyObject) {
        log.debug("TODO: Implement")
    }
}

extension StatusBarViewController: NSMenuDelegate {
    func menuDidClose(menu: NSMenu) {
        statusBarView?.controlIsHighlighted = false
    }
}
