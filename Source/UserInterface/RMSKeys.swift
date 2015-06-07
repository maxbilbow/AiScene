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
   
    
/// Contains Keys control mapping for a desktop interface.
///
/// For example, the following gives a forward momentum of '2' when 'w' is pressed, and 0 when 'w' is released:
///
///   let MOVE_SPEED: (on:RMFloat,off:RMFloat) = (2, 0)
///   var key = RMKey(self, action: "forward", characters: "w", speed: MOVE_SPEED)
///
/// The RMSActionProcessor class handles the application of the human term "forward", regardless of interface used. See also `RMXDPad` for iOS.
///
/// See also: `RMKeys` and  `RMSActionProcessor`.
class RMSKeys : RMXInterface {
    
    
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
    static let MOVE_SPEED: (on:RMFloat,off:RMFloat) = (RMXInterface.moveSpeed, 0)
    static let LOOK_SPEED: (on:RMFloat,off:RMFloat) = (RMXInterface.lookSpeed * -10, 0)
    
    ///Key settings
    lazy var keys: [ RMKey ] = [
    
    // Basic Movement
    RMKey(self, action: UserAction.MOVE_FORWARD, characters: "w", speed: MOVE_SPEED),
    RMKey(self, action: UserAction.MOVE_BACKWARD, characters: "s", speed: MOVE_SPEED),
    RMKey(self, action: UserAction.MOVE_LEFT, characters: "a", speed: MOVE_SPEED),
    RMKey(self, action: UserAction.MOVE_RIGHT, characters: "d", speed: MOVE_SPEED),
    RMKey(self, action: UserAction.MOVE_UP, characters: "e", speed: MOVE_SPEED),
    RMKey(self, action: UserAction.MOVE_DOWN, characters: "q", speed: MOVE_SPEED),
    RMKey(self, action: UserAction.ROLL_LEFT, characters: "z", speed: LOOK_SPEED),
    RMKey(self, action: UserAction.ROLL_RIGHT, characters: "x", speed: LOOK_SPEED),
    RMKey(self, action: UserAction.JUMP, characters: " ", speed: ON_KEY_UP),
    RMKey(self, action: UserAction.ROTATE, characters: MOVE_CURSOR_PASSIVE, isRepeating: false,speed: LOOK_SPEED),
    
    //Interactions
    RMKey(self, action: THROW_ITEM + GRAB_ITEM, characters: LEFT_CLICK, isRepeating: false, speed: ON_KEY_UP),
    RMKey(self, action: THROW_ITEM + GRAB_ITEM, characters: RIGHT_CLICK, isRepeating: false,  speed: ON_KEY_UP),
    RMKey(self, action: UserAction.BOOM, characters: "b", isRepeating: false,  speed: ON_KEY_UP),
    
    //Environmentals
    RMKey(self, action: UserAction.TOGGLE_GRAVITY, characters: "g", isRepeating: false,speed: ON_KEY_UP),
    //RMKey(self, action: UserAction."toggleGravity", characters: "G", isRepeating: false,speed: ON_KEY_UP),
    RMKey(self, action: UserAction.TOGGLE_AI, characters: "A", isRepeating: false,speed: ON_KEY_UP),
    RMKey(self, action: UserAction.RESET, characters: "R", isRepeating: false,speed: ON_KEY_UP),
    RMKey(self, action: UserAction.RESET_CAMERA, characters: "r", isRepeating: false,speed: ON_KEY_UP),
    
    //Interface options
    RMKey(self, action: UserAction.LOCK_CURSOR, characters: "m", isRepeating: false, speed: ON_KEY_UP),
    RMKey(self, action: UserAction.NEXT_CAMERA, characters: ".", isRepeating: false, speed: ON_KEY_DOWN),
    RMKey(self, action: UserAction.PREV_CAMERA, characters: ",", isRepeating: false, speed: ON_KEY_DOWN),
    RMKey(self, action: UserAction.PAUSE_GAME, characters: "p", isRepeating: false, speed: ON_KEY_UP),
    RMKey(self, action: UserAction.PAUSE_GAME, characters: KEY_ESCAPE, isRepeating: false, speed: ON_KEY_UP),
    RMKey(self, action: UserAction.KEYBOARD_LAYOUT, characters: "k", isRepeating: false, speed: ON_KEY_UP),
    RMKey(self, action: UserAction.NEW_GAME, characters: "N", isRepeating: false, speed: ON_KEY_UP),
    
    //Misc: generically used for testing
    RMKey(self, action: UserAction.GET_INFO, characters: "i", isRepeating: false, speed: ON_KEY_DOWN), //Prints to terminal when testing
    RMKey(self, action: UserAction.TOGGLE_SCORES, characters: "S", isRepeating: false, speed: ON_KEY_UP),
    RMKey(self, action: UserAction.ZOOM_IN, characters: "=", isRepeating: true, speed: MOVE_SPEED),
    RMKey(self, action: UserAction.ZOOM_OUT, characters: "-", isRepeating: true, speed: MOVE_SPEED),
    RMKey(self, action: UserAction.INCREASE, characters: "+", isRepeating: false, speed: ON_KEY_DOWN),
    RMKey(self, action: UserAction.DECREASE, characters: "_", isRepeating: false, speed: ON_KEY_DOWN),
    RMKey(self, action: UserAction.DEBUG_NEXT, characters: KEY_TAB, isRepeating: false, speed: ON_KEY_UP),
    RMKey(self, action: UserAction.DEBUG_PREVIOUS, characters: KEY_SHIFT_TAB, isRepeating: false, speed: ON_KEY_UP),
        
    //Unassigned
    RMKey(self, action: "key up", characters: KEY_UP, isRepeating: false, speed: ON_KEY_DOWN),
    RMKey(self, action: "key down", characters: KEY_DOWN, isRepeating: false, speed: ON_KEY_DOWN),
    RMKey(self, action: "key left", characters: KEY_LEFT, isRepeating: false, speed: ON_KEY_DOWN),
    RMKey(self, action: "key right", characters: KEY_RIGHT, isRepeating: false, speed: ON_KEY_DOWN)
    
    ]
    
  
    
    override func updateScoreboard() {
        super.updateScoreboard()
        
    }
    
    override func viewDidLoad() {
        RMXInterface.lookSpeed *= -1
        
        super.viewDidLoad()
    }
    
    override func setUpViews() {
        super.setUpViews()
        self.scoreboard.alphaValue = 0.5
    }
    
    override func pauseGame(sender: AnyObject?) -> Bool {
        if super.pauseGame(sender) {
            self.actionProcessor.isMouseLocked = false
            return true
        } else {
            return false
        }
    }
    
    func set(action a: RMInputKeyValue, characters k: String ) {
        let newKey = RMKey(self, action: a, characters: k)
        var exists = false
        for key in self.keys {
            if key.action == a {
                key.set(k)
                exists = true
                break
            }
        }
        if !exists {
            self.keys.append(newKey)
        }
    }
    
    func get(forAction action: RMInputKeyValue?) -> RMKey? {
        for key in keys {
            if key.action == action {
                return key
            }
        }
        return nil
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
    
    func match(chr: String) -> NSMutableArray {
        let keys: NSMutableArray = NSMutableArray(capacity: chr.pathComponents.count)
        for key in self.keys {
            RMLog(key.description)
            for str in chr.pathComponents {
                if key.characters == str {
                    keys.addObject(key)
                }
            }
            
        }
        return keys
    }
    
    func match(value: UInt16) -> RMKey? {
        for key in keys {
            RMLog(key.description)
            if key.charToInt == Int(value) {
                return key
            }
        }
        return nil
    }
    
    var origin: NSPoint{
        let size = (self.gameView?.frame.size)!//.window!.frame
        let point = (self.gameView?.window!.frame.origin)!
        let x = point.x + size.width / 2
        let y = point.y + size.height / 2
        return NSPoint(x: x, y: y)
    }
    var lastPos: NSPoint = NSEvent.mouseLocation()
    var mouseDelta: NSPoint {
        let newPos = NSEvent.mouseLocation()
        let lastPos = self.lastPos
//        RMLog("  OLD: \(lastPos.x), \(lastPos.y)\n  New: \(newPos.x), \(newPos.y)")
        let delta = NSPoint(
            x: -(newPos.x - lastPos.x),// - self.mousePos.x,
            y: newPos.y - lastPos.y//self.mousePos.y
        )
//        CGDisplayHideCursor(0)
        CGAssociateMouseAndMouseCursorPosition(0)
        CGWarpMouseCursorPosition(self.origin)
        
        /* perform your application’s main loop */
        self.lastPos = NSEvent.mouseLocation()
        CGAssociateMouseAndMouseCursorPosition (1)
//        CGDisplayShowCursor(1)
        
        return delta
    }
    
    override func update() {
        for key in self.keys {
            key.update()
        }
        super.update()
        
        //self.get(forChar: "mouseMoved")?.actionWithValues([RMFloat(self.mouseDelta.x), RMFloat(self.mouseDelta.y)])
        if self.actionProcessor.isMouseLocked {
            let delta = self.mouseDelta
            self.action(UserAction.LOOK, speed: RMXInterface.lookSpeed, args: delta)
//            RMLog("MOUSE: \(delta.x), \(delta.y)")
            
        }
//        RMLog("\(self.mouseDelta.x), \(self.mouseDelta.y)")
    }
    
    ///Adapt the keyboard for different layouts
    override func setKeyboard(type: KeyboardType = .UK) {
        super.setKeyboard(type: type)
        switch type {
        case .French:
            self.set(action: UserAction.MOVE_FORWARD, characters: "z")
            self.set(action: UserAction.MOVE_LEFT, characters: "q")
            self.set(action: UserAction.MOVE_DOWN, characters: "a")
            self.set(action: UserAction.ROLL_LEFT, characters: "w")
            
            self.set(action: UserAction.NEXT_CAMERA, characters: "=")
            self.set(action: UserAction.PREV_CAMERA, characters: ":")
            
            self.set(action: UserAction.ZOOM_IN, characters: "-")
            self.set(action: UserAction.ZOOM_OUT, characters: ")")
            break
        case .UK:
            self.set(action: UserAction.MOVE_FORWARD, characters: "w")
            self.set(action: UserAction.MOVE_LEFT, characters: "a")
            self.set(action: UserAction.MOVE_DOWN, characters: "q")
            self.set(action: UserAction.ROLL_LEFT, characters: "z")
            
            self.set(action: UserAction.NEXT_CAMERA, characters: ".")
            self.set(action: UserAction.PREV_CAMERA, characters: ",")
            
            self.set(action: UserAction.ZOOM_IN, characters: "=")
            self.set(action: UserAction.ZOOM_OUT, characters: "-")
            break
        default:
            break
        }
    }
}

/// Single mapping for a control on the desktop interface.
/// This maps a most binary commands to the action processor
///
/// See also: `RMKeys` and  `RMSActionProcessor`.
class RMKey {
//    private var _key: String?
    var isPressed: Bool = false
    var action: RMInputKeyValue!
    var characters: String
    var isSpecial = false
    var speed:(on:RMFloat,off:RMFloat)
    var isRepeating: Bool = true
    var values: AnyObject?
    private var keys: RMSKeys
    
    init(_ keys: RMSKeys, action: RMInputKeyValue, characters: String, isRepeating: Bool = true, speed: (on:RMFloat,off:RMFloat) = (1,0), values: AnyObject? = nil) {
        self.keys = keys
        self.action = action
        self.isSpecial = true
        self.characters = characters
        self.speed = speed
        self.isRepeating = isRepeating
        if values != nil {
            self.values = values!
        }
    }
    
    func set(characters: String){
        self.characters = characters
    }
    
    ///Returns true if key was not already pressed, and sets isPressed = true
    func press(object: Any? = nil) -> Bool{
        if self.isRepeating {
            if self.isPressed {
                return true //false
            } else {
                self.isPressed = true
                return true
            }
        } else  {
            self.isPressed = true
            
            return self.keys.action(self.action, speed: self.speed.on, args: object ?? self.values)
        }
    }
    
    func actionWithValues(values: [RMFloat]){
        self.keys.action(self.action, speed: self.speed.on, args: values)
    }
    
    ///Returns true if key was already pressed, and sets isPressed = false
    func release(object: Any? = nil) -> Bool{
        if self.isPressed {
            self.isPressed = false
            return self.keys.action(self.action, speed: self.speed.off, args: self.values)
        } else {
            return true //false
        }
    }
    
    init(name: String){
        fatalError("'\(name)' not recognised in \(__FILE__.lastPathComponent)")
    }
    var charToInt: Int {
        return self.characters.toInt() ?? -1
    }
    
    var description: String {
        return "\(self.action): \(self.characters), speed: \(self.speed), pressed: \(self.isPressed)"
    }
    
    func update(){
        if self.isRepeating && self.isPressed {
            self.keys.action(self.action, speed: self.speed.on, args: self.values)
        }
    }
    
    var print: String {
        return "Action: \(self.action), key: \(self.characters), speed: \(self.speed.on), \(self.speed.off)"
    }
    
}

//func ==(lhs: RMKey, rhs: Int) -> Bool{
//    return lhs.charToInt == rhs
//}
//
//func ==(lhs: RMKey, rhs: String) -> Bool{
//    return lhs.action == rhs
//}
//
//func ==(lhs: RMKey, rhs: RMKey) -> Bool{
//    return lhs.action == rhs.action
//}


extension GameView {
    
    var keys: RMSKeys {
        return self.interface as! RMSKeys
    }
    
    override func keyDown(theEvent: NSEvent) {
        if let key = self.keys.forEvent(theEvent) {
            if !key.press() {
                RMLog("ERROR on Key Down for \(key.print)")
            }
        } else {
            if let n = theEvent.characters?.toInt() {
                self.keys.keys.append(RMKey(self.keys, action: theEvent.characters!, characters: "\(n)", isRepeating: false, speed: RMSKeys.ON_KEY_DOWN))
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
    
    
}

extension GameView {
    override func rightMouseUp(theEvent: NSEvent) {
        

        if self.keys.get(forChar: RMSKeys.RIGHT_CLICK)?.release() ?? false {
            let p = self.convertPoint(theEvent.locationInWindow, fromView: nil)
            if !self.interface!.processHit(point: p, type: RMXInterface.THROW_ITEM) {
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
            if !self.interface!.processHit(point: p, type: RMXInterface.THROW_ITEM) {
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
            if !self.interface!.processHit(point: p, type: RMXInterface.GRAB_ITEM) {
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
            if !self.interface!.processHit(point: p, type: RMXInterface.GRAB_ITEM) {
                super.mouseDown(theEvent)
            }
            RMLog("UP hit successful: \(p)", id: "keys")
        } else {
            //            RMLog("UP hit unSuccessful: \(p)", id: "keys")
           super.mouseDown(theEvent)
        }
        
    }
    

}


