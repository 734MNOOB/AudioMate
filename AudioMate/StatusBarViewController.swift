//
//  StatusBarViewController.swift
//  AudioMate
//
//  Created by Ruben Nine on 22/01/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa
import AMCoreAudio
import Sparkle

private var kPreferencesSeparator = 1000
private var kDeviceMasterInputVolumeLabelMenuItem = 1002
private var kDeviceMasterInputVolumeControlMenuItem = 1003
private var kDeviceMasterOutputVolumeLabelMenuItem = 1004
private var kDeviceMasterOutputVolumeControlMenuItem = 1005

class StatusBarViewController: NSViewController {

    private var audioDevices = [AMAudioDevice]()

    private var sortedAudioDevices: [AMAudioDevice] {
        return audioDevices.sort({ (deviceA, deviceB) -> Bool in
            deviceA.deviceName() < deviceB.deviceName()
        })
    }

    private var mainMenu = NSMenu()

    private lazy var statusBarView: StatusBarView? = {
        return self.view as? StatusBarView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        mainMenu.delegate = self

        let preferencesSeparatorItem = NSMenuItem.separatorItem()
        preferencesSeparatorItem.tag = kPreferencesSeparator

        mainMenu.addItem(preferencesSeparatorItem)

        let preferencesMenuItem = NSMenuItem()

        preferencesMenuItem.title = NSLocalizedString("Preferences…", comment: "")
        preferencesMenuItem.target = self
        preferencesMenuItem.action = #selector(showPreferences(_:))
        preferencesMenuItem.keyEquivalent = ","
        preferencesMenuItem.keyEquivalentModifierMask = Int(NSEventModifierFlags.CommandKeyMask.rawValue)

        mainMenu.addItem(preferencesMenuItem)

        let checkForUpdatesMenuItem = NSMenuItem()

        checkForUpdatesMenuItem.title = NSLocalizedString("Check for Updates…", comment: "")
        checkForUpdatesMenuItem.target = self
        checkForUpdatesMenuItem.action = #selector(checkForUpdates(_:))

        mainMenu.addItem(checkForUpdatesMenuItem)
        mainMenu.addItem(NSMenuItem.separatorItem())

        let quitMenuItem = NSMenuItem()

        quitMenuItem.title = NSLocalizedString("Quit AudioMate", comment: "")
        quitMenuItem.target = NSApp
        quitMenuItem.action = #selector(NSApp.terminate(_:))
        quitMenuItem.keyEquivalent = "q"
        quitMenuItem.keyEquivalentModifierMask = Int(NSEventModifierFlags.CommandKeyMask.rawValue)

        mainMenu.addItem(quitMenuItem)

        statusBarView?.setMainMenu(mainMenu)

        // Subscribe to events
        AMNotificationCenter.defaultCenter.subscribe(self, eventType: AMAudioHardwareEvent.self, dispatchQueue: dispatch_get_main_queue())
        AMNotificationCenter.defaultCenter.subscribe(self, eventType: AMAudioDeviceEvent.self, dispatchQueue: dispatch_get_main_queue())
    }

    deinit {
        // Unsubscribe from events
        AMNotificationCenter.defaultCenter.unsubscribe(self, eventType: AMAudioHardwareEvent.self)
        AMNotificationCenter.defaultCenter.unsubscribe(self, eventType: AMAudioDeviceEvent.self)
    }

    // MARK: - Public Functions

    func addDevice(device: AMAudioDevice) {
        log.debug("Adding \(device) to menu.")

        audioDevices.append(device)

        // Rebuild device menu items if needed
        if sortedAudioDevices != audioDevices {
            rebuildDeviceMenuItems()
            return
        }

        // Create menu item for device with submenu
        let menuItem = NSMenuItem()

        menuItem.attributedTitle = attributedStringForDevice(device)
        menuItem.image = transportTypeImageForDevice(device)
        menuItem.representedObject = device

        buildSubmenuForMenuItem(menuItem)

        // Insert menu item
        let separatorIdx = mainMenu.indexOfItemWithTag(kPreferencesSeparator)

        if separatorIdx != -1 {
            mainMenu.insertItem(menuItem, atIndex: separatorIdx)
        }

        updateMasterVolumeInMenu(device, direction: .Recording)
        updateMasterVolumeInMenu(device, direction: .Playback)

        // Force menu update
        mainMenu.performSelector(#selector(NSMenu.update),
                                 withObject: nil,
                                 afterDelay: 0.15,
                                 inModes: [NSEventTrackingRunLoopMode])
    }

    func removeDevice(device: AMAudioDevice) {
        log.debug("Removing \(device) from menu.")

        // Remove device menu item from menu
        if let deviceMenuItem = deviceMenuItemForDevice(device) {
            mainMenu.removeItem(deviceMenuItem)
        }

        // Remove device from device list
        if let idx = audioDevices.indexOf(device) {
            audioDevices.removeAtIndex(idx)
        }
    }

    // MARK: - Private Functions

    private func deviceMenuItemForDevice(audioDevice: AMAudioDevice) -> NSMenuItem? {
        return mainMenu.itemArray.filter { (menuItem) -> Bool in
            (menuItem.representedObject as? AMAudioDevice) == audioDevice
        }.first
    }

    private func buildVolumeControlMenuItem(item: NSMenuItem, direction: AMCoreAudio.Direction) {
        guard let device = item.representedObject as? AMAudioDevice else {
            return
        }

        if let volumeControlView = (item.view as? VolumeControlView) ?? (instantiateViewFromNibNamed("VolumeControlView") as? VolumeControlView) {
            // Set volume slide ranges
            volumeControlView.volumeSlider.minValue = 0.0
            volumeControlView.volumeSlider.maxValue = 1.0

            // Set input volume slider and mute checkbox values
            if let volume = device.masterVolumeForDirection(direction) {
                let volumeSliderAction = direction == .Playback ? #selector(updateOutputVolume(_:)) : #selector(updateInputVolume(_:))

                volumeControlView.volumeSlider.enabled = true
                volumeControlView.volumeSlider.continuous = true
                volumeControlView.volumeSlider.tag = Int(device.deviceID)
                volumeControlView.volumeSlider.floatValue = volume
                volumeControlView.volumeSlider.target = self
                volumeControlView.volumeSlider.action = volumeSliderAction

                let volumeMuteAction = direction == .Playback ? #selector(updateOutputMute(_:)) : #selector(updateInputMute(_:))

                volumeControlView.muteCheckbox.enabled = true
                volumeControlView.muteCheckbox.state = device.isMasterVolumeMutedForDirection(direction) ?? false ? NSOnState : NSOffState
                volumeControlView.muteCheckbox.tag = Int(device.deviceID)
                volumeControlView.muteCheckbox.target = self
                volumeControlView.muteCheckbox.action = volumeMuteAction
            } else {
                volumeControlView.volumeSlider.enabled = false
                volumeControlView.volumeSlider.floatValue = 1.0
                volumeControlView.muteCheckbox.enabled = false
                volumeControlView.muteCheckbox.state = NSOffState
            }

            item.view = volumeControlView
        }
    }

    @objc private func buildSubmenuForMenuItem(item: NSMenuItem) {
        guard let device = item.representedObject as? AMAudioDevice else {
            return
        }

        // Create submenu
        item.submenu = NSMenu()
        item.submenu?.autoenablesItems = false

        // Create `Set sample rate` item and submenu
        let sampleRateItem = NSMenuItem(title: NSLocalizedString("Set sample rate", comment: ""),
                                        action: nil,
                                        keyEquivalent: "")

        sampleRateItem.submenu = NSMenu()
        sampleRateItem.submenu?.autoenablesItems = false

        if let sampleRates = device.nominalSampleRates() {
            for sampleRate in sampleRates {
                let item = NSMenuItem(title: FormattingUtils.formatSampleRate(sampleRate),
                                      action: #selector(updateSampleRate(_:)),
                                      keyEquivalent: "")

                item.enabled = device.nominalSampleRate() != sampleRate
                item.state = !item.enabled ? NSOnState : NSOffState
                item.tag = Int(device.deviceID)
                item.representedObject = sampleRate
                item.target = self

                sampleRateItem.submenu?.addItem(item)
            }
        }

        item.submenu?.addItem(sampleRateItem)

        // Create `Set clock source` item and submenu
        let clockSourceItem = NSMenuItem(title: NSLocalizedString("Set clock source", comment: ""),
                                         action: nil,
                                         keyEquivalent: "")

        clockSourceItem.submenu = NSMenu()
        clockSourceItem.submenu?.autoenablesItems = false

        if let clockSourceIDs = device.clockSourceIDsForChannel(0, andDirection: .Playback) {
            let activeClockSourceID = device.clockSourceIDForChannel(0, andDirection: .Playback)

            for clockSourceID in clockSourceIDs {
                if let clockSourceName = device.clockSourceNameForClockSourceID(clockSourceID,
                                                                                forChannel: 0,
                                                                                andDirection: .Playback) {
                    let item = NSMenuItem(title: clockSourceName,
                                          action: #selector(updateClockSource(_:)),
                                          keyEquivalent: "")

                    item.enabled = clockSourceID != activeClockSourceID
                    item.state = !item.enabled ? NSOnState : NSOffState
                    item.tag = Int(device.deviceID)
                    item.representedObject = UInt(clockSourceID)
                    item.target = self

                    clockSourceItem.submenu?.addItem(item)
                }
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
            let useForSoundOutputItem = NSMenuItem(title: NSLocalizedString("Use this device for sound output", comment: ""),
                                                   action: #selector(updateDefaultOutputDevice(_:)),
                                                   keyEquivalent: "")

            useForSoundOutputItem.image = NSImage(named: "DefaultOutput")
            useForSoundOutputItem.target = self

            if AMAudioDevice.defaultOutputDevice()?.deviceID == device.deviceID {
                useForSoundOutputItem.enabled = false
                useForSoundOutputItem.state = NSOnState
            } else {
                useForSoundOutputItem.tag = Int(device.deviceID)
            }

            item.submenu?.addItem(useForSoundOutputItem)

            let useForSystemOutputItem = NSMenuItem(title: NSLocalizedString("Play alerts and sound effects through this device", comment: ""),
                                                    action: #selector(updateDefaultSystemOutputDevice(_:)),
                                                    keyEquivalent: "")

            useForSystemOutputItem.image = NSImage(named: "SystemOutput")
            useForSystemOutputItem.target = self

            if AMAudioDevice.defaultSystemOutputDevice()?.deviceID == device.deviceID {
                useForSystemOutputItem.enabled = false
                useForSystemOutputItem.state = NSOnState
            } else {
                useForSystemOutputItem.tag = Int(device.deviceID)
            }

            item.submenu?.addItem(useForSystemOutputItem)
        } else if device.channelsForDirection(.Recording) > 0 {
            let useForSoundInputItem = NSMenuItem(title: NSLocalizedString("Use this device for sound input", comment: ""),
                                                  action: #selector(updateDefaultInputDevice(_:)),
                                                  keyEquivalent: "")

            useForSoundInputItem.image = NSImage(named: "DefaultInput")
            useForSoundInputItem.target = self

            if AMAudioDevice.defaultInputDevice()?.deviceID == device.deviceID {
                useForSoundInputItem.enabled = false
                useForSoundInputItem.state = NSOnState
            } else {
                useForSoundInputItem.tag = Int(device.deviceID)
            }

            item.submenu?.addItem(useForSoundInputItem)
        }

        // Add separator item
        item.submenu?.addItem(NSMenuItem.separatorItem())

        let masterInputVolumeLabelItem = NSMenuItem()
        masterInputVolumeLabelItem.enabled = false
        masterInputVolumeLabelItem.tag = kDeviceMasterInputVolumeLabelMenuItem

        item.submenu?.addItem(masterInputVolumeLabelItem)

        // Create master input volume control menu item
        let inputVolumeControlMenuItem = NSMenuItem()
        inputVolumeControlMenuItem.representedObject = device
        inputVolumeControlMenuItem.tag = kDeviceMasterInputVolumeControlMenuItem

        buildVolumeControlMenuItem(inputVolumeControlMenuItem, direction: .Recording)
        item.submenu?.addItem(inputVolumeControlMenuItem)

        let masterOutputVolumeLabelItem = NSMenuItem()
        masterOutputVolumeLabelItem.enabled = false
        masterOutputVolumeLabelItem.tag = kDeviceMasterOutputVolumeLabelMenuItem

        item.submenu?.addItem(masterOutputVolumeLabelItem)

        // Create master input volume control menu item
        let outputVolumeControlMenuItem = NSMenuItem()
        outputVolumeControlMenuItem.representedObject = device
        outputVolumeControlMenuItem.tag = kDeviceMasterOutputVolumeControlMenuItem

        buildVolumeControlMenuItem(outputVolumeControlMenuItem, direction: .Playback)
        item.submenu?.addItem(outputVolumeControlMenuItem)

        // Add separator item
        item.submenu?.addItem(NSMenuItem.separatorItem())

        // Add `Configure Actions…` item
        let configureActionsMenuItem = NSMenuItem()

        configureActionsMenuItem.title = NSLocalizedString("Configure actions…", comment: "")
        configureActionsMenuItem.target = self
        configureActionsMenuItem.action = #selector(showDeviceActions(_:))

        item.submenu?.addItem(configureActionsMenuItem)
    }

    private func updateMasterVolumeInMenu(device: AMAudioDevice, direction: Direction) {
        if let menuItem = deviceMenuItemForDevice(device) {
            let menuItemLabelTag: Int
            let menuItemControlTag: Int

            switch direction {
            case .Recording:
                menuItemLabelTag = kDeviceMasterInputVolumeLabelMenuItem
                menuItemControlTag = kDeviceMasterInputVolumeControlMenuItem
            case .Playback:
                menuItemLabelTag = kDeviceMasterOutputVolumeLabelMenuItem
                menuItemControlTag = kDeviceMasterOutputVolumeControlMenuItem
            default:
                menuItemLabelTag = 0
                menuItemControlTag = 0
            }

            if let volumeMenuItem = menuItem.submenu?.itemWithTag(menuItemLabelTag) {
                let formatString: String
                let dBValue = device.masterVolumeInDecibelsForDirection(direction) ?? 0.0

                switch direction {
                case .Recording:
                    formatString = NSLocalizedString("Master Input Volume is %.1fdBfs", comment: "")
                case .Playback:
                    formatString = NSLocalizedString("Master Output Volume is %.1fdBfs", comment: "")
                default:
                    formatString = "%.1fdBfs"
                }

                volumeMenuItem.title = String(format: formatString, dBValue)
            }

            if let volumeControlMenuItem = menuItem.submenu?.itemWithTag(menuItemControlTag),
                   view = volumeControlMenuItem.view as? VolumeControlView,
                   volume = device.masterVolumeForDirection(direction) {
                view.volumeSlider.floatValue = volume
                view.muteCheckbox.state = (device.isChannelMuted(0, andDirection: direction) ?? false) ? NSOnState : NSOffState
            }
        }
    }

    private func attributedStringForDevice(device: AMAudioDevice) -> NSAttributedString {
        let font = NSFont.menuBarFontOfSize(14.0)
        let attrs = [NSFontAttributeName: font]
        let attrString = NSMutableAttributedString(string: device.deviceName(), attributes: attrs)

        // Formatted sample rate and clock source
        let formattedSampleRate = FormattingUtils.formatSampleRate(device.nominalSampleRate() ?? 0)
        let formattedClockSource = device.clockSourceForChannel(0, andDirection: .Playback) ?? "Internal Clock"

        // Formatted input and output channels
        let inChannels = device.channelsForDirection(.Recording) ?? 0
        let outChannels = device.channelsForDirection(.Playback) ?? 0

        let formatedInputChannels = String(format:inChannels == 1 ? NSLocalizedString("%d in", comment: "") : NSLocalizedString("%d ins", comment: ""), inChannels)
        let formatedOutputChannels = String(format:outChannels == 1 ? NSLocalizedString("%d out", comment: "") : NSLocalizedString("%d outs", comment: ""), outChannels)

        let font2 = NSFont.menuFontOfSize(NSFont.labelFontSize())
        let attrs2 = [NSFontAttributeName: font2, NSForegroundColorAttributeName: NSColor.secondaryLabelColor()]
        let attrStringLine2 = NSMutableAttributedString(string: "\n\(formattedSampleRate) / \(formattedClockSource)\n\(formatedInputChannels) / \(formatedOutputChannels)", attributes: attrs2)

        attrString.appendAttributedString(attrStringLine2)

        return attrString.copy() as! NSAttributedString
    }

    private func rebuildDeviceMenuItems() {
        log.debug("Rebuilding devices in menu...")

        let sortedDevices = sortedAudioDevices

        audioDevices.forEach({ (audioDevice) in
            removeDevice(audioDevice)
        })

        sortedDevices.forEach({ (device) in
            addDevice(device)
        })
    }

    private func updateDeviceMenuItem(device: AMAudioDevice) {
        if let menuItem = deviceMenuItemForDevice(device) {
            menuItem.title = device.deviceName()
            menuItem.image = transportTypeImageForDevice(device)

            buildSubmenuForMenuItem(menuItem)
        }
    }
    
    private func updateDeviceMenuItems() {
        audioDevices.forEach { (device) in
            updateDeviceMenuItem(device)
        }
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

    private func transportTypeImageForDevice(device: AMAudioDevice) -> NSImage {
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

    @IBAction func checkForUpdates(sender: AnyObject) {
        Utils.transformAppIntoForegroundMode()
        // Activate (give focus to) our app
        NSApplication.sharedApplication().activateIgnoringOtherApps(true)

        SUUpdater.sharedUpdater().delegate = self
        SUUpdater.sharedUpdater().checkForUpdates(sender)
    }

    @IBAction func showPreferences(sender: AnyObject) {
        performSegueWithIdentifier("showPreferences", sender: self)
    }

    @IBAction func showDeviceActions(sender: AnyObject) {
        log.debug("TODO: Implement")
    }

    @IBAction func updateInputVolume(sender: AnyObject) {
        if let slider = sender as? NSSlider {
            let device = AMAudioDevice.lookupByID(AudioObjectID(slider.tag))
            device.setMasterVolume(slider.floatValue, forDirection: .Recording)
        }
    }

    @IBAction func updateOutputVolume(sender: AnyObject) {
        if let slider = sender as? NSSlider {
            let device = AMAudioDevice.lookupByID(AudioObjectID(slider.tag))
            device.setMasterVolume(slider.floatValue, forDirection: .Playback)
        }
    }

    @IBAction func updateInputMute(sender: AnyObject) {
        if let button = sender as? NSButton {
            let device = AMAudioDevice.lookupByID(AudioObjectID(button.tag))

            device.setMute(button.state == NSOnState,
                           forChannel: kAudioObjectPropertyElementMaster,
                           andDirection: .Recording)
        }
    }

    @IBAction func updateOutputMute(sender: AnyObject) {
        if let button = sender as? NSButton {
            let device = AMAudioDevice.lookupByID(AudioObjectID(button.tag))

            device.setMute(button.state == NSOnState,
                           forChannel: kAudioObjectPropertyElementMaster,
                           andDirection: .Playback)
        }
    }

    @IBAction func updateSampleRate(sender: AnyObject) {
        if let menuItem = sender as? NSMenuItem {
            let device = AMAudioDevice.lookupByID(AudioObjectID(menuItem.tag))

            if let sampleRate = menuItem.representedObject as? Float64 {
                device.setNominalSampleRate(sampleRate)
            }
        }
    }

    @IBAction func updateClockSource(sender: AnyObject) {
        if let menuItem = sender as? NSMenuItem {
            let device = AMAudioDevice.lookupByID(AudioObjectID(menuItem.tag))

            if let clockSourceID = menuItem.representedObject as? UInt {
                device.setClockSourceID(UInt32(clockSourceID),
                                        forChannel: kAudioObjectPropertyElementMaster,
                                        andDirection: .Playback)
            }
        }
    }

    @IBAction func updateDefaultInputDevice(sender: AnyObject) {
        if let menuItem = sender as? NSMenuItem {
            let device = AMAudioDevice.lookupByID(AudioObjectID(menuItem.tag))
            device.setAsDefaultInputDevice()
        }
    }

    @IBAction func updateDefaultOutputDevice(sender: AnyObject) {
        if let menuItem = sender as? NSMenuItem {
            let device = AMAudioDevice.lookupByID(AudioObjectID(menuItem.tag))
            device.setAsDefaultOutputDevice()
        }
    }

    @IBAction func updateDefaultSystemOutputDevice(sender: AnyObject) {
        if let menuItem = sender as? NSMenuItem {
            let device = AMAudioDevice.lookupByID(AudioObjectID(menuItem.tag))
            device.setAsDefaultSystemDevice()
        }
    }
}

extension StatusBarViewController: NSMenuDelegate {
    func menuDidClose(menu: NSMenu) {
        statusBarView?.controlIsHighlighted = false
    }
}

// MARK: - AMEventSubscriber Protocol Implementation
extension StatusBarViewController : AMEventSubscriber {

    func eventReceiver(event: AMEvent) {
        switch event {
        case let event as AMAudioDeviceEvent:
            switch event {
            case .NominalSampleRateDidChange(let audioDevice):
                updateDeviceMenuItem(audioDevice)
            case .AvailableNominalSampleRatesDidChange(let audioDevice):
                updateDeviceMenuItem(audioDevice)
            case .ClockSourceDidChange(let audioDevice, _, _):
                updateDeviceMenuItem(audioDevice)
            case .NameDidChange(let audioDevice):
                updateDeviceMenuItem(audioDevice)
            case .ListDidChange(let audioDevice):
                updateDeviceMenuItem(audioDevice)
            case .VolumeDidChange(let audioDevice, _, let direction):
                updateMasterVolumeInMenu(audioDevice, direction: direction)
            case .MuteDidChange(let audioDevice, _, let direction):
                updateMasterVolumeInMenu(audioDevice, direction: direction)
            default:
                break
            }
        case let event as AMAudioHardwareEvent:
            switch event {
            case .DeviceListChanged(let addedDevices, let removedDevices):
                for removedDevice in removedDevices {
                    removeDevice(removedDevice)
                }

                for addedDevice in addedDevices {
                    addDevice(addedDevice)
                }
            case .DefaultInputDeviceChanged(_):
                updateDeviceMenuItems()
            case .DefaultOutputDeviceChanged(_):
                updateDeviceMenuItems()
            case .DefaultSystemOutputDeviceChanged(_):
                updateDeviceMenuItems()
            }
        default:
            break
        }
    }
}

extension StatusBarViewController: SUUpdaterDelegate {
    func updaterDidShowModalAlert(updater: SUUpdater!) {
        Utils.transformAppIntoUIElementMode()
    }
}
