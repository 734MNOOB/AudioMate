//
//  StatusBarView.swift
//  AudioMate
//
//  Created by Ruben Nine on 20/01/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa

protocol StatusBarSubView {
    var representedObject: AnyObject? { get set }
    var shouldHighlight: Bool { get set }
    func updateUI()
}

class StatusBarView: NSView {
    var enabled: Bool = true {
        didSet {
            alphaValue = enabled ? 1.0 : 0.33
        }
    }

    func subView() -> StatusBarSubView? {
        if subviews.count > 0 {
            if let view = subviews[0] as? StatusBarSubView {
                return view
            }
        }

        return nil
    }

    func setSubView<T: NSView where T: StatusBarSubView>(subView: T) {
        if subviews.count == 0 {
            addSubview(subView)
        } else {
            replaceSubview(subviews[0], with: subView)
        }

        subView.updateConstraints()
    }
}
