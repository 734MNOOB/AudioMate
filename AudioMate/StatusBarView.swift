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

    var isEnabled: Bool { get set }

    func updateUI()
}

class StatusBarView: NSView {

    var isEnabled: Bool = true {

        didSet {
            if var subView = subView() {
                subView.isEnabled = isEnabled
            }
        }
    }

    func subView() -> StatusBarSubView? {

        return subviews[safe: 0] as? StatusBarSubView
    }

    func setSubView<T: NSView>(subView: T) where T: StatusBarSubView {

        if subviews.count == 0 {
            addSubview(subView)
        } else {
            replaceSubview(subviews[0], with: subView)
        }

        var theSubView = subView
        theSubView.isEnabled = isEnabled

        subView.updateConstraints()
    }
}
