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
        return self.world.activeSprite!
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
    
    func moveSpeed(inout speed: RMFloatB, sprite: RMXSprite) {
        speed *= 1000 * sprite.mass / 10
    }
    
    func turnSpeed(inout speed: RMFloatB, sprite: RMXSprite) {
        speed *= 150 * sprite.mass / 10
    }
    
    func action(action: String!, var speed: RMFloatB = 1,  point: [RMFloatB], sprite: RMXSprite? = nil) -> Bool{
        let sprite = sprite ?? self.activeSprite
        switch action {
        case nil:
            RMXLog("ACTION IS NIL")
            return true
        case "move", "Move", "MOVE":
            if point.count == 3 {
                self.moveSpeed(&speed, sprite: sprite)
                sprite.accelerateForward(point[2] * speed)
                sprite.accelerateLeft(point[0] * speed)
                sprite.accelerateUp(point[1] * speed)
//                sprite.acceleration = RMXVector3Make(point[0] * speed, point[1] * speed, point[2] * speed)
            }
            return true
        case "Stop", "stop", "STOP":
            sprite.stop()
            _movement = (0,0,0)
            return true
        case "look", "Look", "LOOK":
            
            if point.count == 2 {
                if sprite.usesWorldCoordinates {
//                    self.world.activeCamera!.transform = SCNMatrix4Rotate(self.world.activeCamera!.transform, point[0] * -PI_OVER_180, 0, 1, 0)
//                    if let cameraNode = self.world.activeCamera {
                        self.world.activeCamera!.eulerAngles.y += point[0] * 0.1 * speed * PI_OVER_180
                    let phi = self.world.activeCamera!.eulerAngles.x - point[1] * 0.1  * speed * PI_OVER_180
                    if phi < 1 && phi > -1 {
                        self.world.activeCamera!.eulerAngles.x = phi
                    }
//                    }
                } else {
                    if self.world.hasGravity {
                        let phi = self.world.activeCamera!.eulerAngles.x - point[1] * 0.1  * speed * PI_OVER_180
                        if phi < 1 && phi > -1 {
                            self.world.activeCamera!.eulerAngles.x = phi
                        }
                    }
                    self.turnSpeed(&speed, sprite: sprite)
                    sprite.lookAround(theta: point[0] * -speed,phi: point[1] * speed)

                }
            }
            return true
        case "roll", "Roll", "ROLL", "rollLeft":
            self.turnSpeed(&speed,sprite: sprite)
            sprite.lookAround(roll: speed)
            return true
        case "rollRight":
            self.turnSpeed(&speed, sprite: sprite)
            sprite.lookAround(roll: -speed)
            return true
        case "pitch", "Pitch", "PITCH":
            self.turnSpeed(&speed, sprite: sprite)
            sprite.lookAround(phi: speed)
            return true
        case "yaw", "Yaw", "YAW":
            self.turnSpeed(&speed, sprite: sprite)
            sprite.lookAround(theta: speed)
            return true
        case "setRoll":
            sprite.setAngle(roll: speed)
            break
        case "setPitch":
            sprite.setAngle(pitch: speed)
            break
        case "setYaw":
            sprite.setAngle(yaw: speed)
            break
        case "rollLeft":
            sprite.lookAround(roll: -speed)
            return true
        case "rollRight":
            sprite.lookAround(roll: speed)
            return true
        case "forward":
            if speed == 0 {
                sprite.stop()
            }
            else {
                self.moveSpeed(&speed, sprite: sprite)
                sprite.accelerateForward(speed)
            }
            return true
        case "back":
            if speed == 0 {
                sprite.stop()
            }
            else {
                self.moveSpeed(&speed, sprite: sprite)
                sprite.accelerateForward(-speed)
            }
            return true
        case "left":
            if speed == 0 {
                sprite.stop()
            }
            else {
                self.moveSpeed(&speed, sprite: sprite)
                sprite.accelerateLeft(speed)
            }
            return true
        case "right":
            if speed == 0 {
                sprite.stop()
            }
            else {
                self.moveSpeed(&speed, sprite: sprite)
                sprite.accelerateLeft(-speed)
            }
            return true
        case "up":
            if speed == 0 {
                sprite.stop()
            }
            else {
                self.moveSpeed(&speed, sprite: sprite)
                sprite.accelerateUp(speed)
            }
            return true
        case "down":
            if speed == 0 {
                sprite.stop()
            }
            else {
                self.moveSpeed(&speed, sprite: sprite)
                sprite.accelerateUp(-speed)
            }
            return true
        case RMXInterface.JUMP:
            if speed == 1 {
                sprite.jump()
                self.interface.av.playSound(action, info: sprite, volume: 0.2)
            }
            else {
//                sprite.prepareToJump()
            }
            return true
        case "throw":
            if speed != 0 {//depreciated perhaps
                if sprite.hasItem {
                    RMXLog("Throw: \(sprite.item?.name) with speed: \(speed)")
                    self.manipulate(action: "throw", sprite: sprite, object: sprite.item, speed: speed)
                }
            }
            return true
        case "enlargeItem":
            if sprite.hasItem {
                let size = (sprite.item?.radius)! * speed
                if size > 0.5 && size < 15 {
                    sprite.item?.setRadius(size)
                    sprite.item?.node.physicsBody!.mass *= RMFloat(size)
                }
            }
            return true
        case "extendArm":
            if sprite.hasItem {
                if self.extendArm != speed {
                    self.extendArm = speed * 5
                }
            }
            return true
        case "toggleAllGravity":
            if speed == 1 { self.world.toggleGravity() }
            return true
        case "toggleGravity":
            sprite.toggleGravity()
            return true
        case "lockMouse":
            if speed == 1 { self.isMouseLocked = !self.isMouseLocked }
            return true
        case "switchEnvitonment":
//            if speed == 1 { self.world.environments.plusOne() }
            return true
        case "toggleFog":
            RMX.toggleFog()
            return true
        case "nextCamera":
            if speed == 1 {
                let cameraNode = self.world.getNextCamera()
                self.gameView.pointOfView = cameraNode
                if RMXSprite.rootNode(cameraNode, rootNode: self.scene.rootNode).rmxID == sprite.rmxID {
                    sprite.usesWorldCoordinates = false
                } else {
                    sprite.usesWorldCoordinates = true
                }
            }
            return true
        case "previousCamera":
            if speed == 1 {
                let cameraNode = self.world.getPreviousCamera()
                self.gameView.pointOfView = cameraNode
                if RMXSprite.rootNode(cameraNode, rootNode: self.scene.rootNode).rmxID == sprite.rmxID {
                    sprite.usesWorldCoordinates = false
                } else {
                    sprite.usesWorldCoordinates = true
                }
            }
            return true
        case "reset":
            if speed == 1 {
                sprite.setPosition(position: RMXVector3Make(0, 50, 50))
            }
            return true
        case "toggleAI":
            if speed == 1 {
                self.world.aiOn = !self.world.aiOn
                RMXLog("aiOn: \(self.world.aiOn)")
            }
        case "information":
            if speed == 1 {
                NSLog(self.getData())
                self.interface.dataView!.hidden = !self.interface.dataView!.hidden
//                self.interface.dataView!.enabled = !self.interface.dataView!.hidden
                if !self.interface.dataView!.hidden {
                    #if iOS
                    self.interface.dataView!.text = self.getData()
                    #endif
//                    let string: String = self.getData()
//                    string.drawAtPoint(CGPoint(x: 500,y: 500), withAttributes: nil)
//                    
                }
//                self.interface.dataView!.setTitle(_getInfo())
            } 
        case "explode":
            if speed == 1 {
                if let item = sprite.item {
                    self.manipulate(action: "throw", sprite: sprite, object: item, speed: ( self.boomTimer  ) * item.mass)
                } else {
                    self.explode(force: self.boomTimer)
                    
                }
                self.boomTimer = 1
            } else if speed == 0 && self.boomTimer == 1 {
                self.boomTimer = 2
            }
            
            return true
        case "zoomIn":
            --self.gameView.pointOfView!.camera!.xFov
            --self.gameView.pointOfView!.camera!.yFov //= SCNTechnique.
            return true
        case "zoomOut":
            ++self.gameView.pointOfView!.camera!.xFov
            ++self.gameView.pointOfView!.camera!.yFov
            return true
        case "zoom":
            if let cameraNode = self.gameView.pointOfView {
                if cameraNode.camera!.xFov + Double(speed) > 100 || cameraNode.camera!.xFov + Double(speed) < 5 {
//                    cameraNode.transform.m43 += speed
                    return false
                } else {
                    cameraNode.camera!.xFov += Double(speed)
                    cameraNode.camera!.yFov += Double(speed)
//                    NSLog(self.gameView.pointOfView!.camera!.yFov.toData())
                    return true
                }
            }
            return false
        case RMXInterface.PAUSE_GAME:
            if speed == 1 {
                self.interface.pauseGame(speed)
            } 
            return true
        case RMXInterface.KEYBOARD_LAYOUT:
            if speed == 1 {
                switch self.interface.keyboard {
                case .French:
                    self.interface.setKeyboard(type: .UK)
                    break
                case .UK:
                    self.interface.setKeyboard(type: .French)
                    break
                default:
                    self.interface.setKeyboard(type: .UK)
                    break
                }
            }
            return true
        default:
            RMXLog("'\(action)' not recognised")
        }
        
        
       
        return false
        
    }
    enum TESTING { case PLAYER_INFO, ACTIVE_CAMERA, ANGLES }
    func getData(type: TESTING = .ACTIVE_CAMERA) -> String {
        let node = self.activeSprite.node//.presentationNode()
        let sprite = self.activeSprite
        let physics = self.world.scene.physicsWorld
        var info: String = ""
        switch type {
        case .PLAYER_INFO:
            info += "\n        vel:\(sprite.velocity.print)\n     Pos:\(sprite.position.print)\n transform:\n\(sprite.transform.print)\n   orientation:\n\(sprite.orientation.print)\n"
            info += "\n       MASS: \(sprite.mass),  GRAVITY: \(physics.gravity.print)"
            info += "\n   FRICTION: \(node.physicsBody?.friction), Rolling Friction: \(node.physicsBody?.rollingFriction), restitution: \(node.physicsBody?.restitution) \n"
            
            //Accelerometer vs sprite angles
            return info
        case .ANGLES:
            var angles   = "\n ANGLES: \n"
            #if iOS
            if let dPad: RMXDPad = self.interface as? RMXDPad {
                if let att = dPad.motionManager.deviceMotion.attitude {
                    let attitude = SCNVector3Make(RMFloatB(att.pitch), RMFloatB(att.yaw), RMFloatB(att.roll))
                    angles      += "\n    - SPRITE: \(sprite.presentationNode().eulerAngles.asDegrees)"//, Pitch: \()\n"
                    angles      += "\n    -  PHONE: \(attitude.asDegrees) \n"//Roll: \(), Pitch: \()\n"
                }
            }
            #endif
            return angles
        case .ACTIVE_CAMERA:
            let rootNode = self.world.activeCamera?.getRootNode(inScene: self.scene)
            info += "\n --- RootNode: \(rootNode?.name) ---\n"
            info += "   cam: \n\(self.world.activeCamera!.presentationNode().worldTransform.print)\n"
            info += " world: \(self.world.leftVector.print)   rootNode: \(rootNode?.presentationNode().worldTransform.left.print)\n"
            info += "      : \(self.world.upVector.print)           : \(rootNode?.presentationNode().worldTransform.up.print)\n"
            info += "      : \(self.world.forwardVector.print)           : \(rootNode?.presentationNode().worldTransform.forward.print)\n\n"
            return info
        default:
            return info
        }
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
        
        if !self.world.hasGravity {
            if let activeCamera = self.world.activeSprite?.activeCamera {
                if activeCamera.eulerAngles.x > 0.01 {
                    activeCamera.eulerAngles.x -= 0.01
                } else if activeCamera.eulerAngles.x < -0.01 {
                    activeCamera.eulerAngles.x += 0.01
                }
            }
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
    
    func manipulate(action: String? = nil, sprite s: RMXSprite? = nil, object: AnyObject? = nil, speed: RMFloatB = 1,  point: [RMFloatB]? = nil, targetSprite: RMXSprite? = nil, var position: RMXVector? = nil) -> RMXNode? {
        let sprite = s ?? self.activeSprite
        if let action = action {
            switch action {
                case "throw", "Throw","grab", "Grab":
                    if let item = sprite.item {
//                        direction = object?.presentationNode().position
                        if let tgt:RMXNode = object?.node {
                            sprite.throwItem(strength: speed, atNode: tgt)
                        } else if let point = position {
                            sprite.throwItem(strength: speed, atPoint: point)
                        } else {
                            sprite.throwItem(strength: speed)
                        }
                        return item.node
                    } else if let node: RMXNode = object?.node {
                        let rootNode = node.getRootNode(inScene: self.scene)
                            switch rootNode.spriteType {
                            case .ABSTRACT, .BACKGROUND, .KINEMATIC:
                                return nil
                            default:
                                break
                            }
                        // RMXSprite.rootNode(node, rootNode: sprite.scene!.rootNode)
                        if rootNode == sprite.node {
                            RMXLog("Node is self")
                            if let item = sprite.item{
                                sprite.throwItem(strength: speed)
                            }
                        } else {
                            if let item = rootNode.sprite {// self.world.getSprite(node: node) {
                                if let itemInHand = sprite.item {
                                    if item.name == itemInHand.name {
                                        sprite.throwItem(strength: speed)
                                        RMXLog("Node \(item.name) was thrown with force: \(speed) x \(item.mass)")
                                    } else {
                                        //                                   self.world?.observer.grabItem(item: item)
                                        sprite.throwItem()
                                        sprite.grab(item: item)
                                        RMXLog("Node is grabbable: \(item.name) but holding node: \(itemInHand.name)")
                                    }
                                } else if item.type != RMXSpriteType.BACKGROUND {
                                    sprite.grab(item: item)
                                    RMXLog("Node is grabbable: \(item.name)")
                                } else {
                                    RMXLog("Node was NOT grabbable: \(item.name)")
                                }
                            }
                        }
                        return node
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
        sprite.world!.interface.av.playSound(RMXInterface.BOOM, info: sprite.position, range: Float(range))
        RMSActionProcessor.explode(sprite, force: force, range: range)
        
    }
    
    class func explode(sprite: RMXSprite, force: RMFloatB = 1, range: RMFloatB = 5000) {
        
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