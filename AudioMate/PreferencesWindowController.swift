//
//  PreferencesWindowController.swift
//  AudioMate
//
//  Created by Ruben Nine on 4/24/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController {

    var windowDidCloseHandler:(()->Void)?

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        window?.delegate = self

        // Transform application to foreground mode
        Utils.transformAppIntoForegroundMode()

        // Activate (give focus to) our app
        NSApplication.sharedApplication().activateIgnoringOtherApps(true)
    }
}

extension PreferencesWindowController: NSWindowDelegate {
    func windowWillClose(notification: NSNotification) {
        // Transform application to LSUIElement mode
        Utils.transformAppIntoUIElementMode()
        windowDidCloseHandler?()
    }
}
