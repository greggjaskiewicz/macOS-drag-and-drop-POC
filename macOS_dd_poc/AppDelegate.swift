//
//  AppDelegate.swift
//  Draggie Viewer
//
//  Created by Gregg Jaskiewicz on 27/09/2017.
//  Copyright © 2017 k4lab. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func addItemAction(_ sender: Any) {
        print("foo")
    }

}
