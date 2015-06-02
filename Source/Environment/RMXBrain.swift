//
//  RMXBrain.swift
//  AiScene
//
//  Created by Max Bilbow on 25/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import SceneKit

extension SCNNode : RMXLocatable {
    
    func getPosition() -> RMXVector {
//        if self.physicsBody?.type == .Dynamic {
            return self.rmxNode?.presentationNode().worldTransform.position ?? self.presentationNode().worldTransform.position// - self.pivot.position
//        } else {
//            return self.position - self.pivot.position
//        }
    }
    
    var rmxID: Int? {
        return self.rmxNode?.sprite?.rmxID//.getRmxID() ?? -1
    }
    
    func getRmxID(scene: RMXScene? = nil) -> Int? {
        return self.rmxNode?.rmxID
//        if self.name == RMXBrain.ID {
//            return (self as? RMXBrain)?._rmxID
//        } else if let scene = scene {
//            return self.getRootNode(inScene: scene).sprite?.rmxID
//        } else {
//            return nil
//        }
    }
    
    var isPOV: Bool {
        return (self as? RMXCameraNode)?.pov() ?? false
    }
    
    var doesCollide: Bool {
        return self.sprite?.isPlayer ?? false
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
    
    
    @availability(*,deprecated=1)
    class func rootNode(existsIn rootNode: SCNNode, var node: SCNNode) -> SCNNode {
        if node.parentNode == rootNode || node.parentNode == nil {
            RMXLog("RootNode: \(node.name)")
            return node
        } else {
            RMXLog(node.parentNode)
            return self.rootNode(existsIn: rootNode, node: node.parentNode!)
        }
    }
    
    @availability(*,deprecated=1)
    func getRootNode(existsIn rootNode: SCNNode) -> SCNNode {
        return RMXNode.rootNode(existsIn: rootNode, node: self)
    }
    
    @availability(*,deprecated=1)
    func getRootNode(inScene scene: RMXScene) -> SCNNode {
        return RMXNode.rootNode(existsIn: scene.rootNode, node: self)
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
}

class RMXBrain : SCNNode, RMXUniqueEntity {
//    static let ID = "BRAIN21341"
//    
//    
//    class func giveBrainTo(sprite: RMXSprite) -> RMXBrain {
//        let brain = RMXBrain()
//        brain.rmxSprite = sprite
//        brain.name = RMXBrain.ID
//        sprite.node.addChildNode(brain)
//        brain.setRmxID(sprite.rmxID)
//        return brain
//    }
    
}