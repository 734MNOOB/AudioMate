//
//  AppDelegate.swift
//  AudioMate
//
//  Created by Ruben Nine on 18/01/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa

// The bundle identifier for the app we want to launch
private let TargetBundleIdentifier = "io.9labs.AudioMate"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


    func applicationDidFinishLaunching(_ notification: Notification) {

        // Check if main app is already running; if yes, do nothing and terminate helper app

        let runningApps = NSWorkspace.shared().runningApplications

        if (runningApps.contains { $0.bundleIdentifier == TargetBundleIdentifier }) == false {
            let path = Bundle.main.bundlePath
            var pathComponents = path.components(separatedBy: "/")

            pathComponents.removeLast()
            pathComponents.removeLast()
            pathComponents.removeLast()
            pathComponents.append("MacOS")
            pathComponents.append("AudioMate")

            let newPath = pathComponents.joined(separator: "/")

            if FileManager.default.fileExists(atPath: newPath) {
                NSWorkspace.shared().launchApplication(newPath)
            } else {
                print("ERROR: Unable to launch app because path at \(newPath) does not exist.")
            }
        }

        NSApp.terminate(self)
    }

    func applicationWillTerminate(_ notification: Notification) {

        // Insert code here to tear down your application
    }

}
