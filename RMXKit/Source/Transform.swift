//
//  Transform.swift
//  AiScene
//
//  Created by Max Bilbow on 16/07/2015.
//  Copyright © 2015 Rattle Media. All rights reserved.
//

import Foundation
import SceneKit

public typealias Vector2 = CGVector
public typealias Vector3 = SCNVector3
public typealias Vector4 = SCNVector4
public typealias Matrix4 = SCNMatrix4
public typealias Quaternion = SCNQuaternion

public class Transform : Component {
    
    ///	The number of children the Transform has.
    public var childCount: Int { return 0 }
    ///	The rotation as Euler angles in degrees.
    public var eulerAngles: Vector3 = SCNVector3Zero
    ///	The blue axis of the transform in world space.
    public var forward: Vector3 { return self.localToWorldMatrix.forward }
    ///	Has the transform changed since the last time the flag was set to 'false'?
    public var hasChanged: Bool = false
    ///	The rotation as Euler angles in degrees relative to the parent transform's rotation.
    public var localEulerAngles: Vector3 { return self.eulerAngles }
    /// Position of the transform relative to the parent transform.
    public var localPosition: Vector3 { return self.position }
    /// The rotation of the transform relative to the parent transform's rotation.
    public var localRotation: Quaternion { return self.rotation }
    /// The scale of the transform relative to the parent.
    public var localScale: Float = 1
    /// The global scale of the object (Read Only).
    public var lossyScale: Float = 1
    ///	Matrix that transforms a point from local space into world space (Read Only).
    public var localToWorldMatrix: Matrix4 = SCNMatrix4Identity
    /// The parent of the transform.
    public var parent: Transform?
    /// The position of the transform in world space.
    public var position: Vector3 = SCNVector3Zero
    /// The red axis of the transform in world space.
    public var right: Vector3 { return self.localToWorldMatrix.left * -1 }
    /// Returns the topmost transform in the hierarchy.
    public var root: Transform { return self }
    ///	The rotation of the transform in world space stored as a Quaternion.
    public var rotation: Quaternion = SCNVector4Zero
    ///	The green axis of the transform in world space.
    public var up: Vector3 { return self.localToWorldMatrix.up }
    ///	Matrix that transforms a point from world space into local space (Read Only).
    public var worldToLocalMatrix: Matrix4 = SCNMatrix4Identity
    
    ///
    public func DetachChildren(){}// Unparents all children.
    ///
    public func Find(){}// Finds a child by name and returns it.
    ///
    public func GetChild(){}// Returns a transform child by index.
    ///
    public func GetSiblingIndex(){}// Gets the sibling index.
    ///
    public func InverseTransformDirection(){}// Transforms a direction from world space to local space. The opposite of Transform.TransformDirection.
    ///
    public func InverseTransformPoint(){}// Transforms position from world space to local space.
    ///
    public func  InverseTransformVector(){}// Transforms a vector from world space to local space. The opposite of Transform.TransformVector.
    ///
    public func IsChildOf(){}// Is this transform a child of parent?
    ///
    public func LookAt(){}// Rotates the transform so the forward vector points at /target/'s current position.
    ///
    public func Rotate(){}// Applies a rotation of eulerAngles.z degrees around the z axis, eulerAngles.x degrees around the x axis, and eulerAngles.y degrees around the y axis (in that order).
    ///
    public func RotateAround(){}// Rotates the transform about axis passing through point in world coordinates by angle degrees.
    ///
    public func SetAsFirstSibling(){}// Move the transform to the start of the local transfrom list.
    ///
    public func SetAsLastSibling(){}// Move the transform to the end of the local transfrom list.
    ///
    public func SetParent(){}// Set the parent of the transform.
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