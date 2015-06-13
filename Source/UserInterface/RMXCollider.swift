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
    func getPosition() -> SCNVector3 {
        return self.contactPoint
    }
}

@available(OSX 10.10, *)
class RMXCollider: NSObject, SCNPhysicsContactDelegate {
    
    enum type { case Began, Updated, Ended }
    var world: RMXScene? {
        return self.interface.world
    }
    
    var activeSprite: RMXSprite? {
        return self.world?.activeSprite
    }
    
    var interface: RMXInterface
    
    var av: RMXAudioVideo {
        return self.interface.av
    }
    
    
    var trackers: Array<RMXTracker> = Array<RMXTracker>()
    
    init(interface: RMXInterface) {
        self.interface = interface
        
        
    }
    
    
    
    
    func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact) {
        
//        if contact.nodeA.rmxID == self.activeSprite?.rmxID {
//            self.av.playSound("Pop", info: contact)
//        }
        
        contact.nodeA.rmxNode?.tracker.checkForCollision(contact)
        contact.nodeB.rmxNode?.tracker.checkForCollision(contact)
     
        contact.nodeA.rmxNode?.collisionAction(contact)
        contact.nodeB.rmxNode?.collisionAction(contact)

//        if contact.nodeA.doesCollide && contact.nodeB.doesCollide {
//            (contact.nodeA as? RMXNode)?.collisionAction(contact.nodeB)
//            (contact.nodeB as? RMXNode)?.collisionAction(contact.nodeA)
//        }
        
//        if contact.nodeA.sprite?.willCollide ?? false && contact.nodeB.sprite?.willCollide ?? false {
//            for tracker in self.trackers {
//                tracker.checkForCollision(contact)
//            }
//        }
    
        
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didUpdateContact contact: SCNPhysicsContact) {

    }
    
    func physicsWorld(world: SCNPhysicsWorld, didEndContact contact: SCNPhysicsContact) {
        
    }

}