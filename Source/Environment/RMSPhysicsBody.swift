//
//  RMSPhysicsBody.swift
//  RattleGL
//
//  Created by Max Bilbow on 10/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//


import GLKit
import SceneKit


extension RMXSprite {
    
    
    

}

extension RMXSprite {
    func setRadius(radius: RMFloatB){
        let s = radius * 2
        self.node.scale = RMXVector3Make(s,s,s)
    }
    
    var weight: RMFloatB {
        return RMFloatB(self.node.physicsBody!.mass)// * self.world.gravity
    }
   
    func distanceTo(point: RMXVector3 = RMXVector3Zero) -> RMFloatB{
        return RMXVector3Distance(self.position, point)
    }
    
    func distanceTo(object:RMXSprite) -> RMFloatB{
            return RMXVector3Distance(self.position,object.position)
    }
    
    


    var velocity: RMXVector3 {
        if let body = self.physicsBody {
            return body.velocity
        } else {
            return RMXVector3Zero
        }
    }

    

   
    
}