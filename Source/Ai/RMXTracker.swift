//
//  RMXTracker.swift
//  AiScene
//
//  Created by Max Bilbow on 27/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import SceneKit


class RMXTracker {
    
    var rmxID: Int {
        return self.sprite.rmxID
    }
    
    var sprite: RMXSprite
//    var hitTarget = false
    private var _target: RMXNode?
    var target: RMXNode? {
        return self.isActive ? _target : nil
    }
    
    var hasTarget: Bool {
        return _target != nil
    }
    
    var doOnArrival, doOnLeave, doWhileTouching: ((target: RMXNode?)->())?
    
    init(sprite: RMXSprite) {
        self.sprite = sprite
        self.sprite.world!.interface.collider.trackers.append(self)
    }
    
    static let IDLE = "Idle"
    
    var isActive = true
//    var itemToWatch: RMXSprite! = nil
    var timePassed = 0
    var state: String = IDLE
    
    let updateInterval = 1
    var lastPosition: RMXVector = RMXVector3Zero

    var isStuck: Bool {
        if let target = target {
            return self.sprite.distanceTo(point: self.lastPosition) < 1 && self.sprite.distanceTo(point: target.presentationNode().position) >= target.radius + self.sprite.radius
        } else {
            return false
        }
    }
    
    func setTarget(target: RMXNode? = nil, speed: RMFloatB? = nil, afterTime limit: Int = 0, willJump: Bool = true, impulse: Bool = false, doOnArrival: ((target: RMXNode?) -> ())? = nil) {
        self.doesJump = willJump
        self.impulse = impulse
        _limit = limit
        _count = 0
        _target = target
        self.doOnArrival = doOnArrival //!= nil ? doOnArrival : { self.pauseFor(10) }
//        self.doOnLeave = doOnLeave != nil ? doOnLeave : { self._target = lastTarget }
//        self.hitTarget = false
        if let speed = speed {
            self.sprite.speed = speed
        }
    }
    
    private var _count: Int = 0 ; private var _limit: Int = 0
   
    
    func checkForCollision(contact: SCNPhysicsContact) -> Bool {
        if let target = self.target {
            if contact.nodeA == self.sprite.node || contact.nodeB == self.sprite.node || contact.nodeB == self.sprite.item?.node || contact.nodeA == self.sprite.item?.node {
                if target.rmxID == self.sprite.rmxID || contact.nodeB == target || contact.nodeA == target {
                    self.doOnArrival?(target: target)
                    return true
                }
            }
        }
        return false
    }
    var impulse = false
    var doesJump = true
    
    internal func headToTarget() {
        if let target = self.target {
            if _limit > 0 && _count > _limit {
                self.doOnArrival?(target: self.target)
                _count = 0
            } else {
                ++_count
                let direction = RMXVector3Normalize(target.presentationNode().position - self.sprite.position)
                self.sprite.applyForce(direction * self.sprite.speed, atPosition: self.sprite.front,  impulse: self.impulse)
                if self.doesJump && self.isStuck {
                    self.sprite.jump()
                } else {
                    self.lastPosition = self.sprite.position
                }
            }
        }
    }

}