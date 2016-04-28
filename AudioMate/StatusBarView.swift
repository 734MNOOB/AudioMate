//
//  StatusBarView.swift
//  AudioMate
//
//  Created by Ruben Nine on 20/01/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa

protocol StatusBarSubView {
    weak var representedObject: AnyObject? { get set }
    var shouldHighlight: Bool { get set }
    var enabled: Bool { get set }
    func updateUI()
}

class StatusBarView: NSView {
    var enabled: Bool = true {
        didSet {
            if var subView = subView() {
                subView.enabled = enabled
            }
        }
    }

    func subView() -> StatusBarSubView? {
        return subviews[safe: 0] as? StatusBarSubView
    }

    func setSubView<T: NSView where T: StatusBarSubView>(subView: T) {
        if subviews.count == 0 {
            addSubview(subView)
        } else {
            replaceSubview(subviews[0], with: subView)
        }

        var theSubView = subView
        theSubView.enabled = enabled

        subView.updateConstraints()
    }
}
