//
//  RMXInitialize.swift
//  RattleGL
//
//  Created by Max Bilbow on 23/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GLKit
//import RMXKit

@available(OSX 10.10, *)
extension RMX {
    

    
    
    static func makePoppy(world world: RMXScene, master: RMXNode) -> RMXNode{
        let poppy: RMXNode = RMXNode(withScene: world, geometryNode: RMXModels.getNode(shapeType: ShapeType.BOBBLE_MAN, radius: 10, color: RMColor.darkGrayColor()), type: .AI, shape: .BOBBLE_MAN, unique: true)//.asPlayer()
        
        poppy.setPosition(SCNVector3Make(100,y: 10,z: -50))
        poppy.attributes.setTeamID("\(-1)")
//        RMXAi.playFetch(poppy, master: master)
        poppy.aiDelegate = AiPoppy(poppy: poppy, master: master)
        RMXAi.autoStablise(poppy)
        poppy.updateName("Poppy")
        poppy.addCameras()
        world.cameras += poppy.cameras
       
        return poppy
    }
    

    
   
}



