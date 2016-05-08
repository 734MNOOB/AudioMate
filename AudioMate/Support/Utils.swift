//
//  Utils.swift
//  AudioMate
//
//  Created by Ruben Nine on 4/24/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import AppKit

struct Utils {
    private init() {}

    /// Transform application to foreground mode
    static func transformAppIntoForegroundMode() {
        var psn = ProcessSerialNumber(highLongOfPSN: 0, lowLongOfPSN: UInt32(kCurrentProcess))
        TransformProcessType(&psn, ProcessApplicationTransformState(kProcessTransformToForegroundApplication))
    }

    /// Transform application to LSUIElement mode
    static func transformAppIntoUIElementMode() {
        var psn = ProcessSerialNumber(highLongOfPSN: 0, lowLongOfPSN: UInt32(kCurrentProcess))
        TransformProcessType(&psn, ProcessApplicationTransformState(kProcessTransformToUIElementApplication))
    }
}
