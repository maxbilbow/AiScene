//
//  RMXAVProcessor.swift
//  AiScene
//
//  Created by Max Bilbow on 27/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import SceneKit
import AVFoundation

typealias CollisionRequest = (contact: SCNPhysicsContact) -> Bool

class RMXCollider: NSObject, SCNPhysicsContactDelegate {
    
    var world: RMSWorld? {
        return self.interface.world
    }
    
    var activeSprite: RMXSprite? {
        return self.world?.activeSprite
    }
    
    var interface: RMXInterface
    
    class func getPlayer(name: String, ofType ext: String) -> AVAudioPlayer {
        return AVAudioPlayer(
            contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(name, ofType: ext)!),
            error: nil
        )
    }
    
    var sounds: [String:AVAudioPlayer] = [
    RMXInterface.BOOM : RMXCollider.getPlayer("Air Reverse Burst 2", ofType: "caf"),
    RMXInterface.JUMP : RMXCollider.getPlayer("Baseball Catch", ofType: "caf"),
    RMXInterface.THROW_ITEM : RMXCollider.getPlayer("Baseball Catch", ofType: "caf"),
    "pop2" : RMXCollider.getPlayer("pop2", ofType: "m4a"),
    "pop1" : RMXCollider.getPlayer("pop1", ofType: "m4a")
    ]

    var requests: Array<CollisionRequest> = Array<CollisionRequest>()
    
    init(interface: RMXInterface) {
        self.interface = interface
        for sound in self.sounds {
            sound.1.prepareToPlay()
        }
        sounds["hit"]?.volume = 0.1
        sounds[RMXInterface.JUMP]?.volume = 0.0
        sounds[RMXInterface.BOOM]?.volume = 0.3
        
    }
    
    
    // Initial setup
    func didBeginContact(contact: SCNPhysicsContact) {
        self.sounds["hit"]?.play()
    }
   
    func didEndContact(contact: SCNPhysicsContact) {
//        self.sounds["pop2"]?.play()
    }
    
    
    func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact) {
        if contact.nodeA.rmxID == self.activeSprite?.rmxID {
//            NSLog("START: NodeA hit \(contact.nodeB.sprite?.name)")
            didBeginContact(contact)
        }
        for (index, request) in enumerate(self.requests){
            if request(contact) {
                let removed = self.requests.removeAtIndex(index)
            }
        }
//        } else if contact.nodeB.rmxID == self.activeSprite?.rmxID {
//            NSLog("START: NodeB hit \(contact.nodeA.sprite?.name)")
////            didBeginContact(contact)
//        }
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didUpdateContact contact: SCNPhysicsContact) {
//        if contact.nodeA.rmxID == self.activeSprite?.rmxID {
//            NSLog("UPDATE: NodeA hit \(contact.nodeB.sprite?.name)")
//        } else if contact.nodeB.rmxID == self.activeSprite?.rmxID {
//            NSLog("UPDATE: NodeB hit \(contact.nodeA.sprite?.name)")
//        }
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didEndContact contact: SCNPhysicsContact) {
//        if contact.nodeA.rmxID == self.activeSprite?.rmxID {
//            NSLog("END: NodeA hit \(contact.nodeB.sprite?.name)")
//            self.didEndContact(contact)
//        } else if contact.nodeB.rmxID == self.activeSprite?.rmxID {
//            NSLog("END: NodeB hit \(contact.nodeA.sprite?.name)")
//        }
    }

}