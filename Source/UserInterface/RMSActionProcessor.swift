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

//#if SceneKit
    import SceneKit
   // #elseif SpriteKit
    import SpriteKit
 //   #endif

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
    
    var boomTimer: RMFloatB = 1

    var interface: RMXInterface {
        return self.gameView.interface!
    }
    //let keys: RMXController = RMXController()
    var activeSprite: RMXSprite {
        return self.world.observer
    }
    var world: RMSWorld
    
    var scene: RMXScene {
        return self.world.scene
    }
    init(world: RMSWorld, gameView: GameView){
        self.world = world
        self.gameView = gameView
        RMXLog()
    }

    var gameView: GameView
    
    private var _movement: (x:RMFloatB, y:RMFloatB, z:RMFloatB) = (x:0, y:0, z:0)
    private var _panThreshold: RMFloatB = 70
    
    func moveSpeed(inout speed: RMFloatB) {
        speed *= 1000 * self.activeSprite.mass / 10
    }
    
    func turnSpeed(inout speed: RMFloatB) {
        speed *= 150 * self.activeSprite.mass / 10
    }
    
    func movement(action: String!, var speed: RMFloatB = 1,  point: [RMFloatB]) -> Bool{
        
        switch action {
        case nil:
            RMXLog("ACTION IS NIL")
            return true
        case "move", "Move", "MOVE":
            if point.count == 3 {
                self.moveSpeed(&speed)
                self.activeSprite.accelerateForward(point[2] * speed)
                self.activeSprite.accelerateLeft(point[0] * speed)
                self.activeSprite.accelerateUp(point[1] * speed)
                self.activeSprite.acceleration = RMXVector3Make(point[0] * speed, point[1] * speed, point[2] * speed)
            }
            return true
        case "Stop", "stop", "STOP":
            self.activeSprite.stop()
            _movement = (0,0,0)
            return true
        case "look", "Look", "LOOK":
            self.turnSpeed(&speed)
            if point.count == 2 {
                self.activeSprite.lookAround(theta: point[0] * -speed,phi: point[1] * speed)
            }
            return true
        case "roll", "Roll", "ROLL", "rollLeft":
            self.turnSpeed(&speed)
            self.activeSprite.lookAround(roll: speed)
            return true
        case "rollRight":
            self.turnSpeed(&speed)
            self.activeSprite.lookAround(roll: -speed)
            return true
        case "pitch", "Pitch", "PITCH":
            self.turnSpeed(&speed)
            self.activeSprite.lookAround(phi: speed)
            return true
        case "yaw", "Yaw", "YAW":
            self.turnSpeed(&speed)
            self.activeSprite.lookAround(theta: speed)
            return true
        case "setRoll":
            self.activeSprite.setAngle(roll: speed)
            break
        case "setPitch":
            self.activeSprite.setAngle(pitch: speed)
            break
        case "setYaw":
            self.activeSprite.setAngle(yaw: speed)
            break
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
                moveSpeed(&speed)
                self.activeSprite.accelerateForward(speed)
            }
            return true
        case "back":
            if speed == 0 {
                self.activeSprite.stop()
            }
            else {
                moveSpeed(&speed)
                self.activeSprite.accelerateForward(-speed)
            }
            return true
        case "left":
            if speed == 0 {
                self.activeSprite.stop()
            }
            else {
                moveSpeed(&speed)
                self.activeSprite.accelerateLeft(speed)
            }
            return true
        case "right":
            if speed == 0 {
                self.activeSprite.stop()
            }
            else {
                moveSpeed(&speed)
                self.activeSprite.accelerateLeft(-speed)
            }
            return true
        case "up":
            if speed == 0 {
                self.activeSprite.stop()
            }
            else {
                moveSpeed(&speed)
                self.activeSprite.accelerateUp(speed)
            }
            return true
        case "down":
            if speed == 0 {
                self.activeSprite.stop()
            }
            else {
                moveSpeed(&speed)
                self.activeSprite.accelerateUp(-speed)
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
                let cameraNode = self.interface.getNextCamera()
                self.gameView.pointOfView = cameraNode
            }
            break
        case "previousCamera":
            if speed == 1 {
                let cameraNode = self.interface.getPreviousCamera()
                self.gameView.pointOfView = cameraNode
            }
            break
        case "reset":
            if speed == 1 {
                self.activeSprite.setPosition(position: RMXVector3Make(0, 50, 50))
            }
            break
        case "toggleAI":
            if speed == 1 {
                self.world.aiOn = !self.world.aiOn
                RMXLog("aiOn: \(self.world.aiOn)")
            }
        case "information":
            if speed == 1 {
//                println(self.getData())
                self.interface.dataView!.hidden = !self.interface.dataView!.hidden
//                self.interface.dataView!.enabled = !self.interface.dataView!.hidden
                if !self.interface.dataView!.hidden {
//                    self.interface.dataView!.text = self.getData()
                    let string: String = self.getData()
                    string.drawAtPoint(CGPoint(x: 500,y: 500), withAttributes: nil)
                    
                }
//                self.interface.dataView!.setTitle(_getInfo())
            } 
        case "explode":
            if speed == 1 {
                self.explode(force: self.boomTimer)
                self.boomTimer = 1
            } else if speed == 0 && self.boomTimer == 1 {
                self.boomTimer = 2
            }
            break
        case "zoomIn":
            --self.gameView.pointOfView!.camera!.xFov
            --self.gameView.pointOfView!.camera!.yFov //= SCNTechnique.
            return true
        case "zoomOut":
            ++self.gameView.pointOfView!.camera!.xFov
            ++self.gameView.pointOfView!.camera!.yFov
            return true
        default:
            RMXLog("'\(action)' not recognised")
        }
        
        
       
        return false
        
    }
    
    func getData() -> String {
        let node = self.activeSprite.node//.presentationNode()
        let sprite = self.activeSprite
        let physics = self.world.scene.physicsWorld
        var info = "\n     vel:\(sprite.velocity.print)\n     Pos:\(sprite.position.print)\n transform:\n\(sprite.transform.print)\n   orientation:\n\(sprite.orientation.print)\n"
        info += "\n       MASS: \(sprite.mass),  GRAVITY: \(physics.gravity.print)"
        info += "\n   FRICTION: \(node.physicsBody?.friction), Rolling Friction: \(node.physicsBody?.rollingFriction), restitution: \(node.physicsBody?.restitution) \n"
        
        //Accelerometer vs sprite angles
        return info
        var angles   = "\n ANGLES: \n"
        #if iOS
        if let dPad: RMXDPad = self.interface as? RMXDPad {
            if let att = dPad.motionManager.deviceMotion.attitude {
                let attitude = SCNVector3Make(RMFloatB(att.pitch), RMFloatB(att.yaw), RMFloatB(att.roll))
                angles      += "\n    - SPRITE: \(sprite.getNode().eulerAngles.asDegrees)"//, Pitch: \()\n"
                angles      += "\n    -  PHONE: \(attitude.asDegrees) \n"//Roll: \(), Pitch: \()\n"
            }
        }
        #endif
        return angles
    }
    func debug(_ yes: Bool = true){
        if yes {
            NSLog(self.getData() as String)
        }
    }

    func animate(){
        if self.boomTimer > 1 {
            self.boomTimer++
            RMXLog(self.boomTimer)
        }
        
        if self.extendArm != 0 {
            self.activeSprite.extendReach(self.extendArm)
        }
        self.debug(false)
    }
        
        
    var extendArm: RMFloatB = 0
//    var mousePos: NSPoint = NSPoint(x: 0,y: 0)
    var isMouseLocked = false
    
    func setOrientation(sprite s: RMXSprite? = nil, orientation: SCNQuaternion? = nil, zRotation: CGFloat? = nil, pitch x: RMFloatB? = nil, yaw y: RMFloatB? = nil, roll z: RMFloatB? = nil) {
        let sprite = s ?? self.activeSprite
        if let orientation = orientation {
            RMXLog("not implemented")
        } else {
            sprite.setAngle(yaw: y, pitch: x, roll: z)
        }
    }
    
    func manipulate(action: String? = nil, sprite s: RMXSprite? = nil, object: AnyObject? = nil, speed: RMFloatB = 1,  point: [RMFloatB]? = nil) -> AnyObject? {
        let sprite = s ?? self.activeSprite
        if let action = action {
            switch action {
                case "throw", "Throw","grab", "Grab":
                    if let node: RMXNode = object?.node {
                        if let body = node.physicsBody {
                            switch (body.type){
                            case .Static:
                                RMXLog("Node is static")
                                return nil
                            case .Dynamic:
                                RMXLog("Node is Dynamic")
                                break
                            case .Kinematic:
                                RMXLog("Node is Kinematic")
                                break
                            default:
                                fatalError("Something went wrong")
                            }
                        }
                        let rootNode = RMXSprite.rootNode(node, rootNode: sprite.scene!.rootNode)
                        if rootNode == sprite.node {
                            RMXLog("Node is self")
                            if let item = sprite.item{
                                sprite.throwItem(strength: speed)
                            }
                        } else {
                            if let item = self.world.getSprite(node: node) {
                                if let itemInHand = sprite.item {
                                    if item.name == itemInHand.name {
                                        sprite.throwItem(strength: speed)
                                        RMXLog("Node \(item.name) was thrown with force: \(speed) x \(item.mass)")
                                    } else {
                                        //                                   self.world?.observer.grabItem(item: item)
                                        sprite.throwItem()
                                        sprite.grabItem(item: item)
                                        RMXLog("Node is grabbable: \(item.name) but holding node: \(itemInHand.name)")
                                    }
                                } else if item.type != RMXSpriteType.BACKGROUND {
                                    sprite.grabItem(item: item)
                                    RMXLog("Node is grabbable: \(item.name)")
                                } else {
                                    RMXLog("Node was NOT grabbable: \(item.name)")
                                }
                            }
                        }
                    } else if let item = sprite.item{
                        sprite.throwItem(strength: speed)
                    }
                    
                break
            default:
                NSLog("Action '\(action)' not recognised")
            }
            
        }
        return nil
    }
    
    func explode(sprite s: RMXSprite? = nil, force: RMFloatB = 1, range: RMFloatB = 5000) {
        let sprite = s ?? self.activeSprite
        if let world = sprite.world {
            for child in world.children {
                let dist = sprite.distanceTo(child)
                if  dist < range && child.physicsBody?.type != .Static && child != sprite {
                    let direction = RMXVector3Normalize(child.position - sprite.position)
                    child.applyForce(direction * (force * 100000 / (dist + 0.1)) , impulse: true)
                }
            }
        }
    }
}