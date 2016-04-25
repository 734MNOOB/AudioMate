//
//  NSUserDefaults+CustomObjects.swift
//  AudioMate
//
//  Created by Ruben Nine on 25/04/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Foundation

extension NSUserDefaults {

    public func customObjectForKey(defaultName: String) -> NSCoding? {
        guard let objectForKey = objectForKey(defaultName) as? NSData else {
            return nil
        }

        if let decodedObject = NSKeyedUnarchiver.unarchiveObjectWithData(objectForKey) as? NSCoding {
            return decodedObject
        }

        return nil
    }

    public func setCustomObject(value: NSCoding?, forKey defaultName: String) {
        guard let object = value else {
            return
        }

        let encodedObject = NSKeyedArchiver.archivedDataWithRootObject(object)

        setObject(encodedObject, forKey: defaultName)
    }
}
