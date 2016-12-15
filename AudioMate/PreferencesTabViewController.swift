//
//  PreferencesTabViewController.swift
//  AudioMate
//
//  Created by Ruben Nine on 12/15/16.
//  Copyright © 2016 Ruben Nine. All rights reserved.
//

import Cocoa

class PreferencesTabViewController: NSTabViewController {

    lazy var originalSizes = [NSTabViewItem : NSSize]()

    var closeHandler:(() -> Void)?

    override func viewDidLoad() {

        super.viewDidLoad()

        Utils.transformAppIntoForegroundMode()
        // Activate (give focus to) our app
        NSApplication.shared().activate(ignoringOtherApps: true)

        transitionOptions = [.crossfade, .allowUserInteraction]
    }

    // MARK: - Lifecycle functions

    deinit {

        Utils.transformAppIntoUIElementMode()

        if let closeHandler = closeHandler {
            DispatchQueue.main.async {
                closeHandler()
            }
        }
    }

    // MARK: - NSViewController overrides

    override func viewWillAppear() {

        setOriginalSizeFor(tabViewItem: tabViewItems[selectedTabViewItemIndex])
        animateTabViewTransitionTo(tabViewItem: tabViewItems[selectedTabViewItemIndex])

        super.viewWillAppear()
    }

    // MARK: - NSTabViewDelegate

    override func tabView(_ tabView: NSTabView, willSelect tabViewItem: NSTabViewItem?) {

        super.tabView(tabView, willSelect: tabViewItem)

        if let tabViewItem = tabViewItem {
            setOriginalSizeFor(tabViewItem: tabViewItem)
        }
    }

    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {

        super.tabView(tabView, didSelect: tabViewItem)

        if let tabViewItem = tabViewItem {
            animateTabViewTransitionTo(tabViewItem: tabViewItem)
        }
    }

    // MARK: - Private functions

    private func setOriginalSizeFor(tabViewItem: NSTabViewItem) {

        if (originalSizes[tabViewItem] == nil) {
            originalSizes[tabViewItem] = tabViewItem.view?.frame.size
        }
    }

    private func animateTabViewTransitionTo(tabViewItem: NSTabViewItem) {

        guard let window = view.window else { return }

        if let size = originalSizes[tabViewItem] {
            window.title = tabViewItem.label

            let contentFrame = window.frameRect(forContentRect: NSMakeRect(0.0, 0.0, size.width, size.height))
            var frame = window.frame

            frame.origin.y += (frame.height - contentFrame.height)
            frame.size = contentFrame.size
            
            window.setFrame(frame, display: false, animate: true)
        }
    }

}
