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

typealias RMXCamera = SCNCamera

extension RMX  {
    
    static func standardCamera() -> SCNCamera {
        let camera = SCNCamera()
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
    


    
}