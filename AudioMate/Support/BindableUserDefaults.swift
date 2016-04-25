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

    func bind<T: RawRepresentable>(ownerType: Any.Type, name: String, type: T.Type, defaultValue: T) -> Observable<T> {
        let mappedKey = "\(ownerType).\(name)"

        // Set initial default value if missing
        if NSUserDefaults().objectForKey(mappedKey) == nil {
            NSUserDefaults().setObject(defaultValue.rawValue as? AnyObject, forKey: mappedKey)
        }

        let obj = T(rawValue: NSUserDefaults().objectForKey(mappedKey) as! T.RawValue)
        let prop = Observable<T>(obj!)

        prop.observe { value in
            log.verbose("Setting \(mappedKey) = \(value)")
            NSUserDefaults().setObject(value.rawValue as? AnyObject, forKey: mappedKey)
        }

        return prop
    }

    func bind<T: NSCoding>(ownerType: Any.Type, name: String, type: T.Type, defaultValue: T) -> Observable<T> {
        let mappedKey = "\(ownerType).\(name)"

        // Set initial default value if missing
        if NSUserDefaults().customObjectForKey(mappedKey) == nil {
            NSUserDefaults().setCustomObject(defaultValue, forKey: mappedKey)
        }

        let prop = Observable<T>(NSUserDefaults().customObjectForKey(mappedKey) as! T)

        prop.observe { value in
            log.verbose("Setting \(mappedKey) = \(value)")
            NSUserDefaults().setCustomObject(value, forKey: mappedKey)
        }
        
        return prop
    }
}
