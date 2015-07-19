//
//  RMXAVProcessor.swift
//  AiScene
//
//  Created by Max Bilbow on 27/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import SceneKit

@available(OSX 10.10, *)
typealias CollisionRequest = (contact: SCNPhysicsContact) -> Bool

@available(OSX 10.10, *)
extension SCNPhysicsContact : RMXLocatable {
    public func getPosition() -> SCNVector3 {
        return self.contactPoint
    }
}

@available(OSX 10.10, *)
extension SCNPhysicsContact {
    func getDefender(forChallenger challenger: RMXNode) -> SCNNode {
        return self.nodeA == challenger ? nodeB : nodeA
    }
}

@available(OSX 10.10, *)
extension RMXScene: SCNPhysicsContactDelegate {

    
    enum type { case Began, Updated, Ended }

    
    
    
//    collisionTrackers
    func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact) {
        

        contact.nodeA.rmxNode?.tracker.checkForCollision(contact)
        contact.nodeB.rmxNode?.tracker.checkForCollision(contact)
     
        contact.nodeA.rmxNode?.collisionAction(contact)
        contact.nodeB.rmxNode?.collisionAction(contact)

    
        
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didUpdateContact contact: SCNPhysicsContact) {

    }
    
    func physicsWorld(world: SCNPhysicsWorld, didEndContact contact: SCNPhysicsContact) {
        
    }

}