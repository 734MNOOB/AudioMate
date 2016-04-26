//
//  GeneralPreferencesViewController.swift
//  AudioMate
//
//  Created by Ruben Nine on 4/24/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa

class GeneralPreferencesViewController: NSViewController {

    @IBOutlet var deviceInformationToShowPopUpButton: NSPopUpButton!
    @IBOutlet var startAtLoginButton: NSButton!

    private let startAtLoginController = StartAtLoginController(identifier: "io.9labs.AudioMateLauncher")

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        let item1 = NSMenuItem()
        item1.title = NSLocalizedString("Sample Rate", comment: "")
        item1.tag = StatusBarViewLayoutType.SampleRate.rawValue

        let item2 = NSMenuItem()
        item2.title = NSLocalizedString("Sample Rate + Master Output Volume", comment: "")
        item2.tag = StatusBarViewLayoutType.SampleRateAndVolume.rawValue

        let item3 = NSMenuItem()
        item3.title = NSLocalizedString("Sample Rate + Master Output Volume Graphic", comment: "")
        item3.tag = StatusBarViewLayoutType.SampleRateAndGraphicVolume.rawValue

        let item4 = NSMenuItem()
        item4.title = NSLocalizedString("Sample Rate + Master Output Volume Percent", comment: "")
        item4.tag = StatusBarViewLayoutType.SampleRateAndPercentVolume.rawValue

        let item5 = NSMenuItem()
        item5.title = NSLocalizedString("Sample Rate + Clock Source", comment: "")
        item5.tag = StatusBarViewLayoutType.SampleRateAndClockSource.rawValue

        deviceInformationToShowPopUpButton.menu?.addItem(item1)
        deviceInformationToShowPopUpButton.menu?.addItem(item2)
        deviceInformationToShowPopUpButton.menu?.addItem(item3)
        deviceInformationToShowPopUpButton.menu?.addItem(item4)
        deviceInformationToShowPopUpButton.menu?.addItem(item5)

        deviceInformationToShowPopUpButton.target = self
        deviceInformationToShowPopUpButton.action = #selector(updateStatusBarLayoutType(_:))

        deviceInformationToShowPopUpButton.selectItemWithTag(preferences.general.layoutType.value.rawValue)

        startAtLoginButton.state = startAtLoginController.startAtLogin ? NSOnState : NSOffState
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        preferredContentSize = view.bounds.size
    }

    @IBAction func toggleStartAtLogin(sender: AnyObject) {
        startAtLoginController.startAtLogin = startAtLoginButton.state == NSOnState
    }

    @IBAction func updateStatusBarLayoutType(sender: AnyObject) {
        if let popupButton = sender as? NSPopUpButton {
            if let tag = popupButton.selectedItem?.tag, let layoutType = StatusBarViewLayoutType(rawValue: tag) {
                preferences.general.layoutType.value = layoutType
            }
        }
    }
}
