//
//  GameView.swift
//  SceneCubo
//
//  Created by Max Bilbow on 05/04/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import SceneKit
import Foundation
import SpriteKit
//import RMXKit

class GameView: SCNView  {

    private static var _current: GameView?
    static var current: GameView! {
        return _current ?? GameViewController.current.gameView!
    }
    
    
    
    #if OSX
        
        override func keyDown(theEvent: NSEvent) {
            let interface = RMX.DesktopInput.current as! RMX.DesktopInput
            if let key = interface.forEvent(theEvent) {
                if !key.press() {
                    RMLog("ERROR on Key Down for \(key.print)")
                }
            } else {
                if let n = Int((theEvent.characters)!) {
                    interface.keys.append(RMX.RMKey(action: nil, description: theEvent.characters!, characters: "\(n)", isRepeating: false, speed: RMX.DesktopInput.ON_KEY_DOWN))
                } else {
                    super.keyDown(theEvent)
                }
            }
        }
        
        override func keyUp(theEvent: NSEvent) {
            if let key = (RMXInterface.current as? RMX.DesktopInput)?.forEvent(theEvent) {
                RMLog("Key recognised: \(key.print) \n\(theEvent.characters!.hash) == \(theEvent.keyCode) == \(theEvent.characters!)",id: "keys")
                if !key.release() {
                    RMLog("ERROR on Key Up for \(key.print)")
                }
            } else {
                //            RM("new key added:\n\n \(theEvent.description)")
                RMLog("Key unrecognised \(theEvent.characters!.hash) == \(theEvent.keyCode) == \(theEvent.characters!)",id: "keys")
                
                super.keyUp(theEvent)
            }
        }
        
        
        override func rightMouseUp(theEvent: NSEvent) {
            let interface = RMX.DesktopInput.current as! RMX.DesktopInput
            if interface.get(forChar: RMX.DesktopInput.RIGHT_CLICK)?.release() ?? false {
                let p = self.convertPoint(theEvent.locationInWindow, fromView: nil)
                if !interface.processHit(point: p, type: .THROW_ITEM) {
                    super.rightMouseUp(theEvent)
                }
                
                RMLog("UP hit successful: \(p)", id: "keys")
            } else {
                //            RMLog("UP hit unSuccessful: \(p)", id: "keys")
                super.rightMouseUp(theEvent)
            }
            
        }
        
        override func rightMouseDown(theEvent: NSEvent) {
            let interface = RMXInterface.current as! RMX.DesktopInput
            if interface.get(forChar: RMX.DesktopInput.RIGHT_CLICK)?.press() ?? false {
                let p = self.convertPoint(theEvent.locationInWindow, fromView: nil)
                if !interface.processHit(point: p, type: .THROW_ITEM) {
                    super.rightMouseDown(theEvent)
                }
                RMLog("UP hit successful: \(p)", id: "keys")
            } else {
                //            RMLog("UP hit unSuccessful: \(p)", id: "keys")
                super.rightMouseDown(theEvent)
            }
            
        }
        
        override func mouseUp(theEvent: NSEvent) {
            let interface = RMXInterface.current as! RMX.DesktopInput
            if interface.get(forChar: RMX.DesktopInput.LEFT_CLICK)?.release() ?? false {
                let p = self.convertPoint(theEvent.locationInWindow, fromView: nil)
                if !interface.processHit(point: p, type: .GRAB_ITEM) {
                    super.mouseUp(theEvent)
                }
                RMLog("UP hit successful: \(p)", id: "keys")
            } else {
                //            RMLog("UP hit unSuccessful: \(p)", id: "keys")
                super.mouseUp(theEvent)
            }
            
        }
        
        override func mouseDown(theEvent: NSEvent) {
            /* Called when a mouse click occurs */
            
            // check what nodes are clicked
            let interface = RMXInterface.current as! RMX.DesktopInput
            if interface.get(forChar: RMX.DesktopInput.LEFT_CLICK)?.press() ?? false {
                let p = self.convertPoint(theEvent.locationInWindow, fromView: nil)
                if !interface.processHit(point: p, type: .GRAB_ITEM) {
                    super.mouseDown(theEvent)
                }
                RMLog("UP hit successful: \(p)", id: "keys")
            } else {
                //            RMLog("UP hit unSuccessful: \(p)", id: "keys")
                super.mouseDown(theEvent)
            }
        }
        
    #endif
    
}
