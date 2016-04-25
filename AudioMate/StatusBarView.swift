//
//  StatusBarView.swift
//  AudioMate
//
//  Created by Ruben Nine on 20/01/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa
import PureLayout_Mac   

class StatusBarView: NSView {
    private let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(24)

    private let iconView: NSImageView = {
        $0.image = NSImage(named: "Mini AudioMate")
        $0.imageScaling = .ScaleProportionallyUpOrDown

        return $0
    }(NSImageView(forAutoLayout: ()))

    var controlIsHighlighted: Bool = false {
        didSet {
            setNeedsDisplayInRect(bounds)
            if controlIsHighlighted {
                if let menu = statusItem.menu {
                    statusItem.popUpStatusItemMenu(menu)
                }
            }
        }
    }

    private override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        sharedInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }

    private func sharedInit() {
        statusItem.view = self
    }

    func setMainMenu(menu: NSMenu) {
        statusItem.menu = menu
    }

    private func addControls() {
        addSubview(iconView)
    }

    override func mouseDown(theEvent: NSEvent) {
        controlIsHighlighted = !controlIsHighlighted
    }

    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        // Add controls
        addControls()
        // Setup constraints
        iconView.autoPinEdgeToSuperviewEdge(.Left)
        iconView.autoPinEdgeToSuperviewEdge(.Right)
        iconView.autoCenterInSuperview()
    }

    override func drawRect(dirtyRect: NSRect) {
        statusItem.drawStatusBarBackgroundInRect(dirtyRect, withHighlight: controlIsHighlighted)

        super.drawRect(dirtyRect)
    }
}
