//
//  RMXNode.swift
//  RattleGL3-0
//
//  Created by Max Bilbow on 10/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//
import GLKit
import Foundation

import SceneKit

    typealias RMXNode = SCNNode
   

protocol RMXChildNode {
    var node: RMXNode { get set }
    var parentNode: RMXNode? { get }
    var parentSprite: RMXSprite? { get set }
}



extension RMXSprite {

    
    var transform: RMXMatrix4 {
        return self.node.presentationNode().transform
    }
    
    var position: RMXVector3 {
        return self.node.presentationNode().position
    }
    
    
    func presentationNode() -> RMXNode {
        return self.node.presentationNode()
    }
    var geometry: SCNGeometry? {
        return self.node.geometry
    }
    
    var physicsBody: SCNPhysicsBody? {
        return self.node.physicsBody
    }
    
    var physicsField: SCNPhysicsField? {
        return self.node.physicsField
    }
    
    
    func applyForce(direction: SCNVector3, atPosition: SCNVector3? = nil, impulse: Bool = false) {
        if let atPosition = atPosition {
            self.node.physicsBody?.applyForce(direction, atPosition: atPosition, impulse: impulse)
        } else {
            self.node.physicsBody?.applyForce(direction, impulse: impulse)
        }
    }
    
    var orientation: SCNQuaternion {
        return self.presentationNode().orientation
    }
    
    func resetTransform() {
        self.node.physicsBody?.resetTransform()
    }
   
}





