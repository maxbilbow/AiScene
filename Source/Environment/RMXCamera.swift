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
        camera.xFov = 65
        camera.focalBlurRadius = 0.05
        //        camera.focalSize
        camera.aperture = 0.005
        camera.focalDistance = 0.001
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
                sprite.node.addChildNode(followCam)
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
        

        let yScale: RMFloatB = sprite.type == .BACKGROUND ? 1 : 3
        let zScale: RMFloatB = sprite.type == .BACKGROUND ? 2 : 2 * 5
        var pos = SCNVector3Make(0,sprite.height * yScale, sprite.radius * zScale)

        
        followCam.position.y = pos.y
        //            followNode.pivot.m41 = pos.x
        //            followNode.pivot.m42 = pos.y
        followCam.pivot.m43 = -pos.z
        if zScale > 1 { followCam.eulerAngles.x = -15 * PI_OVER_180 }
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
    
    internal var _rmxID: Int?
    static var COUNT: Int = 0
    lazy var cameraID: Int = RMXSprite.COUNT++
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

    

    
}