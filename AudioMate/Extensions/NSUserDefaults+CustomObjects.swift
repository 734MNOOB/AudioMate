//
//  NSUserDefaults+CustomObjects.swift
//  AudioMate
//
//  Created by Ruben Nine on 25/04/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Foundation

extension UserDefaults {

    public func customObjectForKey(defaultName: String) -> NSCoding? {

        guard let objectForKey = object(forKey: defaultName) as? NSData else { return nil }

        if let decodedObject = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(objectForKey) as? NSCoding {
            return decodedObject
        } else {
            return nil
        }
    }

    public func setCustomObject(value: NSCoding?, forKey defaultName: String) {

        guard let object = value else { return }

        let encodedObject = NSKeyedArchiver.archivedData(withRootObject: object)
        set(encodedObject, forKey: defaultName)
    }
}
