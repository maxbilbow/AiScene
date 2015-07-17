//
//  MonoObject.swift
//  RMXKit
//
//  Created by Max Bilbow on 17/07/2015.
//  Copyright © 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation

extension Mono {
    
    public class Object : NSObject {
        
        
        ///	Should the object be hidden, saved with the scene or modifiable by the user?
        var hideFlags: Bool = false
        
        /// The name of the object.
        public var name: String {
            return _name
        }
        private var _name: String!
        
    
        public func clone() -> Object {
//            let aClass: self.classForCoder
//            let aClass: AnyClass = self.classForCoder
            let src = UnsafeMutablePointer<Object>.alloc(sizeof(Object))
            src.initialize(self)
            
            let copy = UnsafeMutablePointer<Object>.alloc(sizeof(Object))
            memcpy(copy, src, sizeof(Object))
            
            return copy.memory

        }
    }
    
}