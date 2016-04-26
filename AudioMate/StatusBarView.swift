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
    weak var statusItem: NSStatusItem?

    var highlighted: Bool = false {
        didSet {
            setNeedsDisplayInRect(bounds)

            if var subView = self.subView() {
                subView.shouldHighlight = highlighted
            }

            if highlighted {
                if let menu = statusItem?.menu {
                    statusItem?.popUpStatusItemMenu(menu)
                }
            }
        }
    }

    override func mouseDown(theEvent: NSEvent) {
        highlighted = !highlighted
    }

    override func drawRect(dirtyRect: NSRect) {
        statusItem?.drawStatusBarBackgroundInRect(dirtyRect, withHighlight: highlighted)

        super.drawRect(dirtyRect)
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
