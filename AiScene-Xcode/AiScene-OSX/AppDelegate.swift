//
//  AppDelegate.swift
//  AiScene-OSX
//
//  Created by Max Bilbow on 20/04/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }
    
    func applicationWillHide(notification: NSNotification) {
        
    }

    func applicationDidChangeOcclusionState(notification: NSNotification) {
//        NSLog(notification.description)
        
    }
}
