//
//  BindableUserDefaults.swift
//  AudioMate
//
//  Created by Ruben Nine on 24/04/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Bond

struct BindableUserDefaults {
    func bind<T>(ownerType: Any.Type, name: String, type: T.Type, defaultValue: T) -> Observable<T> {
        let mappedKey = "\(ownerType).\(name)"

        // Set initial default value if missing
        if NSUserDefaults().objectForKey(mappedKey) == nil {
            NSUserDefaults().setObject(defaultValue as? AnyObject, forKey: mappedKey)
        }

        let prop = Observable<T>(NSUserDefaults().objectForKey(mappedKey) as! T)

        prop.observe { value in
            if let obj: AnyObject = value as? AnyObject {
                log.verbose("Setting \(mappedKey) = \(value)")
                NSUserDefaults().setObject(obj, forKey: mappedKey)
            }
        }

        return prop
    }
}
