//
//  RMXCoupling.swift
//  AiScene
//
//  Created by Max Bilbow on 19/07/2015.
//  Copyright © 2015 Rattle Media. All rights reserved.
//

import Foundation
import SceneKit

typealias NodePair = (A: RMXNode, B: RMXNode)
class RMXCoupling : SCNPhysicsBallSocketJoint {
    
    
    
    class func Make(actor: RMXNode, receiver: RMXNode) -> SCNPhysicsBallSocketJoint {
//        receiver.isLocked = true;
        actor.removeCollisionActions()
        receiver.removeCollisionActions()
        if !receiver.isActor { ///reduce mass to 1% of sprite unless its another player
            receiver.setMass(actor.physicsBody!.mass * 0.01)
            receiver.physicsBody?.restitution = 0.01
            receiver.physicsBody?.friction = 0.01
        }
        
        let coupling = SCNPhysicsBallSocketJoint(bodyA: actor.physicsBody!, anchorA: actor.socket.getPosition(), bodyB: receiver.physicsBody!, anchorB: receiver.socket.getPosition())
        actor.coupling = coupling
        receiver.coupling = coupling
        actor.scene.addCoupling(coupling, nodeA: actor, nodeB: receiver)
        return coupling
    }
    
    class func UnCouple(coupling: SCNPhysicsBallSocketJoint, scene: RMXScene) {
        coupling.unCouple(scene)
    }
    
}

extension SCNPhysicsBallSocketJoint {
    
    func getNodes(inScene scene: RMXScene) -> NodePair? {
        return scene.couplings[self]
    }
    func nodeA(inScene scene: RMXScene) -> RMXNode? {
        return scene.couplings[self]?.A
    }
    
    func nodeB(inScene scene: RMXScene) -> RMXNode? {
        return scene.couplings[self]?.B
    }

    
    func unCouple(scene: RMXScene) {
        if let nodes = scene.couplings[self] {
            nodes.B.setMass()
            nodes.B.physicsBody?.restitution = 0.5
            nodes.B.physicsBody?.friction = 0.5
//            nodeB.isLocked = false
        }
        scene.removeCoupling(self)
    }

}