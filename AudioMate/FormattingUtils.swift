//
//  FormattingUtils.swift
//  AudioMate
//
//  Created by Ruben Nine on 10/04/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Foundation

class FormattingUtils {

    class func formatSampleRate(sampleRate: Double) -> String {
        return String(format: "%.1f kHz", sampleRate / 1000)
    }
}
