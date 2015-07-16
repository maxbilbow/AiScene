//
//  Component.swift
//  RMXKit
//
//  Created by Max Bilbow on 16/07/2015.
//  Copyright © 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation

@objc public class Component : NSObject {
    /// Enabled Behaviours are Updated, disabled Behaviours are not.
    var enabled: Bool = true
    ///	Has the Behaviour had enabled called.
    var isActiveAndEnabled: Bool {
        return self.enabled && self.gameObject.isActive
    }
    /// The game object this component is attached to. A component is always attached to a game object.
    var gameObject: GameObject!
    /// The tag of this game object.
    var tag: String = ""
    /// The Transform attached to this GameObject (null if there is none attached).
    var transform: Transform {
        return self.gameObject.transform
    }
    ///	Should the object be hidden, saved with the scene or modifiable by the user?
    var hideFlags: Bool = false
    /// The name of the object.
    var name: String = ""
    
    
    public func BroadcastMessage(){} /// Calls the method named methodName on every MonoBehaviour in this game object or any of its children.
    public func CompareTag(){} /// Is this game object tagged with tag ?
    public func GetComponent(){} /// Returns the component of Type type if the game object has one attached, null if it doesn't.
    public func GetComponentInChildren(){} /// Returns the component of Type type in the GameObject or any of its children using depth first search.
    public func GetComponentInParent(){} /// Returns the component of Type type in the GameObject or any of its parents.
    public func GetComponents(){} /// Returns all components of Type type in the GameObject.
    public func GetComponentsInChildren(){} /// Returns all components of Type type in the GameObject or any of its children.
    public func GetComponentsInParent(){} /// Returns all components of Type type in the GameObject or any of its parents.
    public func SendMessage(){} /// Calls the method named methodName on every MonoBehaviour in this game object.
    public func SendMessageUpwards(){} /// Calls the method named methodName on every MonoBehaviour in this game object and on every ancestor of the behaviour.
    public func GetInstanceID(){} /// Returns the instance id of the object.
    public func ToString(){} /// Returns the name of the game object.

   
}