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

class GameView: SCNView  {
    
    @available(OSX 10.10, *)
    var world: RMSWorld? {
        return self.interface?.world
    }
    
    @available(OSX 10.10, *)
    var activeSprite: RMXSprite? {
        return self.world?.activeSprite
    }
    
    @available(OSX 10.10, *)
    var interface: RMXInterface? {
        return (self.gvc as? GameViewController)?.interface
    }
    
    

    var gvc: ViewController!
    
    #if OSX
        
        @available(OSX 10.10, *)
        var keys: RMSKeys {
            return self.interface as! RMSKeys
        }
        
        
        override func keyDown(theEvent: NSEvent) {
            if let key = self.keys.forEvent(theEvent) {
                if !key.press() {
                    RMLog("ERROR on Key Down for \(key.print)")
                }
            } else {
                if let n = Int((theEvent.characters)!) {
                    self.keys.keys.append(RMKey(self.keys, action: nil, description: theEvent.characters!, characters: "\(n)", isRepeating: false, speed: RMSKeys.ON_KEY_DOWN))
                } else {
                    super.keyDown(theEvent)
                }
            }
            
        }
        
        override func keyUp(theEvent: NSEvent) {
            if let key = self.keys.forEvent(theEvent) {
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
            if self.keys.get(forChar: RMSKeys.RIGHT_CLICK)?.release() ?? false {
                let p = self.convertPoint(theEvent.locationInWindow, fromView: nil)
                if !self.interface!.processHit(point: p, type: .THROW_ITEM) {
                    super.rightMouseUp(theEvent)
                }
                
                RMLog("UP hit successful: \(p)", id: "keys")
            } else {
                //            RMLog("UP hit unSuccessful: \(p)", id: "keys")
                super.rightMouseUp(theEvent)
            }
        }
        
        override func rightMouseDown(theEvent: NSEvent) {
            if self.keys.get(forChar: RMSKeys.RIGHT_CLICK)?.press() ?? false {
                let p = self.convertPoint(theEvent.locationInWindow, fromView: nil)
                if !self.interface!.processHit(point: p, type: .THROW_ITEM) {
                    super.rightMouseDown(theEvent)
                }
                RMLog("UP hit successful: \(p)", id: "keys")
            } else {
                //            RMLog("UP hit unSuccessful: \(p)", id: "keys")
                super.rightMouseDown(theEvent)
            }
        }
        
        override func mouseUp(theEvent: NSEvent) {
            if self.keys.get(forChar: RMSKeys.LEFT_CLICK)?.release() ?? false {
                let p = self.convertPoint(theEvent.locationInWindow, fromView: nil)
                if !self.interface!.processHit(point: p, type: .GRAB_ITEM) {
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

            if self.keys.get(forChar: RMSKeys.LEFT_CLICK)?.press() ?? false {
                let p = self.convertPoint(theEvent.locationInWindow, fromView: nil)
                if !self.interface!.processHit(point: p, type: .GRAB_ITEM) {
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
