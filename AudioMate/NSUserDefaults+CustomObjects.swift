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

        var returnedObject: NSCoding? = nil

        /**
            At the time of writing, `NSKeyedUnarchiver.unarchiveObjectWithData` was throwing an Objective-C NSException,
            which would cause our app to crash. We are using SwiftTryCatch as a workaround for that.

            - Note: This can be safely removed once the `NSKeyedUnarchiver` API is updated to throw actual Swift errors.
        */
        SwiftTryCatch.tryBlock({ 
            if let decodedObject = NSKeyedUnarchiver.unarchiveObjectWithData(objectForKey) as? NSCoding {
                returnedObject = decodedObject
            }
        }, catchBlock: { (exception) in
            log.debug("Exception: \(exception)")
        }, finallyBlock: nil)

        return returnedObject
    }

    public func setCustomObject(value: NSCoding?, forKey defaultName: String) {
        guard let object = value else {
            return
        }

        let encodedObject = NSKeyedArchiver.archivedDataWithRootObject(object)

        setObject(encodedObject, forKey: defaultName)
    }
}
