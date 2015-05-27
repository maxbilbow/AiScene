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
    
    enum type { case Began, Updated, Ended }
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

    var trackers: Array<RMXTracker> = Array<RMXTracker>()
    
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
            didBeginContact(contact)
        }
        for tracker in self.trackers {
            tracker.checkForCollision(contact)
        }
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didUpdateContact contact: SCNPhysicsContact) {

    }
    
    func physicsWorld(world: SCNPhysicsWorld, didEndContact contact: SCNPhysicsContact) {

    }

}