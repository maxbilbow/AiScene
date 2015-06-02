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


public class RMSActionProcessor {
    
    var boomTimer: RMFloatB = 1

    var interface: RMXInterface
    
    //let keys: RMXController = RMXController()
    var activeSprite: RMXSprite {
        return self.world.activeSprite
    }
    var world: RMSWorld {
        return self.interface.world
    }
    
    var scene: RMXScene {
        return self.world.scene
    }
    init(interface: RMXInterface){
        self.interface = interface
        RMXLog()
    }

    var gameView: GameView {
        return self.interface.gameView!
    }
    
    private var _movement: (x:RMFloatB, y:RMFloatB, z:RMFloatB) = (x:0, y:0, z:0)
    private var _panThreshold: RMFloatB = 70
    
    func moveSpeed(inout speed: RMFloatB, sprite: RMXSprite) {
//        NSLog(speed.toData())
//        speed *= sprite.speed// 1000 * sprite.mass / 10
//        NSLog(speed.toData())
    }
    
    func turnSpeed(inout speed: RMFloatB, sprite: RMXSprite) {
//        speed *= sprite.rotationSpeed// 150 * sprite.mass / 10
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
                if !self.world.activeCamera.isPOV {
                    self.world.activeCamera.eulerAngles.y += point[0] * 0.1 * speed * PI_OVER_180
                    let phi = self.world.activeCamera.eulerAngles.x - point[1] * 0.1  * speed * PI_OVER_180
                    if phi < 1 && phi > -1 {
                        self.world.activeCamera.eulerAngles.x = phi
                    }
//                    }
                } else {
                    if self.world.hasGravity {
                        let phi = self.world.activeCamera.eulerAngles.x - point[1] * 0.1  * speed * PI_OVER_180
                        if phi < 1 && phi > -1 {
                            self.world.activeCamera.eulerAngles.x = phi
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
                self.gameView.pointOfView = self.world.getNextCamera()
            }
            return true
        case "previousCamera":
            if speed == 1 {
                self.gameView.pointOfView = self.world.getPreviousCamera()
            }
            return true
        case "reset":
            if speed == 1 {
                sprite.setPosition(position: RMXVector3Make(0, 50, 50))
            }
            return true
        case "toggleAI":
            if speed == 1 {
                self.world.toggleAi()
                RMXLog("aiOn: \(self.world.aiOn)")
            }
            return true
        case RMXInterface.GET_INFO:
            if speed == 1 {
                self.interface.dataView.hidden = !self.interface.dataView.hidden
                self.interface.skView.hidden = self.interface.dataView.hidden
            }
            return true
        case RMXInterface.SHOW_SCORES:
            if speed == 1 {
                self.interface.scoreboard.hidden = false
                self.interface.skView.hidden = false
                return true
            }
            return false
        case RMXInterface.HIDE_SCORES:
            if speed == 1 {
                self.interface.scoreboard.hidden = true
                self.interface.skView.hidden = true
                return true
            }
            return false
        case RMXInterface.TOGGLE_SCORES:
            if speed == 1 {
                self.interface.scoreboard.hidden = !self.interface.scoreboard.hidden
                self.interface.skView.hidden = self.interface.scoreboard.hidden
                return true
            }

        case RMXInterface.BOOM, RMXInterface.THROW_ITEM:
            if speed > 0 {
                var result = false
                if let item = sprite.item {
                    result = self.activeSprite.throwItem(force: self.boomTimer * item.mass * speed)
                } else {
                    result = self.explode(force: self.boomTimer * 180)
                    
                }
                self.boomTimer = 1
                return result
            } else if speed == 0 && self.boomTimer == 1 {
                self.boomTimer = 2
                return true
            }
        case RMXInterface.INCREASE:
            self.scene.physicsWorld.speed * 1.5
            return true
        case RMXInterface.DECREASE:
            self.scene.physicsWorld.speed / 1.5
            return true
        case RMXInterface.ZOOM_IN:
            --self.gameView.pointOfView!.camera!.xFov
            --self.gameView.pointOfView!.camera!.yFov //= SCNTechnique.
            return true
        case RMXInterface.ZOOM_OUT:
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
                if self.interface.isRunning {
                    return self.interface.pauseGame(speed)
                } else if self.interface.isPaused {
                    return self.interface.unPauseGame(speed)
                }
                return false
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
        case RMXInterface.NEW_GAME:
            self.interface.newGame()
            return true
        case "1", "2", "3", "4", "5", "6", "7", "8", "9", "10":
            let n = action.toInt()! - 1
            if n < self.interface.availableGames.count  {
                self.interface.newGame(type: self.interface.availableGames[n])
                return true
            } else {
                return false
            }
        default:
            NSLog("'\(action)' not recognised")
        }
        
        
       
        return false
        
    }
    enum TESTING { case PLAYER_INFO, ACTIVE_CAMERA, ANGLES, SCORES }
    func getData(type: TESTING = .ACTIVE_CAMERA) -> String {
        let node = self.activeSprite.node//.presentationNode()
        let sprite = self.activeSprite
        let physics = self.world.scene.physicsWorld
        var info: String = "\n"
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
            let camera = self.world.activeCamera
            

            info += "     left: \(self.world.leftVector.print)         camera: \(camera.presentationNode().worldTransform.left.print)\n"
            info += "       up: \(self.world.upVector.print)               : \(camera.presentationNode().worldTransform.up.print)\n"
            info += "      fwd: \(self.world.forwardVector.print)               : \(camera.presentationNode().worldTransform.forward.print)\n\n"
            info += "   sprite: \(self.activeSprite.position.print)\n"
            info += "   camera: \(camera.presentationNode().worldTransform.position.print)\n"
            info += "\n --- Camera: \(camera.name) ID: \(self.activeSprite.rmxID) : \(camera.rmxID)---\n"
            return info
        case .SCORES:
            info += "\n\n        SCORE: \(self.activeSprite.attributes.points), KILLS: \(self.activeSprite.attributes.killCount)"
            for team in self.world.teams {
                info += "\n TEAM-\(team.0) SCORE: \(team.1.printScore)"
            }
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
    
    func throwOrGrab(target: AnyObject?, withForce force: RMFloatB = 1) -> Bool{
        if let item = self.activeSprite.item {
            return self.activeSprite.throwItem(atObject: target?.node, withForce: force)
//            return item.tracker.target?.node
        } else {
            return self.activeSprite.grab(target?.node)
//            if let item = self.activeSprite.item {
//                 return item.isPlayer
//            }
        }
    }
    
       
    func explode(sprite s: RMXSprite? = nil, force: RMFloatB = 1, range: RMFloatB = 500) -> Bool{
        let sprite = s ?? self.activeSprite
        sprite.world.interface.av.playSound(RMXInterface.BOOM, info: sprite.position, range: Float(range))
        return RMSActionProcessor.explode(sprite, force: force * 10000, range: range)
        
    }
    
    class func explode(sprite: RMXSprite?, force: RMFloatB = 1, range: RMFloatB = 500) -> Bool {
        if let sprite = sprite {
            let world = sprite.world
            for child in world.children {
                let dist = sprite.distanceTo(child)
                if  dist < range && child.physicsBody?.type != .Static && child != sprite {
                    let direction = RMXVector3Normalize(child.position - sprite.position)
                    child.applyForce(direction * (force  / (dist + 0.1)) , impulse: true)
                }
            }
            return true
        }
        return false        
    }
}