//
//  GeneralPreferencesViewController.swift
//  AudioMate
//
//  Created by Ruben Nine on 4/24/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa
import AMCoreAudio

class GeneralPreferencesViewController: NSViewController {

    @IBOutlet var deviceInformationToShowPopUpButton: NSPopUpButton!
    @IBOutlet var startAtLoginButton: NSButton!

    private let startAtLoginController = StartAtLoginController(identifier: "io.9labs.AudioMateLauncher")

    override func viewDidLoad() {

        super.viewDidLoad()
        // Do view setup here.

        let item1 = NSMenuItem()
        item1.title = NSLocalizedString("Sample Rate", comment: "")
        item1.tag = StatusBarViewLayoutType.sampleRate.rawValue

        let item2 = NSMenuItem()
        item2.title = NSLocalizedString("Sample Rate + Clock Source", comment: "")
        item2.tag = StatusBarViewLayoutType.sampleRateAndClockSource.rawValue

        let item3 = NSMenuItem()
        item3.title = NSLocalizedString("Master Volume (Decibels)", comment: "")
        item3.tag = StatusBarViewLayoutType.masterVolumeDecibels.rawValue

        let item4 = NSMenuItem()
        item4.title = NSLocalizedString("Master Volume (Percent)", comment: "")
        item4.tag = StatusBarViewLayoutType.masterVolumePercent.rawValue

        let item5 = NSMenuItem()
        item5.title = NSLocalizedString("Master Volume (Graphic)", comment: "")
        item5.tag = StatusBarViewLayoutType.masterVolumeGraphic.rawValue

        deviceInformationToShowPopUpButton.menu?.addItem(item1)
        deviceInformationToShowPopUpButton.menu?.addItem(item2)
        deviceInformationToShowPopUpButton.menu?.addItem(item3)
        deviceInformationToShowPopUpButton.menu?.addItem(item4)
        deviceInformationToShowPopUpButton.menu?.addItem(item5)

        deviceInformationToShowPopUpButton.target = self
        deviceInformationToShowPopUpButton.action = #selector(updateStatusBarLayoutType(_:))

        deviceInformationToShowPopUpButton.selectItem(withTag: prefs.general.layoutType.value.rawValue)

        if let startAtLoginController = startAtLoginController {
            startAtLoginButton.state = startAtLoginController.startAtLogin ? NSOnState : NSOffState
        }
    }

    @IBAction func toggleStartAtLogin(_ sender: AnyObject) {

        if let startAtLoginController = startAtLoginController {
            startAtLoginController.startAtLogin = startAtLoginButton.state == NSOnState
        }
    }

    @IBAction func updateStatusBarLayoutType(_ sender: AnyObject) {

        if let popupButton = sender as? NSPopUpButton {
            if let tag = popupButton.selectedItem?.tag, let layoutType = StatusBarViewLayoutType(rawValue: tag) {
                prefs.general.layoutType.value = layoutType
            }
        }
    }
}
