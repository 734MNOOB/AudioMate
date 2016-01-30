//
//  StatusBarView.swift
//  AudioMate
//
//  Created by Ruben Nine on 20/01/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa
import PureLayout

class StatusBarView: NSView {
    private let statusItem: NSStatusItem!

    private let label: NSTextField = {
        $0.font = NSFont.boldSystemFontOfSize(NSFont.systemFontSizeForControlSize(.RegularControlSize))
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
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        super.init(frame: frameRect)
        sharedInit()
    }

    required init?(coder: NSCoder) {
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        super.init(coder: coder)
        sharedInit()
    }

    private func sharedInit() {
        statusItem.view = self
    }

    func setDeviceMenu(menu: NSMenu) {
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
        super.drawRect(dirtyRect)
    }
}
