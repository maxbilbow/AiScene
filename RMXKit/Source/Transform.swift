//
//  Transform.swift
//  AiScene
//
//  Created by Max Bilbow on 16/07/2015.
//  Copyright © 2015 Rattle Media. All rights reserved.
//

import Foundation
import SceneKit

extension Mono {

    public class Transform : Component {
        
        /// The Node associated with this transform
        private let _node = SCNNode()

        func setName() {
            _node.name = gameObject.name
        }
        
        ///	The number of children the Transform has.
        public var childCount: Int {
            return _node.childNodes.count
        }
        
        ///	The rotation as Euler angles in degrees.
        public var eulerAngles: Vector3 {
            return _node.presentationNode().eulerAngles //TODO: make this world eulers
        }
        
        ///	The blue axis of the transform in world space.
        public var forward: Vector3 {
            return _node.presentationNode().worldTransform.forward
        }
        
        ///	Has the transform changed since the last time the flag was set to 'false'?
        public var hasChanged: Bool {
            return _node.hasActions() //TODO: I doubt this works
        }
        
        ///	The rotation as Euler angles in degrees relative to the parent transform's rotation.
        public var localEulerAngles: Vector3 {
            return _node.presentationNode().eulerAngles
        }
        
        /// Position of the transform relative to the parent transform.
        public var localPosition: Vector3 {
            return _node.presentationNode().position
        }
        
        /// The rotation of the transform relative to the parent transform's rotation.
        public var localRotation: Quaternion {
            return _node.presentationNode().rotation
        }
        
        /// The scale of the transform relative to the parent.
        public var localScale: Float = 1
        
        /// The global scale of the object (Read Only).
        public var lossyScale: Float = 1
        
        ///	Matrix that transforms a point from local space into world space (Read Only).
        public var localToWorldMatrix: Matrix4 {
            return _node.presentationNode().worldTransform
        }
        
        /// The parent of the transform.
        public var parent: Transform?
        
        /// The position of the transform in world space.
        public var position: Vector3 {
            return _node.presentationNode().worldTransform.position
        }
        
        /// The red axis of the transform in world space.
        public var right: Vector3 {
            return _node.presentationNode().worldTransform.left * -1
        }
        
        /// Returns the topmost transform in the hierarchy.
        public var root: Transform { return self }
        
        ///	The rotation of the transform in world space stored as a Quaternion.
        public var rotation: Quaternion = SCNVector4Zero
        
        ///	The green axis of the transform in world space.
        public var up: Vector3 {
            return _node.presentationNode().worldTransform.up
        }
        ///	Matrix that transforms a point from world space into local space (Read Only).
        public var worldToLocalMatrix: Matrix4 {
            return _node.presentationNode().transform
        }
        
        ///
        public func DetachChildren(){}// Unparents all children.
        ///
        public func Find(){}// Finds a child by name and returns it.
        
        /// Returns a transform child by index.
        public func GetChild(withName name: String) -> Transform? {
            return nil//_node.childNodeWithName(name, recursively: true)
        }
        ///
        public func GetSiblingIndex(){}// Gets the sibling index.
        ///
        public func InverseTransformDirection(){}// Transforms a direction from world space to local space. The opposite of Transform.TransformDirection.
        ///
        public func InverseTransformPoint(){}// Transforms position from world space to local space.
        ///
        public func InverseTransformVector(){}// Transforms a vector from world space to local space. The opposite of Transform.TransformVector.
        
        /// Is this transform a child of parent?
        public func IsChildOf(parent: Transform) -> Bool { //TODO: does this include all decendants?
            return parent._node.childNodeWithName(self.name, recursively: true) != nil
        }
        
        ///
        public func LookAt(position: Vector3){}// Rotates the transform so the forward vector points at /target/'s current position.
        ///
        public func Rotate(){}// Applies a rotation of eulerAngles.z degrees around the z axis, eulerAngles.x degrees around the x axis, and eulerAngles.y degrees around the y axis (in that order).
        ///
        public func RotateAround(){}// Rotates the transform about axis passing through point in world coordinates by angle degrees.
        ///
        public func SetAsFirstSibling(){}// Move the transform to the start of the local transfrom list.
        ///
        public func SetAsLastSibling(){}// Move the transform to the end of the local transfrom list.
        
        /// Set the parent of the transform.
        public func SetParent(parent: Transform){
            self.parent = parent
//            _node.removeFromParentNode()
            self.parent?._node.addChildNode(_node)
        }
        
        ///
        public func SetSiblingIndex(){}// Sets the sibling index.
        ///
        public func TransformDirection(){}// Transforms direction from local space to world space.
        ///
        public func TransformPoint(){}// Transforms position from local space to world space.
        ///
        public func TransformVector(){}// Transforms vector from local space to world space.
        ///
        public func Translate(){}// Moves the transform in the direction and distance of translation.
        
    }

}