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
    private let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)

    private let label: NSTextField = {
        $0.font = NSFont.menuBarFontOfSize(14.0)
        $0.drawsBackground = false
        $0.stringValue = "AudioMate"
        $0.editable = false
        $0.bordered = false
        $0.textColor = .controlTextColor()
        $0.alignment = .Center

        return $0
    }(NSTextField(forAutoLayout: ()))

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
        addSubview(label)
    }

    override func mouseDown(theEvent: NSEvent) {
        controlIsHighlighted = !controlIsHighlighted
    }

    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        // Add controls
        addControls()
        // Setup constraints
        label.autoPinEdgeToSuperviewEdge(.Left)
        label.autoPinEdgeToSuperviewEdge(.Right)
        label.autoCenterInSuperview()
    }

    override func drawRect(dirtyRect: NSRect) {
        statusItem.drawStatusBarBackgroundInRect(dirtyRect, withHighlight: controlIsHighlighted)

        if controlIsHighlighted {
            label.textColor = .whiteColor()
        } else {
            label.textColor = .controlTextColor()
        }

        super.drawRect(dirtyRect)
    }
}
