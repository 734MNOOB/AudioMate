//
//  FeaturedDeviceDescriptor.swift
//  AudioMate
//
//  Created by Ruben Nine on 25/04/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Foundation
import AMCoreAudio

class FeaturedDeviceDescriptor: NSObject, NSCoding {

    var deviceUID: String?
    var deviceName: String?

    override init() {}

    required init?(coder: NSCoder) {
        super.init()
        deviceUID = coder.decodeObjectForKey("deviceUID") as? String
        deviceName = coder.decodeObjectForKey("deviceName") as? String
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(deviceUID, forKey: "deviceUID")
        aCoder.encodeObject(deviceName, forKey: "deviceName")
    }

    func audioDevice() -> AMAudioDevice? {
        if let deviceUID = deviceUID {
            return AMAudioDevice.lookupByUID(deviceUID)
        }

        return nil
    }

    override var description: String {
        return "(\(super.description)) {deviceName: \(deviceName ?? "nil"), deviceUID: \(deviceUID ?? "nil")}"
    }
}
