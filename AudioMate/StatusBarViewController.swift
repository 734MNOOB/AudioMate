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
    private var devicesMenu = NSMenu()
    private var statusBarView: StatusBarView!

    override func viewDidLoad() {
        super.viewDidLoad()

        statusBarView = view as? StatusBarView
        devicesMenu.delegate = self

        let quitMenuItem = NSMenuItem()

        quitMenuItem.title = "Quit"
        quitMenuItem.target = NSApp
        quitMenuItem.action = "terminate:"

        devicesMenu.addItem(quitMenuItem)
        statusBarView.setDeviceMenu(devicesMenu)
    }

    func addDevice(device: AMCoreAudioDevice) {
        audioDevices.append(device)

        print("(+) audioDevices = \(audioDevices)")

        let item = NSMenuItem()

        item.title = device.deviceName()
        item.target = self
        item.action = "noop:"
        item.representedObject = device
        item.tag = Int(device.deviceID)

        devicesMenu.insertItem(item, atIndex: 0)
    }

    func removeDevice(device: AMCoreAudioDevice) {
        if let idx = audioDevices.indexOf(device) {
            audioDevices.removeAtIndex(idx)
        }

        if let item = devicesMenu.itemWithTag(Int(device.deviceID)) {
            devicesMenu.removeItem(item)
        }

        print("(-) audioDevices = \(audioDevices)")
    }

    @objc func noop(sender: AnyObject) {
        print("aha \(sender)")
    }
}

extension StatusBarViewController: NSMenuDelegate {
    func menuDidClose(menu: NSMenu) {
        statusBarView.controlIsHighlighted = false
    }
}
