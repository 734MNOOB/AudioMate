//
//  EventNotifier.swift
//  AudioMate
//
//  Created by Ruben Nine on 19/01/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Foundation
import AMCoreAudio

public final class EventNotifier {
    static let sharedEventNotifier = EventNotifier()

    private var lastNotification: NSUserNotification?
    private var lastNotificationTime: NSTimeInterval?
    private let minTimeBetweenNotifications: NSTimeInterval = 0.05 // in seconds

    private init() {}

    func samplerateChangeNotification(audioDevice: AMCoreAudioDevice) {
        let notification = NSUserNotification()

        notification.title = NSLocalizedString("Sample Rate Changed", comment: "")

        notification.informativeText = String(
            format: NSLocalizedString("%@ sample rate changed to %@", comment: ""),
            audioDevice.deviceName(),
            audioDevice.actualSampleRateFormattedWithShortFormat(true)
        )

        debouncedDeliverNotification(notification)
    }

    func volumeChangeNotification(audioDevice: AMCoreAudioDevice, direction: AMCoreAudio.Direction) {
        if let volumeInDb = audioDevice.masterVolumeInDecibelsForDirection(direction) {
            let formattedVolume = AMCoreAudioDevice.formattedVolumeInDecibels(volumeInDb)
            let notification = NSUserNotification()

            notification.title = NSLocalizedString("Volume Changed", comment: "")

            notification.informativeText = String(
                format: NSLocalizedString("%@ volume changed to %@", comment: ""),
                audioDevice.deviceName(),
                formattedVolume
            )

            debouncedDeliverNotification(notification)
        }
    }

    func muteChangeNotification(audioDevice: AMCoreAudioDevice, direction: AMCoreAudio.Direction) {
        let notification = NSUserNotification()

        if audioDevice.isMasterVolumeMutedForDirection(direction) == true {
            notification.title = NSLocalizedString("Audio Muted", comment: "")

            notification.informativeText = String(
                format: NSLocalizedString("%@ audio was muted", comment: ""),
                audioDevice.deviceName()
            )
        } else {
            notification.title = NSLocalizedString("Audio Unmuted", comment: "")

            notification.informativeText = String(
                format: NSLocalizedString("%@ audio was unmuted", comment: ""),
                audioDevice.deviceName()
            )
        }

        debouncedDeliverNotification(notification)
    }

    func clockSourceChangeNotification(audioDevice: AMCoreAudioDevice, channelNumber: UInt32, direction: AMCoreAudio.Direction) {
        if let clockSourceName = audioDevice.clockSourceForChannel(channelNumber, andDirection: direction) {
            let notification = NSUserNotification()

            notification.title = NSLocalizedString("Clock Source Changed", comment: "")

            notification.informativeText = String(
                format: NSLocalizedString("%@ clock source changed to %@", comment: ""),
                audioDevice.deviceName(),
                clockSourceName
            )

            debouncedDeliverNotification(notification)
        }
    }

    func deviceListChangeNotification(addedDevices: [AMCoreAudioDevice], removedDevices: [AMCoreAudioDevice]) {
        for audioDevice in addedDevices {
            let notification = NSUserNotification()

            notification.title = NSLocalizedString("Audio Device Appeared", comment: "")

            notification.informativeText = String(
                format: NSLocalizedString("%@ appeared", comment: ""),
                audioDevice.deviceName()
            )

            NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
        }

        for audioDevice in removedDevices {
            let notification = NSUserNotification()

            notification.title = NSLocalizedString("Audio Device Disappeared", comment: "")

            notification.informativeText = String(
                format: NSLocalizedString("%@ disappeared", comment: ""),
                audioDevice.deviceName()
            )

            NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
        }
    }

    // MARK: Private Methods

    private func debouncedDeliverNotification(notification: NSUserNotification) {
        let timeInterval = NSDate().timeIntervalSinceReferenceDate

        if lastNotification != notification && timeInterval - (lastNotificationTime ?? 0) > minTimeBetweenNotifications {
            lastNotification = notification
            lastNotificationTime = timeInterval

            NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
        }
    }
}
