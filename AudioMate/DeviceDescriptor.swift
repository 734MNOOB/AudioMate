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

    var device: AMAudioDevice? {
        if let deviceUID = deviceUID {
            return AMAudioDevice.lookupByUID(deviceUID)
        }

        return nil
    }

    private(set) var deviceUID: String?

    init(device: AMAudioDevice?) {
        deviceUID = device?.deviceUID()
    }

    required init?(coder: NSCoder) {
        super.init()

        deviceUID = coder.decodeObjectForKey("deviceUID") as? String
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(deviceUID, forKey: "deviceUID")
    }

    override var description: String {
        return "(device: \(device), \(super.description))"
    }
}
