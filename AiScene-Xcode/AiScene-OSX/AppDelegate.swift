//
//  AppDelegate.swift
//  AiScene-OSX
//
//  Created by Max Bilbow on 20/04/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Cocoa
//import RMXKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    #if DEBUG
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        let interface = RMXInterface.current
            var s = "\napplicationDidFinishLaunching"
            s += "\n           World: \(interface.world.name)"
            print(s, appendNewline: true)
    }
    
    func applicationWillHide(notification: NSNotification) {
        _wasPausedAutomatically = RMXInterface.current.pauseGame()
        
    }
    
    private var _wasPausedAutomatically: Bool = false;
   
    func applicationDidUnhide(notification: NSNotification) {
//        if let interface = RMXInterface.current() {
            var s = "\napplicationDidUnhide"
    //      interface.pauseGame()
            s += "\n   Game if not unpause automatically."
        if _wasPausedAutomatically {
            RMXInterface.current.unPauseGame()
            _wasPausedAutomatically = false
        }
            print(s, appendNewline: true)
//        }
    }

    func applicationDidChangeOcclusionState(notification: NSNotification) {
//        NSLog(notification.description)
        let interface = RMXInterface.current
            print("\napplicationDidChangeOcclusionState")
            if self.window.occlusionState != NSWindowOcclusionState.Visible {
                interface.pauseGame()
            
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
