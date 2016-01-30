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

        let quitMenuItem = NSMenuItem()

        quitMenuItem.title = "Quit"
        quitMenuItem.target = NSApp
        quitMenuItem.action = "terminate:"

        mainMenu.addItem(quitMenuItem)
        statusBarView?.setMainMenu(mainMenu)
    }

    func addDevice(device: AMCoreAudioDevice) {
        audioDevices.append(device)

        let item = NSMenuItem()

        item.title = device.deviceName()
        item.target = self
        item.action = "noop:"
        item.representedObject = device
        item.tag = Int(device.deviceID)

        mainMenu.insertItem(item, atIndex: 0)
    }

    func removeDevice(device: AMCoreAudioDevice) {
        if let idx = audioDevices.indexOf(device) {
            audioDevices.removeAtIndex(idx)
        }

        if let item = mainMenu.itemWithTag(Int(device.deviceID)) {
            mainMenu.removeItem(item)
        }
    }

    @objc func noop(sender: AnyObject) {
        print("aha \(sender)")
    }
}

extension StatusBarViewController: NSMenuDelegate {
    func menuDidClose(menu: NSMenu) {
        statusBarView?.controlIsHighlighted = false
    }
}
