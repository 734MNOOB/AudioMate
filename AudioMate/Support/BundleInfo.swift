//
//  BundleInfo.swift
//  AudioMate
//
//  Created by Ruben Nine on 4/29/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Foundation

final class BundleInfo {

    private init() {}

    private static let thisBundle = Bundle(for: BundleInfo.self)

    public static let buildDate: String? = thisBundle.infoDictionary?["BuildDate"] as? String
    public static let name: String? = thisBundle.infoDictionary?["CFBundleName"] as? String
    public static let version: String? = thisBundle.infoDictionary?["CFBundleShortVersionString"] as? String
    public static let buildNumber: String? = thisBundle.infoDictionary?["CFBundleVersion"] as? String

    public static func buildInfo() -> String? {

        guard let buildDate = buildDate, let name = name, let version = version, let buildNumber = buildNumber else {
            return nil
        }

        return "\(name) \(version) (build \(buildNumber)) built on \(buildDate)."
    }
}
