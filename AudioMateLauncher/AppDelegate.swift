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


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Check if main app is already running; if yes, do nothing and terminate helper app

        let runningApps = NSWorkspace.sharedWorkspace().runningApplications

        if runningApps.indexOf({ app -> Bool in app.bundleIdentifier == TargetBundleIdentifier }) == nil {
            let path = NSBundle.mainBundle().bundlePath
            var pathComponents = path.componentsSeparatedByString("/")

            pathComponents.removeLast()
            pathComponents.removeLast()
            pathComponents.removeLast()
            pathComponents.append("MacOS")
            pathComponents.append("AudioMate")

            let newPath = pathComponents.joinWithSeparator("/")

            if NSFileManager.defaultManager().fileExistsAtPath(newPath) {
                NSWorkspace.sharedWorkspace().launchApplication(newPath)
            } else {
                print("ERROR: Unable to launch app because path at \(newPath) does not exist.")
            }
        }

        NSApp.terminate(self)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

}
