//
//  RMXBrain.swift
//  AiScene
//
//  Created by Max Bilbow on 25/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import SceneKit

extension SCNNode : RMXLocatable, RMXObject {
    
    var uniqueID: String? {
        let parentID = self.parentNode?.uniqueID ?? ""
        return "\(parentID)/\(self.name ?? self.description)"
    }
    
    var print: String {
        return self.uniqueID!
    }
    
    @availability(*,deprecated=1)
    func getPosition() -> SCNVector3 {
        return self.presentationNode().position
//        if self.physicsBody?.type == SCNPhysicsBodyType.Dynamic {
//            return self.presentationNode().position
//        } else {
//            return self.position
//        }
    }
    
    var rmxID: Int? {
        return self.rmxNode?.sprite?.rmxID//.getRmxID() ?? -1
    }

    var isPointOfView: Bool {
        return (self as? RMXCameraNode)?.isFixedPointOfView ?? false
    }
    
    var doesCollide: Bool {
        return self.sprite?.isPlayerOrAi ?? false
    }
    
    var collisionNode: RMXNode? {
        return self.rmxNode //self.parentNode as? RMXNode
    }
    
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
    
    var spriteType: RMXSpriteType {
        return self.sprite?.type ?? RMXSpriteType.ABSTRACT
    }
    
    
    var rmxNode: RMXNode? {
        return self as? RMXNode ?? (self.parentNode as? RMXNode)?.rmxNode ?? nil
    }
    
    
    
    func setRmxID(rmxID: Int?) {
        (self as? RMXCameraNode)?._rmxID = rmxID
    }

    var geometryNode: SCNNode? {
        return self.rmxNode?._geometryNode
    }
    
    var boundingSphere: (center: RMXVector3, radius: CGFloat) {
        var center: RMXVector3 = RMXVector3Zero; var radius: CGFloat = 0
        self.getBoundingSphereCenter(&center, radius: &radius)
        return (center, radius)
    }
    
    var boundingBox: (min: RMXVector, max: RMXVector) {
        var min: RMXVector3 = RMXVector3Zero
        var max: RMXVector3 = RMXVector3Zero
        self.getBoundingBoxMin(&min, max: &max)
        return (min, max)
    }
    
    var radius: RMFloat {
        return RMFloat(self.boundingSphere.radius) * RMFloat(self.scale.average)
    }
    
}
