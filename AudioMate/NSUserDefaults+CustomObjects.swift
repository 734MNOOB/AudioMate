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
            At the time of writing, `NSKeyedUnarchiver.unarchiveObjectWithData` may throw an
            Objective-C exception, which might cause our app to crash if the unarchival process fails.
            
            We are using SwiftTryCatch to recover against such cases until the `NSKeyedUnarchiver` 
            API is updated to throw actual Swift errors. Then we will be able to safely remove this.
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
