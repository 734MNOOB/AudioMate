//
//  AppDelegate.swift
//  AudioMate
//
//  Created by Ruben Nine on 18/01/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Check if main app is already running; if yes, do nothing and terminate helper app

        var alreadyRunning = false
        let runningApps = NSWorkspace.sharedWorkspace().runningApplications

        for app in runningApps {
            if app.bundleIdentifier == "io.9labs.AudioMate" {
                alreadyRunning = true
            }
        }

        if !alreadyRunning {
            let path = NSBundle.mainBundle().bundlePath
            var pathComponents = path.componentsSeparatedByString("/")

            pathComponents.removeLast()
            pathComponents.removeLast()
            pathComponents.removeLast()
            pathComponents.append("MacOS")
            pathComponents.append("AudioMate")

            let newPath = pathComponents.joinWithSeparator("/")

            NSWorkspace.sharedWorkspace().launchApplication(newPath)
        }

        NSApp.terminate(self)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

}
