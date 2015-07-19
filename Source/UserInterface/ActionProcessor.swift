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
//import RMXKit

//@available(OSX 10.9, *)
//extension RMX {
//    static var willDrawFog: Bool = false
//    
//    static func toggleFog(){
//        RMX.willDrawFog = !RMX.willDrawFog
//    }
//}

extension RMX {

     class ActionProcessor  {
        
        private static var _current: ActionProcessor?
        static var current: ActionProcessor! {
            return _current ?? ActionProcessor()
        }
        private var boomTimer: RMFloat = 1
        
        //let keys: RMXController = RMXController()
        var activeSprite: RMXNode {
            return self.world.activeSprite
        }
        var world: RMXScene {
            return Interface.current.world
        }
        
        var scene: RMXScene {
            return self.world//.scene
        }
        
        init(){
            if ActionProcessor._current != nil {
                fatalError(RMXException.Singleton.rawValue)
            } else {
                ActionProcessor._current = self
            }
        }


        
        var activeCamera: RMXCameraNode? {
            return self.world.activeCamera as? RMXCameraNode
        }
        
        private var _movement: (x:RMFloat, y:RMFloat, z:RMFloat) = (x:0, y:0, z:0)
        private var _panThreshold: RMFloat = 70
        
        
        func action(action: UserAction?, speed: RMFloat = 1,  args: Any? = nil) -> Bool {
            if let action = action {
            let sprite = self.activeSprite
                switch action {
                case .MOVE:
                    if let point = args as? CGPoint {
                        sprite.accelerate(RMFloat(point.x), forward: RMFloat(point.y))
                    } else if let point = args as? [RMFloat] {
                        if point.count == 3 {
                            sprite.accelerate(forward: point[2] * speed, point[0] * speed, up: point[1] * speed)
                            return true
                        }
                            
                    }
                    return true
                case .LOOK_AROUND:
                    if let point = args as? CGPoint {
                        if let camera = self.world.activeCamera as? RMXCameraNode {
                            let speed = speed * camera.zoomFactor
                            if !self.activeSprite.isPOV {
                                self.world.activeCamera.eulerAngles.y -= RMFloat(point.x) * 0.1 * speed * PI_OVER_180
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
                case .ROLL_LEFT:
                    sprite.lookAround(roll: speed)
                    return true
                case .ROLL_RIGHT:
                    sprite.lookAround(roll: -speed)
                    return true
                case .MOVE_FORWARD:
                    if speed == 0 {
                        sprite.stop()
                    }
                    else {
                        sprite.accelerate(forward: speed)
                    }
                    return true
                case .MOVE_BACKWARD:
                    if speed == 0 {
                        sprite.stop()
                    }
                    else {
                        sprite.accelerate(forward: -speed)
                    }
                    return true
                case .MOVE_LEFT:
                    if speed == 0 {
                        sprite.stop()
                    }
                    else {
                        sprite.accelerate(speed)
                    }
                    return true
                case .MOVE_RIGHT:
                    if speed == 0 {
                        sprite.stop()
                    }
                    else {
                        sprite.accelerate(-speed)
                    }
                    return true
                case .MOVE_UP:
                    if speed == 0 {
                        sprite.stop()
                    }
                    else {
                        sprite.accelerate(up: speed)
                    }
                    return true
                case .MOVE_DOWN:
                    if speed == 0 {
                        sprite.stop()
                    }
                    else {
                        sprite.accelerate(up: -speed)
                    }
                    return true
                case .JUMP:
                    if speed == 1 {
                        sprite.jump()
                        RMSoundBox.current.playSound("jump", info: sprite, volume: 0.2)
                    }
                    else {
        //                sprite.prepareToJump()
                    }
                    return true
                case .STOP_MOVEMENT:
                    sprite.stop()
                    _movement = (0,0,0)
                    return true
                case .TOGGLE_GRAVITY:
                    if speed == 1 { self.world.toggleGravity() }
                    return true
                case .LOCK_CURSOR:
                    if speed == 1 { Interface.current.lockCursor = !Interface.current.lockCursor }
                    return true
                case .NEXT_CAMERA:
                    if speed == 1 {
                        GameViewController.current.gameView?.pointOfView = self.world.getNextCamera()
                    }
                    return true
                case .PREV_CAMERA:
                    if speed == 1 {
                        GameViewController.current.gameView?.pointOfView = self.world.getPreviousCamera()
                    }
                    return true
                case .RESET:
                    if speed == 1 {
                        self.world.reset()
                    }
                    return true
                case .DEBUG_NEXT:
                    if speed == 1 {
                        RMXLog.next()
                        return true
                    } else if speed == -1 {
                        RMXLog.previous()
                        return true
                    }
                    return false
                case .DEBUG_PREVIOUS:
                    if speed == 1 {
                        RMXLog.previous()
                        return true
                    } else if speed == -1 {
                        RMXLog.next()
                        return true
                    }
                    return false
                case .TOGGLE_AI:
                    if speed == 1 {
                        self.world.toggleAi()
                        RMLog("aiOn: \(self.world.aiOn)")
                    }
                    return true
                case .GET_INFO:
                    if speed == 1 {
        //                Interface.current.dataView.hidden = !Interface.current.dataView.hidden
        //                Interface.current.skView.hidden = Interface.current.dataView.hidden
                    }
                    return true
                case .SHOW_SCORES:
                    if speed == 1 {
                        Interface.current.scoreboard.hidden = false
                        Interface.current.updateScoreboard(nil)
                        return true
                    }
                    return false
                case .HIDE_SCORES:
                    if speed == 1 {
                        Interface.current.scoreboard.hidden = true
        //                Interface.current.skView.hidden = true
                        return true
                    }
                    return false
                case .TOGGLE_SCORES:
                    if speed == 1 {
                        Interface.current.scoreboard.hidden = !Interface.current.scoreboard.hidden
        //                Interface.current.skView.hidden = Interface.current.scoreboard.hidden
                        Interface.current.updateScoreboard(nil)
                        return true
                    }

                case .BOOM:
                    if speed > 0 && self.boomTimer > 1 {
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
                case .THROW_OR_GRAB_TRACKED, .THROW_OR_GRAB_UNTRACKED:
                    if speed == 0 && self.boomTimer == 1 {
                        if sprite.isHoldingItem {
                            self.boomTimer = 2
                            return true
                        } else {
                            return true
                        }
                    } else if speed > 0 {
                        //                    var result = false
                        if sprite.isHoldingItem {
                            return true// RMXNode.current.throwItem(atObject: args as? AnyObject, withForce: self.boomTimer * item.mass * speed)
                        }
                        self.boomTimer = 1
                        return false
                    }
                    self.boomTimer = 1
                    return false
                case .INCREASE:
                    self.scene.physicsWorld.speed * 1.5
                    return true
                case .DECREASE:
                    self.scene.physicsWorld.speed / 1.5
                    return true
                case .ZOOM_IN:
        //            --self.gameView.pointOfView!.camera!.xFov
        //            --self.gameView.pointOfView!.camera!.yFov //= SCNTechnique.
                    assert((self.world.activeCamera as? RMXCameraNode)?.moveIn(1) != nil, "not an RMXCamera")
                    return true
                case .ZOOM_OUT:
        //            ++self.gameView.pointOfView!.camera!.xFov
        //            ++self.gameView.pointOfView!.camera!.yFov
                    assert((self.world.activeCamera as? RMXCameraNode)?.moveOut(1) != nil, "not an RMXCamera")
                    return true
                case .ZoomInAnOut:
                    if let cameraNode = self.activeCamera {
                        if speed > 0 {
                            cameraNode.moveIn(speed)
                        } else if speed < 0 {
                            cameraNode.moveOut(-speed)
                        }
                    }
                    return false

                case .RESET_CAMERA:
                    if speed == 1 {
                        self.activeCamera?.zoomNeedsReset()
                        self.activeCamera?.orientationNeedsReset()
                        
                    }
                    return true
                case .PAUSE_GAME:
                    if speed == 1 {
                        if Interface.current.isRunning {
                            return Interface.current.pauseGame()
                        } else if Interface.current.isPaused {
                            return Interface.current.unPauseGame()
                        }
                        return false
                    }
                    return true
                case .KEYBOARD_LAYOUT:
                    if speed == 1 {
                        switch Interface.current.keyboard {
                        case .French:
                            Interface.current.setKeyboard(.UK)
                            break
                        case .UK:
                            Interface.current.setKeyboard(.French)
                            break
                        default:
                            Interface.current.setKeyboard(.UK)
                            break
                        }
                    }
                    return true
                case .NEW_GAME:
                    Interface.current.newGame()
                    return true
                default:
                    NSLog("'\(action)' not recognised")
                    return false
                }
            }
            return false
        }
        
        func action(string: String, speed: RMFloat = 1,  args: Any?) -> Bool {
            let action = string
            let sprite = self.activeSprite
                switch action {
                case "pitch", "Pitch", "PITCH":
                    sprite.rotate(phi: speed)
                    return true
                case "yaw", "Yaw", "YAW":
                    sprite.rotate(theta: speed)
                    return true
                case "1", "2", "3", "4", "5", "6", "7", "8", "9", "10":
                    let n = Int(action)! - 1
                    if n < Interface.current.availableGames.count  {
                        Interface.current.newGame(Interface.current.availableGames[n])
                        return true
                    } else {
                        return false
                    }
                default:
                    NSLog("'\(action)' not recognised")
                    return false
                }

        }
        
        
        enum TESTING { case PLAYER_INFO, ACTIVE_CAMERA, ANGLES, SCORES }
        func getData(type: TESTING = .ACTIVE_CAMERA) -> String {
            let node = self.activeSprite//.presentationNode()
            let sprite = self.activeSprite
            let physics = self.world.physicsWorld
            var info: String = "\n"
            switch type {
            case .PLAYER_INFO:
                info += "\n        vel:\(sprite.velocity.print)\n     Pos:\(sprite.getPosition().print)\n transform:\n\(sprite.transform.print)\n   orientation:\n\(sprite.orientation.print)\n"
                info += "\n       MASS: \(sprite.physicsBody?.mass),  GRAVITY: \(physics.gravity.print)"
                info += "\n   FRICTION: \(node.physicsBody?.friction), Rolling Friction: \(node.physicsBody?.rollingFriction), restitution: \(node.physicsBody?.restitution) \n"
                
                //Accelerometer vs sprite angles
                return info
            case .ANGLES:
                var angles   = "\n ANGLES: \n"
                #if iOS
                if let dPad: RMXMobileInput = Interface.current as? RMXMobileInput {
                    if let att = dPad.motionManager.deviceMotion?.attitude {
                        let attitude = SCNVector3Make(RMFloat(att.pitch), RMFloat(att.yaw), RMFloat(att.roll))
                        angles      += "\n    - SPRITE: \(sprite.presentationNode().eulerAngles.asDegrees)"//, Pitch: \()\n"
                        angles      += "\n    -  PHONE: \(attitude.asDegrees) \n"//Roll: \(), Pitch: \()\n"
                    }
                }
                #endif
                return angles
            case .ACTIVE_CAMERA:
                let camera = self.world.activeCamera as! RMXCameraNode
                

                info += "     left: \(self.world.leftVector.print)         camera: \(camera.presentationNode().worldTransform.left.print)\n"
                info += "       up: \(self.world.upVector.print)               : \(camera.presentationNode().worldTransform.up.print)\n"
                info += "      fwd: \(self.world.forwardVector.print)               : \(camera.presentationNode().worldTransform.forward.print)\n\n"
                info += "   sprite: \(self.activeSprite.getPosition().print)\n"
                info += "   camera: \(camera.presentationNode().worldTransform.position.print)\n"
                info += "\n --- Camera: \(camera.name) ID: \(self.activeSprite.rmxID) : \(camera.rmxID)---\n"
                return info
            case .SCORES:
                info += "\n\n        SCORE: \(self.activeSprite.attributes.points), KILLS: \(self.activeSprite.attributes.killCount)"
                for team in self.world.teams {
                    info += "\n TEAM-\(team.0) SCORE: \(team.1.print)"
                }
                return info
            }
        }
        func debug(yes: Bool = true){
            if yes {
                RMLog(self.getData(), id: "ActionProcessor")
            }
        }

        func animate(){
            if self.boomTimer > 1 {
                self.boomTimer++
//                RMLog(self.boomTimer.print, id: "ActionProcessor")
            }
//            self.debug(false)
        }
            
        
        var extendArm: RMFloat = 0

        
    //    func setOrientation(sprite s: RMXNode? = nil, orientation: SCNQuaternion? = nil, zRotation: CGFloat? = nil, pitch x: RMFloat? = nil, yaw y: RMFloat? = nil, roll z: RMFloat? = nil) {
    //        let sprite = s ?? self.activeSprite
    //        if  orientation != nil {
    //            RMLog("not implemented")
    //        } else {
    //            sprite.setAngle(y, pitch: x, roll: z)
    //        }
    //    }
        /*
        func throwOrGrab(target: Any?, withForce force: RMFloat = 1, tracking: Bool) -> Bool {
            if self.activeSprite.isHoldingItem  {
                let boom = self.boomTimer
                self.boomTimer = 1
                if let target: AnyObject = target as? AnyObject {
                    return self.activeSprite.throwItem(at: target, withForce: force * boom, tracking: tracking)
                } else if let target: SCNVector3 = target as? SCNVector3 {
                    return self.activeSprite.throwItem(atPosition: target, withForce: force * boom)
                }
            } else {
                self.boomTimer = 1
                return self.activeSprite.grabItem(target as? AnyObject)
            }
            self.boomTimer = 1
            return false
        } */
        
        
        func explode(sprite s: RMXNode? = nil, force: RMFloat = 1, range: RMFloat = 500) -> Bool{
            let sprite = s ?? self.activeSprite
            RMSoundBox.current.playSound(UserAction.BOOM.description, info: sprite, range: Float(range))
            return ActionProcessor.explode(sprite, force: force * 10000, range: range)
            
        }
        
        class func explode(sprite: RMXNode?, force: RMFloat = 1, range: RMFloat = 500) -> Bool {
            if let sprite = sprite {
                let world = sprite.scene
                for child in world.sprites {
                    let dist = sprite.distanceToSprite(child)
                    if  dist < range && child.physicsBody?.type != .Static && child != sprite {
                        let direction = (child.getPosition() - sprite.getPosition()).normalised
                        child.applyForce(direction * (force  / (dist + 0.1)) , impulse: true)
                    }
                }
                return true
            }
            return false        
        }
    }
}