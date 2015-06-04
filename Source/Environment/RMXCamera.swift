//
//  RMXCamera.swift
//  RattleGL
//
//  Created by Max Bilbow on 13/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GLKit

import SceneKit

//typealias RMXCamera = SCNCamera
enum CameraOptions: Int16 { case FIXED, FREE, SLOW_FOLLOW }
class RMXCamera : SCNCamera {
    
    class func standardCamera() -> RMXCamera {
        let camera = RMXCamera()
        camera.zNear = 0.1
        camera.zFar = 10000
        camera.yFov = 65
        camera.xFov = 65// * 16 / 9
//        camera.focalBlurRadius = 0.05
        //        camera.focalSize
        camera.aperture = 0.75
        camera.focalDistance = 240
        camera.focalBlurRadius = 3
        camera.focalSize = 1000
        return camera
    }
    
    
    
    class func free(inWorld world: RMSWorld) -> RMXCameraNode {
//        let sprite = RMXSprite(inWorld: world, type: .ABSTRACT, isUnique: false)
        let cameraNode = RMXCameraNode(world: world)
        cameraNode.name = "\(cameraNode.name!)/FREE/\(world.rmxID)"
        cameraNode.cameraType = .FREE
        world.cameras.append(cameraNode)
        return cameraNode
    }
    
    class func followCam(sprite: RMXSprite, option: CameraOptions) -> RMXCameraNode {
        let followCam = RMXCameraNode(sprite: sprite)
        var type = "FREE"
        followCam.cameraType = .FREE
        if sprite.type == .PLAYER {
            switch option {
            case .FIXED:
                type = "FIXED"
                followCam.cameraType = .FIXED
                if let head = sprite.node.childNodeWithName("head", recursively: true) {
                    head.addChildNode(followCam)
                } else {
                    sprite.node.addChildNode(followCam)
                }
                break
            case .FREE:
//                followCam.node
                sprite.addAi({ AiBehaviour in
                    if sprite.world.activeCamera.rmxID == followCam.rmxID {
                        followCam.position = sprite.position
                    }
                } )
                type = "FREE"
                followCam.cameraType = .FREE
                break
            case .SLOW_FOLLOW:
                type = "SLOW-FOLLOW"
                followCam.cameraType = sprite.type == .PLAYER ? .FIXED : .FREE
                let slowFollow = SCNAction.moveTo(followCam.position, duration: 1)
                sprite.addAi({ AiBehaviour in
                    if sprite.world.activeCamera.rmxID == followCam.rmxID {
                            //followCam.runAction(slowFollow)
                    }
                } )

            
                break
            default:
                type = "UNKNOWN"
                fatalError(__FUNCTION__)
                break
            }
        }
        followCam.name! += "/\(type)/\(sprite.name)"
        
        
        
        sprite.cameras.append(followCam)
        

//        let yScale: RMFloatB = sprite.type == .BACKGROUND ? 1 : 3
//        let zScale: RMFloatB = sprite.type == .BACKGROUND ? 2 : 2 * 5
//        var pos = SCNVector3Make(0,sprite.height * yScale, sprite.radius * zScale)

        

        followCam.restingPivotPoint.z = -(100 + sprite.radius)
        followCam.restingEulerAngles.x = -25 * PI_OVER_180
        
        followCam.pivot.m43 = followCam.restingPivotPoint.z
        followCam.eulerAngles.x = followCam.restingEulerAngles.x
        
        return followCam
    }
    
    class func headcam(sprite: RMXSprite) -> RMXCameraNode {
        var headcam: RMXCameraNode = RMXCameraNode(sprite: sprite)
        headcam.cameraType = sprite.type == .PLAYER ? .FIXED : .FREE
        let type: String = headcam.cameraType == .FIXED ? "FIXED" : "FREE"
        headcam.name! += "\(type)/HEADCAM/\(sprite.name)"
        
        sprite.cameras.append(headcam)
        if let head = sprite.node.childNodeWithName("head", recursively: true) {
            head.addChildNode(headcam)
            
        } else {
            sprite.node.addChildNode(headcam)
        }
       
        return headcam
    }

    
}


class RMXCameraNode : SCNNode {
    var rmxSprite: RMXSprite?
    var world: RMSWorld
    var restingPivotPoint: SCNVector3 = SCNVector3Zero
    var restingEulerAngles: SCNVector3 = SCNVector3Zero
    var restingFOV: Double = 65
    internal var _rmxID: Int?
    static var COUNT: Int = 0
    lazy var cameraID: Int = RMX.COUNT++
//    var rmxID: Int?
    var cameraType: CameraOptions = .FIXED
    
    init(sprite: RMXSprite? = nil, world: RMSWorld! = nil) {
        self.rmxSprite = sprite ?? world.activeSprite
        self._rmxID = sprite?.rmxID ?? world.activeSprite.rmxID ?? world.rmxID
        self.world = sprite?.world ?? world
        super.init()
        self.camera = RMXCamera.standardCamera()
        self.name = "CAM\(self.cameraID)"
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var isFixedPointOfView: Bool {
        return cameraType == .FIXED// && self.rmxID == world.activeSprite.rmxID
    }
    
    var isActiveCamera: Bool {
        return self == self.world.activeCamera
    }
    
    func resetPosition() -> Bool {
        if self._resetZoom {
            self.calibrate(pos: true, force: true, speed: 1)
            self._resetZoom = !(self.pivot.position.z == self.restingPivotPoint.z && self.fov == self.camera!.xFov)
        }
        return self._resetZoom
        
    }
    
    func resetOrientation() -> Bool {
        if self._resetOrientation {
            self.calibrate(x: true, y: true, z: true, force: true, speed: 1)
            self._resetOrientation = !(self.eulerAngles.x == self.restingEulerAngles.x)
        }
        return self._resetOrientation
        
    }
    
    private var _resetZoom: Bool = false
    func zoomNeedsReset() {
        self._resetZoom = true
    }
    
    private var _resetOrientation: Bool = false
    func orientationNeedsReset() {
        self._resetOrientation = true
    }
    
    private func _calibrate(var value: RMFloatB,_ target: RMFloatB,_ i: RMFloatB) -> RMFloatB {
        if value == target {
            return value
        } else if value < target {
            value += i
            if value > target {
                value = target
            }
        } else if value > target {
            value -= i
            if value < target {
                value = target
            }
        }
        return value
    
    }
    
    func calibrate(x: Bool = true, y: Bool = false, z: Bool = false, pos: Bool = false, force: Bool = false, speed: RMFloatB = 1) -> Bool {
        if self.shouldAutoCalibrate || force {
            if x { self.eulerAngles.x = _calibrate(self.eulerAngles.x, self.restingEulerAngles.x, speed * 0.01) }
            if y { self.eulerAngles.y = _calibrate(self.eulerAngles.y, self.restingEulerAngles.y, speed * 0.01) }
            if z { self.eulerAngles.z = _calibrate(self.eulerAngles.z, self.restingEulerAngles.z, speed * 0.01) }
        
            if pos {
                self.camera?.xFov = Double(_calibrate(RMFloatB(self.camera!.xFov), 65, RMFloatB(speed)))
                self.camera?.yFov = self.camera!.xFov //_calibrate(self.camera!.yFov, 65, speed)
                self.pivot.m41 = RMFloatB(_calibrate(self.pivot.m41, self.restingPivotPoint.x, speed))
                self.pivot.m42 = RMFloatB(_calibrate(self.pivot.m42, self.restingPivotPoint.y, speed))
                self.pivot.m43 = RMFloatB(_calibrate(self.pivot.m43, self.restingPivotPoint.z, speed))
            }
        }
        return self.pivot.position.z == self.restingPivotPoint.z && self.eulerAngles.x == self.restingEulerAngles.x && self.fov == self.camera!.xFov
    }
    
    private let fovYMin: Double = 10
    lazy private var fovXMin: Double = self.fovYMin// * 16 / 9
    
    private let zoomSpeed: Double = 0.5
    var zoomRatio: RMFloatB = 0.98

    func moveIn(speed: RMFloatB = 1) {
//        print()
        
        if let fov = self.camera?.xFov {
            if self.pivot.m43 < 0 {
                if self.pivot.m43 <= self.zMin {
                    self.camera?.zFar = Double(self.pivot.m43)
                }
                self.pivot.m43 = self.pivot.m43 * zoomRatio + 0.5 * speed
                if self.isFixedPointOfView {
                    self.eulerAngles.x *= 0.99
                }
                
            } else if self.pivot.m43 == 0 && fov != self.fovXMin {
                if fov < self.fovXMin {
                    self.camera?.xFov = self.fovXMin
                    self.camera?.yFov = self.fovYMin
                } else {
                    self.camera?.xFov -= zoomSpeed * Double(speed)
                    self.camera?.yFov -= zoomSpeed * Double(speed)
                }
            } else if self.pivot.m43 > 0 {
                self.pivot.m43 = 0
            }
        }
    }
    
    lazy var zMin: RMFloatB = -RMFloatB(self.camera!.zFar)
//        {
//        return self.world.radius - RMFloatB(self.camera!.zFar)
//    }
    
    var fov: Double {
        return self.camera!.xFov //+ self.camera!.yFov / 2
    }
    
    var zoomFactor: RMFloatB {
        if self.pivot.m43 < self.zMin {
            return 0.25
        } else {
            return RMFloatB(self.fov / self.restingFOV) * (1 - self.pivot.m43 * 0.75 / self.zMin)
        }
    }
    func print() {
        var s = ""
        s += "\n   pivot: \(self.pivot.position.print), FOV: \(fov.toData()), phi: \(self.eulerAngles.x.toData()), zoomFactor: \(self.zoomFactor.toData())"
       
        s += "\n   focalSize: \(self.camera!.focalSize.print), fDist: \(self.camera!.focalDistance.print), fBlurRad: \(self.camera!.focalBlurRadius.print)"
        s += "\n   appeture: \(self.camera!.aperture.print), orthScale: \(self.camera!.orthographicScale.print)\n zFar: \(self.camera!.zFar)"
        println(s)
    }
    func moveOut(speed: RMFloatB = 1) {
//        print()
        if let fov = self.camera?.xFov {
//            NSLog("pivot: \(self.pivot.position.print), FOV: \(fov.toData()), phi: \(self.eulerAngles.x.toData()), zoomFactor: \(self.zoomFactor.toData())")
            
            if fov < self.restingFOV {
                self.camera?.xFov += zoomSpeed * Double(speed)
                self.camera?.yFov += zoomSpeed * Double(speed)
//                self.camera?.focalSize
            } else if fov > self.restingFOV {
                self.camera?.xFov = self.restingFOV
                self.camera?.yFov = self.restingFOV
//            } else if self.pivot.m43 > self.zMin {
//                self.pivot.m43 = self.pivot.m43 / zoomRatio - 0.5 * speed
            } else {
                self.pivot.m43 = self.pivot.m43 / zoomRatio - 0.5 * speed
                if self.pivot.m43 < self.zMin + self.world.radius{
                    self.camera?.zFar = Double(self.pivot.m43)
                }
            }
        }
    }

    var shouldAutoCalibrate: Bool {
        return self.cameraType == .FIXED && self.isActiveCamera
    }
    
}