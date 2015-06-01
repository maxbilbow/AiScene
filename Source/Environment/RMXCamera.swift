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
enum CameraOptions: Int16 { case FIXED, FREE }
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
    
    private class func node(sprite: RMXSprite) -> RMXCameraNode {
        let cameraNode = RMXCameraNode.new(camera: RMXCamera.standardCamera())
        cameraNode.setRmxID(sprite.rmxID)
        cameraNode.cameraType = .FIXED
        cameraNode.name = "\(cameraNode.cameraID)"
        return cameraNode
    }
    
    class func free(inWorld world: RMSWorld) -> RMXCameraNode {
        let sprite = RMXSprite(inWorld: world, type: .ABSTRACT, isUnique: false)
        let cameraNode = self.node(sprite)
        sprite.setName(name: "\(cameraNode.name!)/FREECAM/\(sprite.name)")
        world.cameras.append(cameraNode)
        return cameraNode
    }
    
    class func followCam(sprite: RMXSprite, option: CameraOptions) -> RMXCameraNode {
        let followCam = self.node(sprite)
        var type = ""
        switch option {
        case .FIXED:
            type = "FIXED"
            sprite.node.addChildNode(followCam)
            break
        case .FREE:
            sprite.addAi({ AiBehaviour in
                if sprite.world.activeCamera.rmxID == followCam.rmxID {
                    followCam.position = sprite.position
                }
            } )
            type = "FREE"
            break
        default:
            type = "UNKNOWN"
            break
        }
        followCam.cameraType = option
        
        followCam.name! += "/\(type)/\(option.rawValue)/\(sprite.name)"
        
        
        
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
        var headcam: RMXCameraNode
        if let head = sprite.node.childNodeWithName("head", recursively: true) {
            headcam = RMXCamera.node(sprite)
            head.addChildNode(headcam)
            sprite.cameras.append(headcam)
        } else {
            sprite.node.camera = RMXCamera.standardCamera()
            headcam = RMXCamera.node(sprite)
        }
        headcam.cameraType = .FIXED
        headcam.name! += "/HEADCAM/\(sprite.name)"
        return headcam
    }


}


class RMXCameraNode : RMXBrain  {

    var isPOV: Bool = false
    
    static var COUNT: Int = 0
    lazy var cameraID: Int = RMXCameraNode.COUNT++
//    var rmxID: Int?
    var cameraType: CameraOptions = .FIXED
    
    class func new(#camera: RMXCamera) -> RMXCameraNode {
        let cameraNode = RMXCameraNode()
        cameraNode.camera = RMXCamera.standardCamera()
        cameraNode.name = "Fixed: \(CameraOptions.FIXED.rawValue)/"
        return cameraNode
    }
    
    func pov() -> RMXCameraNode {
        self.isPOV = true
        return self
    }
    
    
    

    
}