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
        let poppy: RMXSprite = RMXSprite.new(inWorld: world, node: RMXModels.getNode(shapeType: ShapeType.BOBBLE_MAN, mode: .AI, radius: 10, color: RMColor.darkGrayColor()), type: .AI, isUnique: true).asPlayer()
        
        poppy.setPosition(position: RMXVector3Make(100,10,-50))
        poppy.attributes.setTeam(ID: -1)
//        RMXAi.playFetch(poppy, master: master)
        poppy.aiDelegate = AiPoppy(poppy: poppy, master: master)
        RMXAi.autoStablise(poppy)
       
        return poppy
    }
    

    
   
}



