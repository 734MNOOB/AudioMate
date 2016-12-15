//
//  UpdatePreferencesViewController.swift
//  AudioMate
//
//  Created by Ruben Nine on 21/07/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa
import Sparkle

class UpdatePreferencesViewController: NSViewController {

    @IBOutlet var buildInformationLabel: NSTextField!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        // Do view setup here.

        if let buildInfo = BundleInfo.buildInfo() {
            buildInformationLabel.stringValue = buildInfo
        }
    }

    @IBAction func checkForUpdates(_ sender: AnyObject) {

        SUUpdater.shared().checkForUpdates(sender)
    }
}
