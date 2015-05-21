//
//  RMSKeys.swift
//  RattleGL
//
//  Created by Max Bilbow on 22/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

#if OSX
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
    
    ///Key down, Key up options
    static let ON_KEY_DOWN: (on:RMFloat,off:RMFloat) = (1,0)
    static let ON_KEY_UP: (on:RMFloat,off:RMFloat) = (0,1)
    static let MOVE_SPEED: (on:RMFloat,off:RMFloat) = (RMXInterface.moveSpeed * 2, 0)
    static let LOOK_SPEED: (on:RMFloat,off:RMFloat) = (RMXInterface.lookSpeed * -10, 0)
    
    ///Key settings
    lazy var keys: [ RMKey ] = [
    
    // Basic Movement
    RMKey(self, action: "forward", characters: "w", speed: MOVE_SPEED),
    RMKey(self, action: "back", characters: "s", speed: MOVE_SPEED),
    RMKey(self, action: "left", characters: "a", speed: MOVE_SPEED),
    RMKey(self, action: "right", characters: "d", speed: MOVE_SPEED),
    RMKey(self, action: "up", characters: "e", speed: MOVE_SPEED),
    RMKey(self, action: "down", characters: "q", speed: MOVE_SPEED),
    RMKey(self, action: "rollLeft", characters: "z", speed: LOOK_SPEED),
    RMKey(self, action: "rollRight", characters: "x", speed: LOOK_SPEED),
    RMKey(self, action: "jump", characters: " "),
    RMKey(self, action: "look", characters: "mouseMoved", isRepeating: false,speed: LOOK_SPEED),
    
    //Interactions
    RMKey(self, action: "grab", characters: "Mouse 1", isRepeating: false, speed: ON_KEY_UP),
    RMKey(self, action: "throwItem", characters: "Mouse 2", isRepeating: false,  speed: (0,20)),
    RMKey(self, action: "explode", characters: "b", isRepeating: false,  speed: ON_KEY_UP),
    
    //Environmentals
    RMKey(self, action: "toggleAllGravity", characters: "g", isRepeating: false,speed: ON_KEY_UP),
    //RMKey(self, action: "toggleGravity", characters: "G", isRepeating: false,speed: ON_KEY_UP),
    RMKey(self, action: "toggleAI", characters: "A", isRepeating: false,speed: ON_KEY_UP),
    RMKey(self, action: "reset", characters: "R", isRepeating: false,speed: ON_KEY_UP),
    
    //Interface options
    RMKey(self, action: "lockMouse", characters: "m", isRepeating: false, speed: ON_KEY_UP),
    RMKey(self, action: "nextCamera", characters: ".", isRepeating: false, speed: ON_KEY_DOWN),
    RMKey(self, action: "previousCamera", characters: ",", isRepeating: false, speed: ON_KEY_DOWN),
    
    //Misc: generically used for testing
    RMKey(self, action: "information", characters: "i", isRepeating: false,speed: ON_KEY_DOWN), //Prints to terminal when testing
    RMKey(self, action: "zoomIn", characters: "=", isRepeating: true, speed: MOVE_SPEED),
    RMKey(self, action: "zoomOut", characters: "-", isRepeating: true, speed: MOVE_SPEED)
    ]
    
    override func viewDidLoad(coder: NSCoder!) {
        super.viewDidLoad(coder)
        RMXInterface.lookSpeed *= -1
    }
    
    func set(action a: String, characters k: String ) {
        let newKey = RMKey(self, action: a, characters: k)
        var exists = false
        for key in self.keys {
            if key.action == a {
                key.set(k)
                exists = true
                break
            }
            if !exists {
                self.keys.append(newKey)
            }
        }
    }
    
    func get(action: String?) -> RMKey? {
        for key in keys {
            if key.action == action {
                return key
            }
        }
        return nil
    }
    
    func get(forChar char: String?) -> RMKey? {
        for key in keys {
            if key.characters == char {
                return key
            }
        }
        return nil
    }
    
    func match(chr: String) -> NSMutableArray {
        let keys: NSMutableArray = NSMutableArray(capacity: chr.pathComponents.count)
        for key in self.keys {
            //RMXLog(key.description)
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
            //RMXLog(key.description)
            if key.charToInt == Int(value) {
                return key
            }
        }
        return nil
    }
//    var mousePos: NSPoint{// = NSPoint(x: NSEvent.mouseLocation().x, y: NSEvent.mouseLocation().y)
//        return self.actionProcessor.mousePos
//    }
    
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
//        RMXLog("  OLD: \(lastPos.x), \(lastPos.y)\n  New: \(newPos.x), \(newPos.y)")
        let delta = NSPoint(
            x: newPos.x - lastPos.x,// - self.mousePos.x,
            y: newPos.y - lastPos.y//self.mousePos.y
        )
//        CGDisplayHideCursor(0)
        CGAssociateMouseAndMouseCursorPosition(0)
        CGWarpMouseCursorPosition(self.origin)
//        CGDisplayMoveCursorToPoint(displayAtPoint(screenPoint), self.origin)
        
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
            self.action(action: "look", speed: RMXInterface.lookSpeed, point: [RMFloat(delta.x), RMFloat(delta.y)])
//            RMXLog("MOUSE: \(delta.x), \(delta.y)")
            
        }
//        RMXLog("\(self.mouseDelta.x), \(self.mouseDelta.y)")
    }
}

/// Single mapping for a control on the desktop interface.
/// This maps a most binary commands to the action processor
///
/// See also: `RMKeys` and  `RMSActionProcessor`.
class RMKey {
//    private var _key: String?
    var isPressed: Bool = false
    var action: String
    var characters: String
    var isSpecial = false
    var speed:(on:RMFloat,off:RMFloat)
    var isRepeating: Bool = true
    var values: [RMFloat] = []
    private var keys: RMSKeys
    
    init(_ keys: RMSKeys, action: String, characters: String, isRepeating: Bool = true, speed: (on:RMFloat,off:RMFloat) = (1,0), values: [RMFloat]? = nil) {
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
    func press() -> Bool{
        if self.isRepeating {
            if self.isPressed {
                return false
            } else {
                self.isPressed = true
                return true
            }
        } else  {
            self.isPressed = true
            self.keys.action(action: self.action, speed: self.speed.on, point: self.values)
            return true
        }
    }
    
    func actionWithValues(values: [RMFloat]){
        self.keys.action(action: self.action, speed: self.speed.on, point: values)
    }
    
    ///Returns true if key was already pressed, and sets isPressed = false
    func release() -> Bool{
        if self.isPressed {
            self.isPressed = false
            self.keys.action(action: self.action, speed: self.speed.off, point: self.values)
            return true
        } else {
            return false
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
            self.keys.action(action: self.action, speed: self.speed.on, point: self.values)
        }
    }
}

func ==(lhs: RMKey, rhs: Int) -> Bool{
    return lhs.charToInt == rhs
}

func ==(lhs: RMKey, rhs: String) -> Bool{
    return lhs.action == rhs
}

func ==(lhs: RMKey, rhs: RMKey) -> Bool{
    return lhs.action == rhs.action
}


extension GameView {
    
    var keys: RMSKeys {
        return self.interface as! RMSKeys
    }
    
    override func keyDown(theEvent: NSEvent) {
        if let key = self.keys.get(forChar: theEvent.characters) {
            if key.press() {
                //RMXLog(key.description)
                
            }
        } else {
            super.keyDown(theEvent)
        }
        
    }
    
    override func keyUp(theEvent: NSEvent) {
        if let key = self.keys.get(forChar: theEvent.characters) {
            if key.release() {
                //RMXLog(key.description)
            }
        } else {
            super.keyUp(theEvent)
        }
    }
    
    
    
    /*
    override func mouseMoved(theEvent: NSEvent) {
        keys.get(forChar: "mouseMoved")?.actionWithValues([RMFloat(theEvent.deltaX), RMFloat(theEvent.deltaY)])
        RMXLog("\(theEvent.deltaX), \(theEvent.deltaY)")
    }
    
    override func cursorUpdate(event: NSEvent) {
        RMXLog("\(event.deltaX), \(event.deltaY)")
        keys.get(forChar: "mouseMoved")?.actionWithValues([RMFloat(event.deltaX), RMFloat(event.deltaY)])
        super.cursorUpdate(event)
    }
    
    override func mouseDragged(theEvent: NSEvent) {
       // keys.get(forChar: "mouseMoved")?.actionWithValues([RMFloat(theEvent.deltaX), RMFloat(theEvent.deltaY)])
        //RMXLog("\(theEvent.deltaX), \(theEvent.deltaY)")
        super.mouseDragged(theEvent)
    }
*/
}

extension GameView {
    override func rightMouseUp(theEvent: NSEvent) {
        self.keys.get(forChar: "Mouse 2")?.release()
        super.rightMouseUp(theEvent)
    }
    
    override func rightMouseDown(theEvent: NSEvent) {
//        self.keys.get(forChar: "Mouse 2")?.press()
        self.interface!.actionProcessor.manipulate(action: "throw", sprite: self.interface!.activeSprite, speed: 18000)
        super.rightMouseDown(theEvent)
    }
    
    
    override func mouseDown(theEvent: NSEvent) {
        /* Called when a mouse click occurs */
        
        // check what nodes are clicked
        let p = self.convertPoint(theEvent.locationInWindow, fromView: nil)
        if let hitResults = self.hitTest(p, options: nil) {
            // check that we clicked on at least one object
            if hitResults.count > 0 {
                // retrieved the first clicked object
                let result: AnyObject! = hitResults[0]
                
                self.interface!.actionProcessor.manipulate(action: "throw", sprite: self.interface!.activeSprite, object: result, speed: 18000)
            
                // get its material
                let material = result.node!.geometry!.firstMaterial!
                
                // highlight it
                SCNTransaction.begin()
                SCNTransaction.setAnimationDuration(0.5)
                
                // on completion - unhighlight
                SCNTransaction.setCompletionBlock {
                    SCNTransaction.begin()
                    SCNTransaction.setAnimationDuration(0.5)
                    
                    material.emission.contents = NSColor.blackColor()
                    
                    SCNTransaction.commit()
                }
                
                material.emission.contents = NSColor.redColor()
                
                SCNTransaction.commit()
            }
        }
        super.mouseDown(theEvent)
    }

}

#endif

