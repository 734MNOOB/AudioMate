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

        // These items are temporary
        deviceInformationToShowPopUpButton.addItemWithTitle(NSLocalizedString("Sample Rate + Master Output Volume", comment: ""))
        deviceInformationToShowPopUpButton.addItemWithTitle(NSLocalizedString("Sample Rate + Master Output Volume Percentage", comment: ""))
        deviceInformationToShowPopUpButton.addItemWithTitle(NSLocalizedString("Sample Rate + Master Output Volume Graphic", comment: ""))
        deviceInformationToShowPopUpButton.addItemWithTitle(NSLocalizedString("Sample Rate + Clock Source", comment: ""))
        deviceInformationToShowPopUpButton.addItemWithTitle(NSLocalizedString("Sample Rate", comment: ""))

        startAtLoginButton.state = startAtLoginController.startAtLogin ? NSOnState : NSOffState
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        preferredContentSize = view.bounds.size
    }

    @IBAction func toggleStartAtLogin(sender: AnyObject) {
        startAtLoginController.startAtLogin = startAtLoginButton.state == NSOnState
    }
}
