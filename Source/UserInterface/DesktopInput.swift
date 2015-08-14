//
//  RMSKeys.swift
//  RattleGL
//
//  Created by Max Bilbow on 22/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import AppKit
import ApplicationServices
import SceneKit
//import RMXKit

extension RMX {
    typealias DPadOrKeys = DesktopInput

    /// Contains Keys control mapping for a desktop interface.
    ///
    /// For example, the following gives a forward momentum of '2' when 'w' is pressed, and 0 when 'w' is released:
    ///
    ///   let MOVE_SPEED: (on:RMFloat,off:RMFloat) = (2, 0)
    ///   var key = RMKey(action: "forward", characters: "w", speed: MOVE_SPEED)
    ///
    /// The RMSActionProcessor class handles the application of the human term "forward", regardless of interface used. See also `RMXMobileInput` for iOS.
    ///
    /// See also: `RMKeys` and  `RMSActionProcessor`.
    class DesktopInput : Interface {
        
        
        //Non-ASCKI commands
        static let MOVE_CURSOR_PASSIVE: String = "mouseMoved"
        static let LEFT_CLICK: String = "Mouse 1"
        static let RIGHT_CLICK: String = "Mouse 2"
        static let KEY_LEFT: String = "123"
        static let KEY_RIGHT: String = "124"
        static let KEY_DOWN: String = "125"
        static let KEY_UP: String = "126"
        static let KEY_BACKSPACE: String = "\u{7F}"
        static let KEY_ESCAPE: String = "\u{1B}"
        static let KEY_TAB: String = "\t"
        static let KEY_SHIFT_TAB: String = "\tt"
        
        
        ///Key down, Key up options
        static let ON_KEY_DOWN: (on:RMFloat,off:RMFloat) = (1,0)
        static let ON_KEY_UP: (on:RMFloat,off:RMFloat) = (0,1)
        static let TOGGLE: (on:RMFloat,off:RMFloat) = (0,-1)
        static let MOVE_SPEED: (on:RMFloat,off:RMFloat) = (Interface.moveSpeed, 0)
        static let LOOK_SPEED: (on:RMFloat,off:RMFloat) = (-1, 0)
        let lookSpeed: RMFloat = -1
        ///Key settings
        var keys: [ RMKey ] = [
            
        // Basic Movement
        RMKey(action: .MOVE_FORWARD, characters: "w", speed: MOVE_SPEED),
        RMKey(action: .MOVE_BACKWARD, characters: "s", speed: MOVE_SPEED),
        RMKey(action: .MOVE_LEFT, characters: "a", speed: MOVE_SPEED),
        RMKey(action: .MOVE_RIGHT, characters: "d", speed: MOVE_SPEED),
        RMKey(action: .MOVE_UP, characters: "e", speed: MOVE_SPEED),
        RMKey(action: .MOVE_DOWN, characters: "q", speed: MOVE_SPEED),
        RMKey(action: .ROLL_LEFT, characters: "z", speed: (10, 0)),
        RMKey(action: .ROLL_RIGHT, characters: "x", speed: (10, 0)),
        RMKey(action: .JUMP, characters: " ", speed: ON_KEY_UP),
        RMKey(action: .LOOK_AROUND, characters: MOVE_CURSOR_PASSIVE, isRepeating: false,speed: LOOK_SPEED),
        
        //Interactions
        RMKey(action: .THROW_OR_GRAB_UNTRACKED, characters: LEFT_CLICK, isRepeating: false, speed: ON_KEY_UP),
        RMKey(action: .THROW_OR_GRAB_TRACKED, characters: RIGHT_CLICK, isRepeating: false,  speed: ON_KEY_UP),
        RMKey(action: .BOOM, characters: "b", isRepeating: false,  speed: ON_KEY_UP),
        
        //Environmentals
        RMKey(action: .TOGGLE_GRAVITY, characters: "g", isRepeating: false,speed: ON_KEY_UP),
        //RMKey(action: ."toggleGravity", characters: "G", isRepeating: false,speed: ON_KEY_UP),
        RMKey(action: .TOGGLE_AI, characters: "A", isRepeating: false,speed: ON_KEY_UP),
        RMKey(action: .RESET, characters: "R", isRepeating: false,speed: ON_KEY_UP),
        RMKey(action: .RESET_CAMERA, characters: "r", isRepeating: false,speed: ON_KEY_UP),
        
        //Interface options
        RMKey(action: .LOCK_CURSOR, characters: "m", isRepeating: false, speed: ON_KEY_UP),
        RMKey(action: .NEXT_CAMERA, characters: ".", isRepeating: false, speed: ON_KEY_DOWN),
        RMKey(action: .PREV_CAMERA, characters: ",", isRepeating: false, speed: ON_KEY_DOWN),
        RMKey(action: .PAUSE_GAME, characters: "p", isRepeating: false, speed: ON_KEY_UP),
        RMKey(action: .PAUSE_GAME, characters: KEY_ESCAPE, isRepeating: false, speed: ON_KEY_UP),
        RMKey(action: .KEYBOARD_LAYOUT, characters: "k", isRepeating: false, speed: ON_KEY_UP),
        RMKey(action: .NEW_GAME, characters: "N", isRepeating: false, speed: ON_KEY_UP),
        
        //Misc: generically used for testing
        RMKey(action: .GET_INFO, characters: "i", isRepeating: false, speed: ON_KEY_DOWN), //Prints to terminal when testing
        RMKey(action: .TOGGLE_SCORES, characters: "S", isRepeating: false, speed: ON_KEY_UP),
        RMKey(action: .ZOOM_IN, characters: "=", isRepeating: true, speed: (10,0)),
        RMKey(action: .ZOOM_OUT, characters: "-", isRepeating: true, speed: (10,0)),
        RMKey(action: .INCREASE, characters: "+", isRepeating: false, speed: ON_KEY_DOWN),
        RMKey(action: .DECREASE, characters: "_", isRepeating: false, speed: ON_KEY_DOWN),
        RMKey(action: .DEBUG_NEXT, characters: KEY_TAB, isRepeating: false, speed: ON_KEY_UP),
        RMKey(action: .DEBUG_PREVIOUS, characters: KEY_SHIFT_TAB, isRepeating: false, speed: ON_KEY_UP),
            
        //Unassigned
        RMKey(action: nil, description: "key up", characters: KEY_UP, isRepeating: false, speed: ON_KEY_DOWN),
        RMKey(action: nil, description: "key down", characters: KEY_DOWN, isRepeating: false, speed: ON_KEY_DOWN),
        RMKey(action: nil, description: "key left", characters: KEY_LEFT, isRepeating: false, speed: ON_KEY_DOWN),
        RMKey(action: nil, description: "key right", characters: KEY_RIGHT, isRepeating: false, speed: ON_KEY_DOWN)
        
        ]
        

        override func setUpViews() {
            super.setUpViews()
            self.scoreboard.alphaValue = 0.5
        }

        override func pauseGame(sender: AnyObject? = nil) -> Bool {
            self.lockCursor = false
            return super.pauseGame(sender)
        }
        
        func set(action: UserAction?, description string: String = "NULL", characters k: String ) {
            let newKey = RMKey(action: action, description: string, characters: k)
            var exists = false
            for key in self.keys {
                if key.description == newKey.description {
                    key.set(k)
                    exists = true
                    break
                }
            }
            if !exists {
                self.keys.append(newKey)
            }
        }
        
        
        func forEvent(theEvent: NSEvent) -> RMKey? {
            if let key = self.get(forChar: theEvent.characters) {
                return key
            } else if let key = self.get(forCode: theEvent.keyCode) {
                return key
            } else if let key = self.get(forHash: theEvent.hash) {
                return key
            } else {
                return nil
            }
        }
        
        func get(forChar char: String?) -> RMKey? {
            for key in keys {
                if key.characters == char {
                    return key
                }
            }
            return nil
        }
        
        func get(forCode code: UInt16?) -> RMKey? {
            if let code = code {
                for key in keys {
                    if key.characters == "\(code)" {
                        return key
                    }
                }
            }
            return nil
        }
        
        func get(forHash code: Int?) -> RMKey? {
            if let code = code {
                for key in keys {
                    if key.characters == "\(code)" {
                        return key
                    }
                }
            }
            return nil
        }
        
        private var origin: NSPoint{
            let size = (GameViewController.current.gameView?.frame.size)!//.window!.frame
            let point = (GameViewController.current.gameView?.window!.frame.origin)!
            let x = point.x + size.width / 2
            let y = point.y + size.height / 2
            return NSPoint(x: x, y: y)
        }

        private var lastPos: NSPoint = NSEvent.mouseLocation()
        
        private var mouseDelta: NSPoint {
            let newPos = NSEvent.mouseLocation()
            let lastPos = self.lastPos

            let delta = NSPoint(
                x: -(newPos.x - lastPos.x),
                y: newPos.y - lastPos.y
            )

            CGAssociateMouseAndMouseCursorPosition(0)
            CGWarpMouseCursorPosition(self.origin)
            
            /* perform your application’s main loop */
            self.lastPos = NSEvent.mouseLocation()
            CGAssociateMouseAndMouseCursorPosition (1)
            
            return delta
        }
        
        
        override func update() {
            for key in self.keys {
                key.update()
            }
            super.update()
            
            if self.lockCursor {
                let delta = self.mouseDelta
                ActionProcessor.current.action(.LOOK_AROUND, speed: self.lookSpeed, args: delta)
            }
        }
        
        ///Adapt the keyboard for different layouts
        override func setKeyboard(type: KeyboardType = .UK) {
            super.setKeyboard(type)
            switch type {
            case .French:
                self.set(.MOVE_FORWARD, characters: "z")
                self.set(.MOVE_LEFT, characters: "q")
                self.set(.MOVE_DOWN, characters: "a")
                self.set(.ROLL_LEFT, characters: "w")
                
                self.set(.NEXT_CAMERA, characters: "=")
                self.set(.PREV_CAMERA, characters: ":")
                
                self.set(.ZOOM_IN, characters: "-")
                self.set(.ZOOM_OUT, characters: ")")
                break
            case .UK:
                self.set(.MOVE_FORWARD, characters: "w")
                self.set(.MOVE_LEFT, characters: "a")
                self.set(.MOVE_DOWN, characters: "q")
                self.set(.ROLL_LEFT, characters: "z")
                
                self.set(.NEXT_CAMERA, characters: ".")
                self.set(.PREV_CAMERA, characters: ",")
                
                self.set(.ZOOM_IN, characters: "=")
                self.set(.ZOOM_OUT, characters: "-")
                break
            default:
                break
            }
        }
    }


}



