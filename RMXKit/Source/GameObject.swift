//
//  GameObject.swift
//  RMXKit
//
//  Created by Max Bilbow on 16/07/2015.
//  Copyright © 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
import SceneKit
extension Mono {
    public class GameObject : Object {
        static var Count: Int = 0
        private static var _gameObjects: [String:GameObject] = [:]
        public static var gameObjects: [String:GameObject] {//Array<GameObject> {
            return _gameObjects//.values.array
        }
        private var _id: Int = GameObject.Count++
        
        public var id: Int {
            return _id
        }
        
        public var isActive: Bool = true
        
//        /// Enabled Behaviours are Updated, disabled Behaviours are not.
//        var enabled: Bool = true
//        ///	Has the Behaviour had enabled called.
//        var isActiveAndEnabled: Bool {
//            return self.isActive
//        }

        public var gameObject: GameObject {
            return self
        }
        
        /// The tag of this game object.
        var tag: String = ""
        
        /// The Transform attached to this GameObject (null if there is none attached).
        var transform: Transform {
            return self.GetComponent(Transform) ?? self.AddComponent(Transform)
        }
        
        private var _name: String = "New GameObject"
        
        public override var name: String {
            return _name
        }
        
        ///@TODO: Needs to be stress tested.
        func setName(name name: String? = nil, addNumber ext: Int = 0) -> Bool {
            var output: String = ext > 0 ? "\n - ++\(_name), ext: \(ext)" : "\nOLD NAME: \(self._name)"
            let oldName = _name
            var newName = name ?? _name
            if ext > 0 {
                newName += " (\(ext))"
                output += "\n - ++\(newName)"
            }
            
            //if we would be replacing a copy or other instance
            if let old = GameObject._gameObjects[newName] where old !== self {
                output += "\n - Matched: \(self.name), id: \(self.id) ?= \(old.id)"
                if old.id == self.id {
                    self._id = GameObject.Count++
                    output += "\n - ID from \(old.id) to \(self.id)"
                }
                return self.setName(name: name, addNumber: ext + 1)
            } else if self === GameObject._gameObjects[oldName] {//Remove before renaming
                output += "\n - Renaming Self \(oldName), ID: \(self.id)"
                GameObject._gameObjects.removeValueForKey(oldName)
            }
            self._name = newName
            output += "\n - Inserting Self: \(_name), ID: \(_id)"
            GameObject._gameObjects[_name] = self
            self.transform.setName()
            output += "\nNEW NAME: \(_name)\n"
            print(output)
            return true
        }
        
        public override convenience init() {
            self.init(named: nil)
        }
        
        public init(named name: String?) {
            super.init()
            self.setName(name: name)
            self.AddComponent(Transform)
        }
        

        
        private var _scripts: [String:IBehaviour] = [:]
        
        private var _components: [String:Component] = [:]
        
        public func SendMessage(message: String, args: AnyObject...) {
            for script in _scripts {
                if script.1.respondsToSelector(Selector(message)) {
    //                script.1.Awake?()
                    NSObjectController.performSelector(Selector(message), withObject: script.1, afterDelay: 0)
                }
               
            }
        }
        
        public func AddComponent<T:Component>(type: T.Type) -> T {
            if let component = self._components[type.className()] as? T {
                return component
            } else {
                let component = T(gameObject: self)
                if let script = component as? IBehaviour {
                    self._scripts[T.className()] = script
                }
                _components[T.className()] = component
                return component
            }
        }
        
        public func Awake() {
            for script in _scripts {
                script.1.Awake?()
            }
        }
        
        /// Calls the method named methodName on every MonoBehaviour in this game object or any of its children.
        public func BroadcastMessage(){}
        /// Is this game object tagged with tag ?
        public func CompareTag(){}
        
        /// Returns the component of Type type if the game object has one attached, null if it doesn't.
        public func GetComponent<T: Component>(type: T.Type) -> T? {
            return _components[type.className()] as? T
        }
        
        /// Returns the component of Type type in the GameObject or any of its children using depth first search.
        public func GetComponentInChildren(){}
        
        /// Returns the component of Type type in the GameObject or any of its parents.
        public func GetComponentInParent(){}
        
        /// Returns all components of Type type in the GameObject.
        public func GetComponents(){}
        
        /// Returns all components of Type type in the GameObject or any of its children.
        public func GetComponentsInChildren(){}
        /// Returns all components of Type type in the GameObject or any of its parents.
        public func GetComponentsInParent(){}
        
        /// Calls the method named methodName on every MonoBehaviour in this game object.
        public func SendMessage(){}
        
        /// Calls the method named methodName on every MonoBehaviour in this game object and on every ancestor of the behaviour.
        public func SendMessageUpwards(){}
        
        /// Returns the instance id of the object.
        public func GetInstanceID(){}
        
        /// Returns the name of the game object.
        public func ToString() -> String {
            return _name
        }
        
        public override var description: String {
            let result: String = "\(_name), ID: \(_id)"// + " has Components:\n"
//            for component in _components {
//                result += "\(component.0)\n"
//            }
           return result
        }
        
        public override func clone() -> Object {
            let clone = super.clone() as! GameObject
            clone._id = GameObject.Count++
            clone.setName()
            if self === clone {
                fatalError()
            }
            return clone
        }
        
    }
    
   
}



///Static Methods
extension Mono.GameObject {
   
}