//
//  RMXInitialize.swift
//  RattleGL
//
//  Created by Max Bilbow on 23/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GLKit


extension RMX {
    

    
    
    static func makePoppy(#world: RMSWorld, master: RMXSprite) -> RMXSprite{
        let poppy: RMXSprite = RMXSprite(inWorld: world, geometry: RMXModels.getNode(shapeType: ShapeType.BOBBLE_MAN, radius: 10, color: RMColor.darkGrayColor()), type: .AI, shape: .BOBBLE_MAN, unique: true)//.asPlayer()
        
        poppy.setPosition(position: RMXVector3Make(100,10,-50))
        poppy.attributes.setTeamID("\(-1)")
//        RMXAi.playFetch(poppy, master: master)
        poppy.aiDelegate = AiPoppy(poppy: poppy, master: master)
        RMXAi.autoStablise(poppy)
        poppy.setName(name: "Poppy")
        poppy.addCameras()
        world.cameras += poppy.cameras
       
        return poppy
    }
    

    
   
}



