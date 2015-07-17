//
//  Mono.swift
//  RMXKit
//
//  Created by Max Bilbow on 17/07/2015.
//  Copyright © 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
import SceneKit

public struct Mono {
    public typealias Vector2 = CGVector
    public typealias Vector3 = SCNVector3
    public typealias Vector4 = SCNVector4
    public typealias Matrix4 = SCNMatrix4
    public typealias Quaternion = SCNQuaternion

    /// Removes a gameobject, component or asset.
    public static func Destroy(object: NSObject?) {
        if let transform: Transform = object?.valueForKey("transform") as? Transform {
            print(transform)
        }
    }
    
    /// Destroys the object obj immediately. You are strongly recommended to use Destroy instead.
    public static func DestroyImmediate(object: NSObject?) {
        fatalError("\(__FUNCTION__) not implemented")
    }
    
    /// Makes the object target not be destroyed automatically when loading a new scene.
    public static func DontDestroyOnLoad(object: NSObject?) {
        fatalError("\(__FUNCTION__) not implemented")
    }
    
    /// Returns the first active loaded object of Type type.
    public static func FindObjectOfType(object: NSObject?)	{
        fatalError("\(__FUNCTION__) not implemented")
    }
    
    /// Returns a list of all active loaded objects of Type type.
    public static func FindObjectsOfType(object: NSObject?) {
        fatalError("\(__FUNCTION__) not implemented")
    }
    
    /// Clones the object original and returns the clone.
    public static func Instantiate<T:Object>(object: T) -> T! {
        
//        let src = UnsafeMutablePointer<T>.alloc(sizeof(T))
//        src.initialize(object)
//        
//        let copy = UnsafeMutablePointer<T>.alloc(sizeof(T))
//        memcpy(copy, src, sizeof(T)).memory as? T
//
//        if let object = copy.memory as? GameObject {
//            object.setName()
//        }
        
        return object.clone() as? T
    }

}