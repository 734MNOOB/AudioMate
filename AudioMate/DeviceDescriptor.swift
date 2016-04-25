//
//  DeviceDescriptor.swift
//  AudioMate
//
//  Created by Ruben Nine on 25/04/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Foundation
import AMCoreAudio

class DeviceDescriptor: NSObject, NSCoding {

    private(set) var device: AMAudioDevice?

    init(device: AMAudioDevice?) {
        self.device = device
    }

    required init?(coder: NSCoder) {
        super.init()

        let deviceUID = coder.decodeObjectForKey("deviceUID") as? String

        if let deviceUID = deviceUID {
            device = AMAudioDevice.lookupByUID(deviceUID)
        }
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(device?.deviceUID(), forKey: "deviceUID")
    }

    override var description: String {
        return "(device: \(device), \(super.description))"
    }
}
