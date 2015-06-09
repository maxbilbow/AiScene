//
//  RMXBrain.swift
//  AiScene
//
//  Created by Max Bilbow on 25/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import SceneKit


extension SCNNode : RMXObject {
    
    var uniqueID: String? {
        let parentID = self.parentNode?.uniqueID ?? ""
        return "\(parentID)/\(self.name ?? self.description)"
    }
    
    var print: String {
        return self.uniqueID!
    }
    
    @available(*,deprecated=1)
    func getPosition() -> SCNVector3 {
        return self.presentationNode().position
//        if self.physicsBody?.type == SCNPhysicsBodyType.Dynamic {
//            return self.presentationNode().position
//        } else {
//            return self.position
//        }
    }
    
    var rmxID: Int? {
        if #available(OSX 10.10, *) {
            return self.rmxNode?.sprite?.rmxID
        } else {
            return nil
            // Fallback on earlier versions
        }//.getRmxID() ?? -1
    }

    @available(OSX 10.10, *)
    var isPointOfView: Bool {
        return (self as? RMXCameraNode)?.isFixedPointOfView ?? false
    }
    
    var doesCollide: Bool {
        if #available(OSX 10.10, *) {
            return self.sprite?.isPlayerOrAi ?? false
        } else {
            return false// Fallback on earlier versions
        }
    }
    
    @available(OSX 10.10, *)
    var collisionNode: RMXNode? {
        return self.rmxNode //self.parentNode as? RMXNode
    }
    
    @available(OSX 10.10, *)
    var sprite: RMXSprite? {
        return self.rmxNode?.rmxSprite
//        if self.isKindOfClass(RMXNode) {
//            return (self as! RMXNode).getSprite()
//        } else if let brain = self.childNodeWithName(RMXBrain.ID, recursively: false) as? RMXNode {
//            return brain.getSprite()
//        } else {
//            return nil
//        }
    }
    
    @available(OSX 10.10, *)
    var spriteType: RMXSpriteType {
        return self.sprite?.type ?? RMXSpriteType.ABSTRACT
    }
    
    
    @available(OSX 10.10, *)
    var rmxNode: RMXNode? {
        return self as? RMXNode ?? (self.parentNode as? RMXNode)?.rmxNode ?? nil
    }
    
    
    
    @available(OSX 10.10, *)
    func setRmxID(rmxID: Int?) {
        (self as? RMXCameraNode)?._rmxID = rmxID
    }

    @available(*,deprecated=1)
    var geometryNode: SCNNode? {
        if #available(OSX 10.10, *) {
            return self.rmxNode?.childNodeWithName("geometry", recursively: false)
        } else {
            return nil // Fallback on earlier versions
        }
    }
    
    @available(OSX 10.10, *)
    var boundingSphere: (center: SCNVector3, radius: CGFloat) {
        var center: SCNVector3 = SCNVector3Zero; var radius: CGFloat = 0
        self.getBoundingSphereCenter(&center, radius: &radius)
        return (center, radius)
    }
    
    @available(OSX 10.10, *)
    var boundingBox: (min: SCNVector3, max: SCNVector3) {
        var min: SCNVector3 = SCNVector3Zero
        var max: SCNVector3 = SCNVector3Zero
        self.getBoundingBoxMin(&min, max: &max)
        return (min, max)
    }
    
    @available(OSX 10.10, *)
    var radius: RMFloat {
        return RMFloat(self.boundingSphere.radius) * RMFloat(self.scale.average)
    }
    
}
