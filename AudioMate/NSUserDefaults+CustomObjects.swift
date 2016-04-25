//
//  NSUserDefaults+CustomObjects.swift
//  AudioMate
//
//  Created by Ruben Nine on 25/04/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Foundation

extension NSUserDefaults {

    public func customObjectForKey(defaultName: String) -> AnyObject? {
        guard let objectForKey = objectForKey(defaultName) as? NSData else {
            return nil
        }

        let decodedObject = NSKeyedUnarchiver.unarchiveObjectWithData(objectForKey)

        return decodedObject
    }

    public func setCustomObject(value: AnyObject?, forKey defaultName: String) {
        guard let object = value else {
            return
        }

        let encodedObject = NSKeyedArchiver.archivedDataWithRootObject(object)

        setObject(encodedObject, forKey: defaultName)
    }
}
