//
//  RMXAi.swift
//  AiScene
//
//  Created by Max Bilbow on 19/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation

typealias AiBehaviour = (Bool) -> ()
class RMXAi {
    static var autoStabilise: Bool = true
    class func autoStablise(sprite: RMXSprite) {
        let ai: AiBehaviour = { (isOn) -> () in
            if self.autoStabilise && sprite.world!.hasGravity {
                var bottom = sprite.upVector * -1
                bottom.y *= sprite.height
                let force = RMXVector3Make(0, -200000, 0) //self.scene.physicsWorld.gravity * self.activeSprite.mass
                sprite.physicsBody?.applyForce(force, atPosition: bottom, impulse: false)
            }
        }
        sprite.addBehaviour(ai)
    }
    
    class func playFetch(poppy: RMXSprite, master observer: RMXSprite) {
        var itemToWatch: RMXSprite! = nil
        var timePassed = 0
        var state: PoppyState = .IDLE
        let speed:RMFloatB = 150 * (poppy.mass + 1)
        let updateInterval = 1
        
        
        poppy.behaviours.append { (isOn: Bool) -> () in
            //            NSLog("State: \(state.rawValue) - Pos: \(poppy.position.print)")
            func idle(sender: RMXSprite, objects: [AnyObject]? = []) -> AnyObject? {
                sender.lookAround(theta: speed / 10)
                sender.accelerateForward(speed)
                return nil
            }
            
            func fetch(sender: RMXSprite, objects: [AnyObject]?) -> AnyObject? {
                //                sender.body.hasGravity = (objects?[0] as! RMXSprite).hasGravity
                return sender.grabItem(item: itemToWatch)
            }
            
            func drop(sender: RMXSprite, objects: [AnyObject]?) -> AnyObject?  {
                sender.releaseItem()
                sender.completeStop()
                return nil
            }
            
            func getReady(sender: RMXSprite, objects: [AnyObject]?)  -> AnyObject? {
                sender.completeStop()
                return nil
            }
            
            switch (state) {
            case .IDLE:
                if observer.hasItem {
                    itemToWatch = observer.item
                    state = .READY_TO_CHASE
                } else {
                    idle(poppy)
                    RMXLog("Idle: \(state.rawValue), pos: \(poppy.position.print)")
                }
                break
            case .READY_TO_CHASE:
                if !observer.hasItem {
                    state = .CHASING
                } else {
                    RMXLog("Ready to Chase: \(state.rawValue),  pos: \(poppy.position.print)")
                    poppy.headTo(itemToWatch, speed: speed, doOnArrival: getReady)
                }
                break
            case .CHASING:
                if  observer.hasItem {
                    itemToWatch = observer.item
                    state = .READY_TO_CHASE
                } else if poppy.hasItem {
                    itemToWatch = nil
                    state = .FETCHING
                } else {
                    RMXLog("Chasing: \(state.rawValue),  pos: \(poppy.position.print)")
                    poppy.headTo(itemToWatch, speed: speed, doOnArrival: fetch, objects: observer)
                }
                break
            case .FETCHING:
                if !poppy.hasItem  {
                    state = .IDLE
                } else {
                    poppy.headTo(observer, speed: speed, doOnArrival: drop)
                    RMXLog("Fetching: \(state.rawValue),  pos: \(poppy.position.print)")
                }
                break
            default:
                if observer.hasItem {
                    state = .READY_TO_CHASE
                } else {
                    state = .IDLE
                    
                }
                fatalError("no state set")
            }
        }
    
    }

}