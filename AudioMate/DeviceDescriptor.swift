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

    var device: AudioDevice? {

        if let deviceUID = deviceUID {
            return AudioDevice.lookup(by: deviceUID)
        }

        return nil
    }

    private(set) var deviceUID: String?


    init(device: AudioDevice?) {

        deviceUID = device?.uid
    }

    required init?(coder: NSCoder) {

        super.init()

        deviceUID = coder.decodeObject(forKey: "deviceUID") as? String
    }

    public func encode(with aCoder: NSCoder) {

        aCoder.encode(deviceUID, forKey: "deviceUID")
    }
}

extension DeviceDescriptor {

    override var description: String {

        return "(device: \(String(describing: device)), \(super.description))"
    }

}
