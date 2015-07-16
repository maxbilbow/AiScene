//
//  GameObject.swift
//  RMXKit
//
//  Created by Max Bilbow on 16/07/2015.
//  Copyright © 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation

@objc public class GameObject : NSObject  {
    static var Count: Int = 0
    
    private var _id: Int = GameObject.Count++
    
    public var id: Int {
        return _id
    }
    
    public var isActive: Bool = true
    
    private var _transform: Transform = Transform()
    
    public var transform: Transform {
        return _transform
    }
    
    private var _scripts: [String:IBehaviour] = [:]
    
    private var _components: [String:Component] = [:]
    
    public func addScript(behaviour: MonoBehaviour){
        
    }
    
    public func SendMessage(message: String, args: AnyObject...) {
        for script in _scripts {
            if script.1.respondsToSelector(Selector(message)) {
//                script.1.Awake?()
                NSObjectController.performSelector(Selector(message), withObject: script.1, afterDelay: 0)
            }
           
        }
    }
    
    public func addComponent<T:Component>(t: T = T()) -> Component {
        t.gameObject = self
        if let script = t as? IBehaviour {
            self._scripts[T.className()] = script
        }
        _components[T.className()] = t
        return t
    }
    
    public func Awake() {
        for script in _scripts {
            script.1.Awake?()
        }
    }
    
    
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