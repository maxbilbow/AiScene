//
//  RMKey.swift
//  AiScene
//
//  Created by Max Bilbow on 09/06/2015.
//  Copyright © 2015 Rattle Media. All rights reserved.
//

import Foundation
//import RMXKit
extension RMX {
    /// Single mapping for a control on the desktop interface.
    /// This maps a most binary commands to the action processor
    ///
    /// See also: `RMKeys` and  `RMSActionProcessor`.

    @available(OSX 10.9, *)
    class RMKey : CustomStringConvertible{

        var isPressed: Bool = false
        private var asString = false
        private var action: UserAction?
        private var string: String
        var characters: String

        var speed:(on:RMFloat,off:RMFloat)
        var isRepeating: Bool = true
        var values: AnyObject?
    //    private var keys: RMSKeys
        
        init(action: UserAction?, description: String? = nil, characters: String, isRepeating: Bool = true, speed: (on:RMFloat,off:RMFloat) = (1,0), values: AnyObject? = nil) {
    //        self.keys = keys
            self.action = action
            self.string = action?.description ?? description!
            if action == nil {
                self.asString = true
            }
            
            self.characters = characters
            self.speed = speed
            self.isRepeating = isRepeating
            self.values = values
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
                if asString {
                    return ActionProcessor.current.action(self.string, speed: self.speed.on, args: object ?? self.values)
                } else {
                    return ActionProcessor.current.action(self.action, speed: self.speed.on, args: object ?? self.values)
                }
            }
        }
        
        //    func actionWithValues(values: [RMFloat]){
        //        self.keys.action(self.action, speed: self.speed.on, args: values)
        //    }
        
        ///Returns true if key was already pressed, and sets isPressed = false
        func release(object: Any? = nil) -> Bool{
            if self.isPressed {
                self.isPressed = false
                if asString {
                    return ActionProcessor.current.action(self.string, speed: self.speed.off, args: self.values)
                } else {
                    return ActionProcessor.current.action(self.action, speed: self.speed.off, args: self.values)
                }
                
            } else {
                return true //false
            }
        }
        
        init(name: String){
            fatalError("'\(name)' not recognised")
        }
        
        
        var description: String {
            return self.string
        }
        
        func update(){
    //        NSLog(self.print)
            if self.isRepeating && self.isPressed {
                if asString {
                    ActionProcessor.current.action(self.string, speed: self.speed.on, args: self.values)
                } else {
                    ActionProcessor.current.action(self.action, speed: self.speed.on, args: self.values)
                }
                
            }
        }
        
        var print: String {
            return "Action: \(self.action), key: \(self.characters), speed: \(self.speed.on), \(self.speed.off)"
        }
        
    }
}

