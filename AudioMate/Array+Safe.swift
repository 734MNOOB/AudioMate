//
//  Array+Safe.swift
//  AudioMate
//
//  Created by Ruben Nine on 26/04/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//
//  Originally written by Erica Sadun, and Mike Ash
//  Source: http://ericasadun.com/2015/06/01/swift-safe-array-indexing-my-favorite-thing-of-the-new-week/

import Foundation

extension Array {
    subscript (safe index: UInt) -> Element? {
        return Int(index) < count ? self[Int(index)] : nil
    }
}
