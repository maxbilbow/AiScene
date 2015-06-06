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


public class RMSActionProcessor {
    
    private var boomTimer: RMFloat = 1

    var interface: RMXInterface
    
    //let keys: RMXController = RMXController()
    var activeSprite: RMXSprite {
        return self.world.activeSprite
    }
    var world: RMSWorld {
        return self.interface.world
    }
    
    var scene: RMXScene {
        return self.world//.scene
    }
    init(interface: RMXInterface){
        self.interface = interface
        RMLog()
    }

    var gameView: GameView {
        return self.interface.gameView!
    }
    
    var activeCamera: RMXCameraNode? {
        return self.world.activeCamera as? RMXCameraNode
    }
    
    private var _movement: (x:RMFloat, y:RMFloat, z:RMFloat) = (x:0, y:0, z:0)
    private var _panThreshold: RMFloat = 70
    
    
    func action(action: String!, var speed: RMFloat = 1,  args: Any?) -> Bool {
        let sprite = self.activeSprite
        switch action {
        case nil:
            RMLog("ACTION IS NIL")
            return true
        case "move", "Move", "MOVE":
            if let point = args as? CGPoint {
                sprite.accelerate(left: RMFloat(point.x), forward: RMFloat(point.y))
            } else if let point = args as? [RMFloat] {
                if point.count == 3 {
                    sprite.accelerate(forward: point[2] * speed, left: point[0] * speed, up: point[1] * speed)
                    return true
                }
                    
            }
            return true
        case "Stop", "stop", "STOP":
            sprite.stop()
            _movement = (0,0,0)
            return true
        case "look", "Look", "LOOK":
            
            if let point = args as? CGPoint {
                if let camera = self.world.activeCamera as? RMXCameraNode {
                    speed *= camera.zoomFactor
                    if !self.activeSprite.isPOV {
//                        self.world.activeCamera.eulerAngles.y += point.x * 0.1 * speed * PI_OVER_180
                        let phi: RMFloat = self.world.activeCamera.eulerAngles.x - RMFloat(point.y) * 0.1 * speed * PI_OVER_180
                        if phi < 1 && phi > -1 {
                            self.world.activeCamera.eulerAngles.x = phi
                        }
    //                    }
                    } else {
                        if self.world.hasGravity {
                            let phi = self.world.activeCamera.eulerAngles.x - RMFloat(point.y) * 0.1 * speed * PI_OVER_180
                            if phi < 1 && phi > -1 {
                                self.world.activeCamera.eulerAngles.x = phi
                            }
                        }
                        
                        sprite.lookAround(theta: RMFloat(point.x) * speed,phi: RMFloat(point.y) * speed)

                    }
                }
            }
            return true
        case "roll", "Roll", "ROLL", "rollLeft":
            sprite.lookAround(roll: speed)
            return true
        case "rollRight":
            sprite.lookAround(roll: -speed)
            return true
        case "pitch", "Pitch", "PITCH":
            sprite.lookAround(phi: speed)
            return true
        case "yaw", "Yaw", "YAW":
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
                sprite.accelerate(forward: speed)
            }
            return true
        case "back":
            if speed == 0 {
                sprite.stop()
            }
            else {
                sprite.accelerate(forward: -speed)
            }
            return true
        case "left":
            if speed == 0 {
                sprite.stop()
            }
            else {
                sprite.accelerate(left: speed)
            }
            return true
        case "right":
            if speed == 0 {
                sprite.stop()
            }
            else {
                sprite.accelerate(left: -speed)
            }
            return true
        case "up":
            if speed == 0 {
                sprite.stop()
            }
            else {
                sprite.accelerate(up: speed)
            }
            return true
        case "down":
            if speed == 0 {
                sprite.stop()
            }
            else {
                sprite.accelerate(up: -speed)
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
//                    sprite.item?.setRadius(size)
                    sprite.item?.physicsBody!.mass *= CGFloat(size)
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
        case RMXInterface.RESET:
            if speed == 1 {
//                sprite.setPosition(position: RMXVector3Make(0, 50, 50))
                for player in self.world.players {
                    player.attributes.deRetire()
                }
            }
            return true
        case RMXInterface.DEBUG_NEXT:
            if speed == 1 {
                RMXLog.next()
                return true
            } else if speed == -1 {
                RMXLog.previous()
                return true
            }
            return false
        case RMXInterface.DEBUG_PREVIOUS:
            if speed == 1 {
                RMXLog.previous()
                return true
            } else if speed == -1 {
                RMXLog.next()
                return true
            }
            return false
        case RMXInterface.TOGGLE_AI:
            if speed == 1 {
                self.world.toggleAi()
                RMLog("aiOn: \(self.world.aiOn)")
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

        case RMXInterface.BOOM:
            if sprite.hasItem && speed > 0 && self.boomTimer > 1 {
                let result = sprite.throwItem(force: speed * self.boomTimer)
                self.boomTimer = 1
                return result
            } else {
                if speed == 0 && self.boomTimer == 1 {
                    self.boomTimer = 2
                    return true
                } else if speed == 1 && self.explode(force: self.boomTimer * 180) {
                    self.boomTimer = 1
                    return true
                }
            }
            return false
        case RMXInterface.THROW_ITEM + RMXInterface.GRAB_ITEM:
            if speed == 0 && self.boomTimer == 1 {
                if sprite.hasItem {
                    self.boomTimer = 2
                    return true
                } else {
                    return true
                }
            } else if speed > 0 {
                var result = false
                if let item = sprite.item {
                    return true//self.activeSprite.throwItem(atObject: args as? AnyObject, withForce: self.boomTimer * item.mass * speed)
                }
                self.boomTimer = 1
                return false
            }
            self.boomTimer = 1
            return false
        case RMXInterface.INCREASE:
            self.scene.physicsWorld.speed * 1.5
            return true
        case RMXInterface.DECREASE:
            self.scene.physicsWorld.speed / 1.5
            return true
        case RMXInterface.ZOOM_IN:
//            --self.gameView.pointOfView!.camera!.xFov
//            --self.gameView.pointOfView!.camera!.yFov //= SCNTechnique.
            assert((self.world.activeCamera as? RMXCameraNode)?.moveIn(speed: 1) != nil, "not an RMXCamera")
            return true
        case RMXInterface.ZOOM_OUT:
//            ++self.gameView.pointOfView!.camera!.xFov
//            ++self.gameView.pointOfView!.camera!.yFov
            assert((self.world.activeCamera as? RMXCameraNode)?.moveOut(speed: 1) != nil, "not an RMXCamera")
            return true
        case "zoom":
            if let cameraNode = self.activeCamera {
                if speed > 0 {
                    cameraNode.moveIn(speed: speed)
                } else if speed < 0 {
                    cameraNode.moveOut(speed: -speed)
                }
            }
            return false
        case RMXInterface.RESET_CAMERA:
            if speed == 1 {
                self.activeCamera?.zoomNeedsReset()
                self.activeCamera?.orientationNeedsReset()
                
            }
            return true
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
        let physics = self.world.physicsWorld
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
                    let attitude = SCNVector3Make(RMFloat(att.pitch), RMFloat(att.yaw), RMFloat(att.roll))
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
            NSLog(self.getData())
        }
    }

    func animate(){
        if self.boomTimer > 1 {
            self.boomTimer++
            RMLog(self.boomTimer.print, id: __FILE__.lastPathComponent)
        }
        
        
        

        self.debug(false)
    }
        
    
    var extendArm: RMFloat = 0
//    var mousePos: NSPoint = NSPoint(x: 0,y: 0)
    var isMouseLocked = false
    
    func setOrientation(sprite s: RMXSprite? = nil, orientation: SCNQuaternion? = nil, zRotation: CGFloat? = nil, pitch x: RMFloat? = nil, yaw y: RMFloat? = nil, roll z: RMFloat? = nil) {
        let sprite = s ?? self.activeSprite
        if let orientation = orientation {
            RMLog("not implemented")
        } else {
            sprite.setAngle(yaw: y, pitch: x, roll: z)
        }
    }
    
    func throwOrGrab(target: Any?, withForce force: RMFloat = 1, tracking: Bool) -> Bool{
        if let item = self.activeSprite.item {
            let boom = self.boomTimer
            self.boomTimer = 1
            return self.activeSprite.throwItem(atObject: target as? AnyObject, withForce: force * boom, tracking: tracking)
        } else {
            self.boomTimer = 1
            return self.activeSprite.grab(target as? AnyObject)
        }
    }
    
       
    func explode(sprite s: RMXSprite? = nil, force: RMFloat = 1, range: RMFloat = 500) -> Bool{
        let sprite = s ?? self.activeSprite
        sprite.world.interface.av.playSound(RMXInterface.BOOM, info: sprite.position, range: Float(range))
        return RMSActionProcessor.explode(sprite, force: force * 10000, range: range)
        
    }
    
    class func explode(sprite: RMXSprite?, force: RMFloat = 1, range: RMFloat = 500) -> Bool {
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