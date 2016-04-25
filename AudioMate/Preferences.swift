//
//  Preferences.swift
//  AudioMate
//
//  Created by Ruben Nine on 24/04/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Bond

final class Preferences {
    let general = General()
    let notifications = Notifications()

    static let sharedPreferences = Preferences()
    private init() {}

    static private let defaults = BindableUserDefaults()

    /// General preferences
    final class General {
        lazy var isFirstLaunch: Observable<Bool> = {
            return defaults.bind(self.dynamicType, name: #function, type: Bool.self, defaultValue: true)
        }()

        lazy var featuredDevice: Observable<DeviceDescriptor> = {
            return defaults.bind(self.dynamicType, name: #function, type: DeviceDescriptor.self, defaultValue: DeviceDescriptor(device: nil))
        }()

        lazy var layoutType: Observable<StatusBarViewLayoutType> = {
            return defaults.bind(self.dynamicType, name: #function, type: StatusBarViewLayoutType.self, defaultValue: StatusBarViewLayoutType.SampleRate)
        }()
    }

    /// User notification preferences
    final class Notifications {
        lazy var shouldDisplayVolumeChanges: Observable<Bool> = {
            return defaults.bind(self.dynamicType, name: #function, type: Bool.self, defaultValue: true)
        }()

        lazy var shouldDisplayMuteChanges: Observable<Bool> = {
            return defaults.bind(self.dynamicType, name: #function, type: Bool.self, defaultValue: true)
        }()

        lazy var shouldDisplaySampleRateChanges: Observable<Bool> = {
            return defaults.bind(self.dynamicType, name: #function, type: Bool.self, defaultValue: true)
        }()

        lazy var shouldDisplayClockSourceChanges: Observable<Bool> = {
            return defaults.bind(self.dynamicType, name: #function, type: Bool.self, defaultValue: true)
        }()

        lazy var shouldDisplayAddedAndRemovedDeviceChanges: Observable<Bool> = {
            return defaults.bind(self.dynamicType, name: #function, type: Bool.self, defaultValue: true)
        }()

        lazy var shouldDisplayDefaultDeviceChanges: Observable<Bool> = {
            return defaults.bind(self.dynamicType, name: #function, type: Bool.self, defaultValue: true)
        }()
    }
}
