//
//  Double+Extensions.swift
//  AudioMate
//
//  Created by Ruben Nine on 10/04/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Foundation

extension Double {

    enum SpecialFormat {

        case sampleRate
        case interval
    }

    func string(as format: SpecialFormat) -> String {

        switch format {
        case .interval:

            if !isNormal {
                return "00:00"
            }

            let sign = self < 0 ? "-" : ""
            let ti = UInt(abs(self))
            let seconds = ti % 60
            let minutes = (ti / 60) % 60
            let hours = ti / 3600

            if hours > 0 {
                return String(format: "%@%.2d:%0.2d:%0.2d", sign, hours, minutes, seconds)
            } else {
                return String(format: "%@%.2d:%0.2d", sign, minutes, seconds)
            }

        case .sampleRate:

            return String(format: "\(self / 1000.0) kHz")

        }
    }

    @discardableResult func wait() -> DispatchTimeoutResult {

        let semaphore = DispatchSemaphore(value: 0)
        return semaphore.wait(timeout: .now() + self)
    }
}
