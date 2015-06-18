//
//  RMXBrain.swift
//  AiScene
//
//  Created by Max Bilbow on 25/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import SceneKit


extension SCNNode {
    
   
    @available(OSX 10.10, *)
    var isPointOfView: Bool {
        return (self as? RMXCameraNode)?.isFixedPointOfView ?? false
    }
    
    var doesCollide: Bool {
        return self.rmxNode?.isActor ?? false
    }
    
    @available(OSX 10.10, *)
    var collisionNode: RMXNode? {
        return self.rmxNode //self.parentNode as? RMXNode
    }
    
    
    @available(OSX 10.10, *)
    var rmxNode: RMXNode? {
        return self.pawn as? RMXNode
    }
    
    
    @available(OSX 10.10, *)
    var boundingSphere: (center: SCNVector3, radius: CGFloat) {
        var center: SCNVector3 = SCNVector3Zero; var radius: CGFloat = 0
        self.getBoundingSphereCenter(&center, radius: &radius)
        return (center, radius)
    }
    
    @available(OSX 10.10, *)
    var boundingBox: (min: SCNVector3, max: SCNVector3) {
        var min: SCNVector3 = SCNVector3Zero
        var max: SCNVector3 = SCNVector3Zero
        self.getBoundingBoxMin(&min, max: &max)
        return (min, max)
    }
    
    @available(OSX 10.10, *)
    var radius: CGFloat {
        return self.boundingSphere.radius// * RMFloat(self.scale.average)
    }
    
}
