//
//  AppInfo.swift
//  AudioMate
//
//  Created by Ruben Nine on 4/29/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Foundation

struct AppInfo {
    private init() {}

    static let buildDate: String? = NSBundle.mainBundle().infoDictionary?["BuildDate"] as? String
    static let name: String? = NSBundle.mainBundle().infoDictionary?["CFBundleName"] as? String
    static let version: String? = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
    static let buildNumber: String? = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String

    static func buildInfo() -> String? {
        guard let buildDate = buildDate, let appName = name, let version = version, let buildNumber = buildNumber else {
            return nil
        }

        return "\(appName) \(version) (build \(buildNumber)) built on \(buildDate)."
    }
}
