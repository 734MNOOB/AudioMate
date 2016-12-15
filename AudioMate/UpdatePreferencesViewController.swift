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

    override func viewWillAppear() {
        super.viewWillAppear()
        preferredContentSize = view.bounds.size
    }

    @IBAction func checkForUpdates(sender: AnyObject) {
        SUUpdater.shared().checkForUpdates(sender)
    }
}
