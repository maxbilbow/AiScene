//
//  RMSActionProcessor.swift
//  RattleGL
//
//  Created by Max Bilbow on 22/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
#if OSX
import AppKit
    #elseif iOS
    import UIKit
    
    #endif


    import SceneKit

enum RMXMoveType { case PUSH, DRAG }

extension RMX {
    static var willDrawFog: Bool = false
    
    static func toggleFog(){
        RMX.willDrawFog = !RMX.willDrawFog
        #if OPENGL_OSX
            DrawFog(RMX.willDrawFog)
        #endif
    }
}
class RMSActionProcessor {
    
    //let keys: RMXController = RMXController()
    var activeSprite: RMXSprite {
        return self.world.observer
    }
    var world: RMSWorld
    
    init(world: RMSWorld, gameView: GameView){
        self.world = world
        self.gameView = gameView
        RMXLog()
    }

    var gameView: GameView
    
    private var _movement: (x:RMFloatB, y:RMFloatB, z:RMFloatB) = (x:0, y:0, z:0)
    private var _panThreshold: RMFloatB = 70
    
    func movement(action: String!, speed: RMFloatB = 1,  point: [RMFloatB]) -> Bool{
        
        switch action {
        case nil:
            RMXLog("ACTION IS NIL")
            return true
        case "move", "Move", "MOVE":
            if point.count == 3 {
                self.activeSprite.accelerateForward(point[2] * speed)
                self.activeSprite.accelerateLeft(point[0] * speed)
                self.activeSprite.accelerateUp(point[1] * speed)
                
                let sprite = self.activeSprite.node
                sprite
            }
            return true
        case "Stop", "stop", "STOP":
            self.activeSprite.stop()
            _movement = (0,0,0)
            return true
        case "look", "Look", "LOOK":
            if point.count == 2 {
                self.activeSprite.lookAround(theta: point[0] * speed,phi: point[1] * speed)
            }
            return true
        case "roll", "Roll", "ROLL":
            self.activeSprite.lookAround(roll: speed)
            return true
        case "pitch", "Pitch", "PITCH":
            self.activeSprite.lookAround(phi: speed)
            return true
        case "yaw", "Yaw", "YAW":
            self.activeSprite.lookAround(theta: speed)
            return true
        case "rollLeft":
            self.activeSprite.lookAround(roll: -speed)
            return true
        case "rollRight":
            self.activeSprite.lookAround(roll: speed)
            return true
        case "forward":
            if speed == 0 {
                self.activeSprite.stop()
            }
            else {
                self.activeSprite.accelerateForward(speed)
            }
            return true
        case "back":
            if speed == 0 {
                self.activeSprite.stop()
            }
            else {
                self.activeSprite.accelerateForward(-speed)
            }
            return true
        case "left":
            if speed == 0 {
                self.activeSprite.stop()
            }
            else {
                self.activeSprite.accelerateLeft(speed)
            }
            return true
        case "right":
            if speed == 0 {
                self.activeSprite.stop()
            }
            else {
                self.activeSprite.accelerateLeft(-speed)
            }
            return true
        case "up":
            if speed == 0 {
                self.activeSprite.stop()
            }
            else {
                self.activeSprite.accelerateUp(-speed)
            }
            return true
        case "down":
            if speed == 0 {
                self.activeSprite.stop()
            }
            else {
                self.activeSprite.accelerateUp(speed)
            }
            return true
        case "jump":
            if speed == 0 {
                self.activeSprite.jump()
            }
            else {
                self.activeSprite.prepareToJump()
            }
            return true
        case "throw":
            if speed != 0 {//depreciated perhaps
                if self.activeSprite.hasItem {
                    RMXLog("Throw: \(self.activeSprite.item?.name) with speed: \(speed)")
                    self.manipulate(action: "throw", sprite: self.activeSprite, object: self.activeSprite.item, speed: speed)
                }
            }
            return true
        case "enlargeItem":
            if self.activeSprite.hasItem {
                let size = (self.activeSprite.item?.radius)! * speed
                if size > 0.5 && size < 15 {
                    self.activeSprite.item?.setRadius(size)
                    self.activeSprite.item?.node.physicsBody!.mass *= RMFloat(size)
                }
            }
            return true
        case "extendArm":
            if self.activeSprite.hasItem {
                if self.extendArm != speed {
                    self.extendArm = speed * 5
                }
            }
            return true
        case "toggleAllGravity":
            if speed == 1 { self.world.toggleGravity() }
            break
        case "toggleGravity":
            self.activeSprite.toggleGravity()
            break
        case "lockMouse":
            if speed == 1 { self.isMouseLocked = !self.isMouseLocked }
            break
        case "switchEnvitonment":
            if speed == 1 { self.world.environments.plusOne() }
            break
        case "toggleFog":
            RMX.toggleFog()
            break
        case "nextCamera":
            if speed == 1 {
                let cameraNode = self.activeSprite.getNextCamera()
                self.gameView.pointOfView = cameraNode
            }
            break
        case "previousCamera":
            if speed == 1 {
                let cameraNode = self.activeSprite.getPreviousCamera()
                self.gameView.pointOfView = cameraNode
            }
            break
        case "reset":
            if speed == 1 {
                self.activeSprite.node.position = self.activeSprite.startingPoint
                self.activeSprite.node.physicsBody!.resetTransform()
            }
            break
        case "information":
            if speed == 1 { println(_getInfo()) }
        default:
            RMXLog("'\(action)' not recognised")
        }
        
        
       
        return false
        
    }
    
    private func _getInfo() -> String {
        let node = self.activeSprite.node//.presentationNode()
        let sprite = self.activeSprite
        let physics = self.world.scene.physicsWorld
        var info = "\n     vel:\(sprite.velocity.print)\n     Pos:\(sprite.position.print)\n transform:\n\(sprite.transform.print)\n   orientation:\n\(sprite.orientation.print)\n"
        info += "\n       MASS: \(sprite.mass),  GRAVITY: \(physics.gravity.print)"
        info += "\n   FRICTION: \(node.physicsBody?.friction), Rolling Friction: \(node.physicsBody?.rollingFriction), restitution: \(node.physicsBody?.restitution) \n"
        return info
    }
    func debug(_ yes: Bool = true){
        if yes {
            RMXLog(_getInfo())
        }
    }
    
    func animate(){
        if self.extendArm != 0 {
            self.activeSprite.extendArmLength(self.extendArm)
        }
        self.debug(false)
    }
        
        
    var extendArm: RMFloatB = 0
//    var mousePos: NSPoint = NSPoint(x: 0,y: 0)
    var isMouseLocked = false
    
    
    func manipulate(action: String? = nil, sprite: RMXSprite? = nil, object: AnyObject? = nil, speed: RMFloatB = 1,  point: [RMFloatB]? = nil) -> AnyObject? {
        if let action = action {
            switch action {
                case "throw", "Throw","grab", "Grab":
                    if let sprite = sprite {
                        if let node = object?.node {
                            if let body = node.physicsBody {
                                switch (body.type){
                                case .Static:
                                    NSLog("Node is static")
                                    return nil
                                case .Dynamic:
                                    NSLog("Node is Dynamic")
                                    break
                                case .Kinematic:
                                    NSLog("Node is Kinematic")
                                    break
                                default:
                                    fatalError("Something went wrong")
                                }
                            }
                            let rootNode = RMXSprite.rootNode(node, rootNode: sprite.scene!.rootNode)
                            if rootNode == sprite.node {
                                NSLog("Node is self")
                                //return
                            } else {
                                if let item = self.world.getSprite(node: node) {
                                    if let itemInHand = sprite.item {
                                        if item.name == itemInHand.name {
                                            sprite.throwItem(speed * item.mass)
                                            NSLog("Node \(item.name) was thrown with force: \(speed) x \(item.mass)")
                                        } else {
                                            //                                   self.world?.observer.grabItem(item: item)
                                            NSLog("Node is grabbable: \(item.name) but holding node: \(itemInHand.name)")
                                        }
                                    } else if item.type != RMXSpriteType.BACKGROUND {
                                        sprite.grabItem(item: item)
                                        NSLog("Node is grabbable: \(item.name)")
                                    } else {
                                        NSLog("Node was NOT grabbable: \(item.name)")
                                    }
                                }
                            }
                        } else {
                            if let itemInHand = sprite.item {
                                sprite.throwItem(speed * itemInHand.mass)
                                NSLog("Node \(itemInHand.name) was thrown with force: \(speed) x \(itemInHand.mass)")
                            }
                        }
                    }
                break
            default:
                NSLog("Action '\(action)' not recognised")
            }
            
        }
        return nil
    }
}