//
//  Preferences.swift
//  AudioMate
//
//  Created by Ruben Nine on 24/04/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Foundation
import ReactiveKit

private extension UserDefaults {

    // non-optional
    func observe<T: Any>(key: String, defaultValue: T) -> Property<T> {

        let o = object(forKey: key) as? T ?? defaultValue
        let p = Property(o)
        let _ = p.observeNext { (value) in self.set(value, forKey: key) }

        return p
    }

    // optional
    func observe<T: Any>(key: String, defaultValue: T?) -> Property<T?> {

        let o = object(forKey: key) as? T ?? defaultValue
        let p = Property(o)
        let _ = p.observeNext { (value) in self.set(value, forKey: key) }

        return p
    }

    // raw representable
    func observe<T: RawRepresentable>(key: String, defaultValue: T) -> Property<T> {

        let o = T(rawValue: object(forKey: key) as? T.RawValue ?? defaultValue.rawValue)!
        let p = Property(o)
        let _ = p.observeNext { (value) in self.set(value.rawValue, forKey: key) }
        
        return p
    }

    // NSCoding
    func observe<T: NSCoding>(key: String, defaultValue: T) -> Property<T> {

        if customObjectForKey(defaultName: key) == nil {
            setCustomObject(value: defaultValue, forKey: key)
        }

        let o = (customObjectForKey(defaultName: key) as? T)!
        let p = Property(o)
        let _ = p.observeNext { (value) in self.setCustomObject(value: value, forKey: key) }

        return p
    }
}

// MARK: - Preferences

final class Preferences {

    static let sharedPreferences = Preferences()
    private init() {}

    fileprivate static let sud = UserDefaults.standard

    let general = General()
    let notifications = Notifications()

    class Base {

        // Support function that returns the fully qualified key name from a partial key name
        // i.e. "name" -> "Preferences:General:name"
        fileprivate func fqnKey(_ name: String) -> String {

            return "\(type(of: self)):\(name)"
        }
    }

}

// MARK: - Preferences - General

extension Preferences {

    final class General: Base {

        lazy var isFirstLaunch: Property<Bool> = sud.observe(key: self.fqnKey(#function), defaultValue: true)
        lazy var featuredDevice: Property<DeviceDescriptor> = sud.observe(key: self.fqnKey(#function), defaultValue: DeviceDescriptor(device: nil))
        lazy var layoutType: Property<StatusBarViewLayoutType> = sud.observe(key: self.fqnKey(#function), defaultValue: .sampleRate)
    }

}

// MARK: - Preferences - Notifications

extension Preferences {

    final class Notifications: Base {

        lazy var shouldDisplayVolumeChanges: Property<Bool> = sud.observe(key: self.fqnKey(#function), defaultValue: true)
        lazy var shouldDisplayMuteChanges: Property<Bool> = sud.observe(key: self.fqnKey(#function), defaultValue: true)
        lazy var shouldDisplaySampleRateChanges: Property<Bool> = sud.observe(key: self.fqnKey(#function), defaultValue: true)
        lazy var shouldDisplayClockSourceChanges: Property<Bool> = sud.observe(key: self.fqnKey(#function), defaultValue: true)
        lazy var shouldDisplayAddedAndRemovedDeviceChanges: Property<Bool> = sud.observe(key: self.fqnKey(#function), defaultValue: true)
        lazy var shouldDisplayDefaultDeviceChanges: Property<Bool> = sud.observe(key: self.fqnKey(#function), defaultValue: true)
    }
}
