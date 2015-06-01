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
            return self.presentationNode().worldTransform.position// - self.pivot.position
//        } else {
//            return self.position - self.pivot.position
//        }
    }
    
    var rmxID: Int {
        return self.getRmxID() ?? -1
    }
    
    func getRmxID(scene: RMXScene? = nil) -> Int? {
        if let sprite = self.sprite {
            return sprite.rmxID
        } else if let brain = self as? RMXBrain {
            return brain.rmxID
        } else if let scene = scene {
            return self.getRootNode(inScene: scene).sprite?.rmxID
        } else {
            return nil
        }
    }
    
    
    var sprite: RMXSprite? {
        if self is RMXNode {
            return (self as! RMXNode).spriteDirect
        } else {
            return self.parentNode?.sprite
        }
//        if let brain = self.childNodeWithName(RMXBrain.ID, recursively: false) as? RMXBrain {
//            return brain.getSprite()
//        } else {
//            return nil
//        }
    }
    
    var spriteType: RMXSpriteType {
        return self.sprite?.type ?? RMXSpriteType.ABSTRACT
    }
    
    var brain: RMXBrain? {
        return self.childNodeWithName(RMXBrain.ID, recursively: false) as? RMXBrain
    }
    
    class func rootNode(existsIn rootNode: SCNNode, var node: SCNNode) -> SCNNode {
        if node.parentNode == rootNode || node.parentNode == nil {
            RMXLog("RootNode: \(node.name)")
            return node
        } else {
            RMXLog(node.parentNode)
            return self.rootNode(existsIn: rootNode, node: node.parentNode!)
        }
    }
    
    func getRootNode(existsIn rootNode: SCNNode) -> SCNNode {
        return RMXNode.rootNode(existsIn: rootNode, node: self)
    }
    
    func getRootNode(inScene scene: RMXScene) -> SCNNode {
        return RMXNode.rootNode(existsIn: scene.rootNode, node: self)
    }
    
    
    var isActiveSprite: Bool {
        return self.sprite?.isActiveSprite ?? false
    }

    var boundingSphere: (center: RMXVector3, radius: RMFloatB) {
        var center: RMXVector3 = RMXVector3Zero
        var radius: RMFloat = 0
        self.getBoundingSphereCenter(&center, radius: &radius)
        return (center, RMFloatB(radius))
    }
    
    var boundingBox: (min: RMXVector, max: RMXVector) {
        var min: RMXVector3 = RMXVector3Zero
        var max: RMXVector3 = RMXVector3Zero
        self.getBoundingBoxMin(&min, max: &max)
        return (min, max)
    }
    
    var radius: RMFloatB {
        
        // let radius = RMXVector3Length(self.boundingBox.max * self.scale)
        return self.boundingSphere.radius * RMFloatB(self.scale.average)//radius
    }
    
    var isHeld: Bool {
        return self.sprite?.isLocked ?? false
    }
    
    var holder: RMXSprite? {
        return self.sprite?.holder
    }
    
    

}

class RMXBrain : RMXNode , RMXUniqueEntity {
    
    private var _rmxID: Int?
    
    override var rmxID: Int {
        if let id = _rmxID {
            return id
        } else {
            _rmxID = self.rootNode?.rmxID
            if _rmxID == nil { NSLog("error -1 RMXID") }
            return _rmxID ?? -1
        }
    }
//        {
//        return self.sprite?.rmxID
//    }

    static let ID = "Brain"
    internal var rmxSprite: RMXSprite?

    func getSprite() -> RMXSprite? {
        return self.rmxSprite
    }
    
    var rootNode: RMXNode? {
        return self.rmxSprite?.node
    }
    
    
    internal func setRmxID(ID: Int) {
        _rmxID = ID
    }
    
    class func giveBrainTo(sprite: RMXSprite) -> RMXBrain {
        let brain = RMXBrain()
        brain.rmxSprite = sprite
        brain.name = RMXBrain.ID
        sprite.node.addChildNode(brain)
        brain._rmxID = sprite.rmxID
        return brain
    }
    
}