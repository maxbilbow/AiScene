//
//  RMXAVProcessor.swift
//  AiScene
//
//  Created by Max Bilbow on 27/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import SceneKit


typealias CollisionRequest = (contact: SCNPhysicsContact) -> Bool

extension SCNPhysicsContact : RMXLocatable {
    func getPosition() -> SCNVector3 {
        return self.contactPoint
    }
}

class RMXCollider: NSObject, SCNPhysicsContactDelegate {
    
    enum type { case Began, Updated, Ended }
    var world: RMSWorld? {
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
        
        if contact.nodeA.rmxID == self.activeSprite?.rmxID {
            self.av.playSound("Pop", info: contact)
        }
        if contact.nodeB.sprite?.type != .BACKGROUND && contact.nodeA.sprite?.type != .BACKGROUND {
            for tracker in self.trackers {
                tracker.checkForCollision(contact)
            }
        }
//        self.av.playAudio()
        
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didUpdateContact contact: SCNPhysicsContact) {

    }
    
    func physicsWorld(world: SCNPhysicsWorld, didEndContact contact: SCNPhysicsContact) {
        
    }

}