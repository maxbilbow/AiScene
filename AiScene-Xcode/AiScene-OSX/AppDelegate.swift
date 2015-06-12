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
    
    var interface: RMXInterface! {
        return (self.window.contentView.subviews.first as? GameView)?.interface
    }
    
    #if DEBUG
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        var s = "\napplicationDidFinishLaunching"
        s += "\n           World: \(self.interface.world.name)"
        print(s, appendNewline: true)
    }
    
    func applicationWillHide(notification: NSNotification) {
        var s = "\napplicationWillHide"
        self.interface.pauseGame()
        s += "\n   Game was paused"
        print(s, appendNewline: true)
    }
    
    func applicationDidUnhide(notification: NSNotification) {
        var s = "\napplicationDidUnhide"
//        self.interface.pauseGame()
        s += "\n   Game if not unpause automatically."
        print(s, appendNewline: true)
    }

    func applicationDidChangeOcclusionState(notification: NSNotification) {
//        NSLog(notification.description)
        
        print("\napplicationDidChangeOcclusionState")
        if self.window.occlusionState != NSWindowOcclusionState.Visible {
            self.interface.pauseGame()
        }
        
    }
    
    func applicationDidBecomeActive(notification: NSNotification) {
        print("\napplicationDidBecomeActive", appendNewLine: true)
    }
    
    func applicationWillTerminate(notification: NSNotification) {
        var s = "\napplicationWillTerminate"
        s += "\n   Game will be archived?"
        print(s, appendNewline: true)
    }
    
    func applicationDidChangeScreenParameters(notification: NSNotification) {
        print("\napplicationDidChangeScreenParameters", appendNewLine: true)
    }
    
    
    #endif
}
