//
//  UserNotificationDispatcher.swift
//  AudioMate
//
//  Created by Ruben Nine on 19/01/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Foundation
import AMCoreAudio

/**
    `UserNotificationDispatcher` is a singleton class that wraps all the user notifications 
    that AudioMate generates.
 */
public final class UserNotificationDispatcher {

    /// Shared instance
    static let sharedDispatcher = UserNotificationDispatcher()

    private var lastNotification: NSUserNotification?
    private var lastNotificationTime: TimeInterval?
    private let minIntervalBetweenNotifications: TimeInterval = 0.05 // in seconds

    private init() {}

    func samplerateChangeNotification(audioDevice: AudioDevice) {

        let notification = NSUserNotification()
        let sampleRate = audioDevice.nominalSampleRate() ?? 0

        notification.title = NSLocalizedString("Sample Rate Changed", comment: "")

        notification.informativeText = String(
            format: NSLocalizedString("%@ sample rate changed to %@", comment: ""),
            audioDevice.name,
            String(format: NSLocalizedString("%.1f kHz", comment: ""), sampleRate * 0.001)
        )

        debouncedDeliver(notification: notification)
    }

    func volumeChangeNotification(audioDevice: AudioDevice, direction: AMCoreAudio.Direction) {

        if let volumeInDb = audioDevice.virtualMasterVolumeInDecibels(direction: direction) {
            let formattedVolume = String(format: NSLocalizedString("%.1fdBFS", comment: ""), volumeInDb)
            let notification = NSUserNotification()

            notification.title = NSLocalizedString("Volume Changed", comment: "")

            notification.informativeText = String(
                format: NSLocalizedString("%@ volume changed to %@", comment: ""),
                audioDevice.name,
                formattedVolume
            )

            debouncedDeliver(notification: notification)
        }
    }

    func muteChangeNotification(audioDevice: AudioDevice, direction: AMCoreAudio.Direction) {

        let notification = NSUserNotification()

        if audioDevice.isMasterChannelMuted(direction: direction) == true {
            notification.title = NSLocalizedString("Audio Muted", comment: "")

            notification.informativeText = String(
                format: NSLocalizedString("%@ audio was muted", comment: ""),
                audioDevice.name
            )
        } else {
            notification.title = NSLocalizedString("Audio Unmuted", comment: "")

            notification.informativeText = String(
                format: NSLocalizedString("%@ audio was unmuted", comment: ""),
                audioDevice.name
            )
        }

        debouncedDeliver(notification: notification)
    }

    func clockSourceChangeNotification(audioDevice: AudioDevice, channelNumber: UInt32, direction: AMCoreAudio.Direction) {

        if let clockSourceName = audioDevice.clockSourceName(channel: channelNumber, direction: direction) {
            let notification = NSUserNotification()

            notification.title = NSLocalizedString("Clock Source Changed", comment: "")

            notification.informativeText = String(
                format: NSLocalizedString("%@ clock source changed to %@", comment: ""),
                audioDevice.name,
                clockSourceName
            )

            debouncedDeliver(notification: notification)
        }
    }

    func deviceListChangeNotification(addedDevices: [AudioDevice], removedDevices: [AudioDevice]) {

        for audioDevice in addedDevices {
            let notification = NSUserNotification()

            notification.title = NSLocalizedString("Audio Device Appeared", comment: "")

            notification.informativeText = String(
                format: NSLocalizedString("%@ appeared", comment: ""),
                audioDevice.name
            )

            NSUserNotificationCenter.default.deliver(notification)
        }

        for audioDevice in removedDevices {
            let notification = NSUserNotification()

            notification.title = NSLocalizedString("Audio Device Disappeared", comment: "")

            notification.informativeText = String(
                format: NSLocalizedString("%@ disappeared", comment: ""),
                audioDevice.name
            )

            NSUserNotificationCenter.default.deliver(notification)
        }
    }

    func defaultOutputDeviceChangeNotification(audioDevice: AudioDevice) {
        let notification = NSUserNotification()

        notification.title = NSLocalizedString("Default Output Device Changed", comment: "")

        notification.informativeText = String(
            format: NSLocalizedString("%@ is the new default output device", comment: ""),
            audioDevice.name
        )

        debouncedDeliver(notification: notification)
    }

    func defaultInputDeviceChangeNotification(audioDevice: AudioDevice) {
        let notification = NSUserNotification()

        notification.title = NSLocalizedString("Default Input Device Changed", comment: "")

        notification.informativeText = String(
            format: NSLocalizedString("%@ is the new default input device", comment: ""),
            audioDevice.name
        )

        debouncedDeliver(notification: notification)
    }

    func defaultSystemOutputDeviceChangeNotification(audioDevice: AudioDevice) {
        let notification = NSUserNotification()

        notification.title = NSLocalizedString("Default System Output Device Changed", comment: "")

        notification.informativeText = String(
            format: NSLocalizedString("%@ is the new default system output device", comment: ""),
            audioDevice.name
        )

        debouncedDeliver(notification: notification)
    }

    // MARK: Private Methods

    // Discards duplicate notifications or those that happen faster than the min interval.
    private func debouncedDeliver(notification: NSUserNotification) {
        let timeInterval = NSDate().timeIntervalSinceReferenceDate

        if lastNotification != notification &&
           timeInterval - (lastNotificationTime ?? 0) > minIntervalBetweenNotifications {
            lastNotification = notification
            lastNotificationTime = timeInterval

            NSUserNotificationCenter.default.deliver(notification)
        }
    }
}
