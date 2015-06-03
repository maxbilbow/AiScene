//
//  RMXNode.swift
//  RattleGL3-0
//
//  Created by Max Bilbow on 10/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//
import GLKit
import Foundation

import SceneKit

    //typealias RMXNode = SCNNode


class RMXNode : SCNNode {
    
    internal var _geometryNode: SCNNode!
    
    private var _rmxID: Int?
    
//    override var rmxID: Int {
//        return self.rmxSprite.rmxID
//        if let id = _rmxID {
//            return id
//        } else {
//            _rmxID = self.rootNode?.rmxID
//            if _rmxID == nil { NSLog("error -1 RMXID") }
//            return _rmxID ?? -1
//        }
//    }

    internal var rmxSprite: RMXSprite?
    
    func getSprite() -> RMXSprite? {
        return self.rmxSprite
    }
    
//    var rootNode: RMXNode? {
//        return self.rmxSprite?.rmxNode
//    }
    
    
    func removeCollisionAction(name: String) {
        if self.rmxSprite?.tracker.isStuck ?? true {
            self.collisionActions.removeValueForKey(name)
        } else {
            NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: "removeCollisionActions", userInfo: nil, repeats: false)
        }
    }
    func removeCollisionActions() {
        if self.rmxSprite?.tracker.isStuck ?? true {
            NSLog(__FUNCTION__)
            self.collisionActions.removeAll()
        } else {
            NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: "removeCollisionActions", userInfo: nil, repeats: false)
        }
    }
    
        
    internal func setRmxID(ID: Int) {
        _rmxID = ID
    }
   
    init(sprite: RMXSprite){
        self.rmxSprite = sprite
        super.init()
        self._rmxID = sprite.rmxID
        self._geometryNode = sprite.geometryNode// ?? RMXModels.getNode(shapeType: .CUBE, mode: .PASSIVE, radius: 5)
        self._geometryNode.name = "\(sprite.name)/geometry"
        sprite.setNode(self)
        self.addChildNode(self._geometryNode)

        switch sprite.type {
        case .AI, .PLAYER, .PASSIVE, .PLAYER_OR_AI:
            self.physicsBody = SCNPhysicsBody.dynamicBody()
            self.physicsBody!.restitution = 0.1
            self.physicsBody!.angularDamping = 0.5
            self.physicsBody!.damping = 0.5
            self.physicsBody!.friction = 0.1
            break
        case .BACKGROUND:
            self.physicsBody = SCNPhysicsBody.staticBody()
            self.physicsBody!.restitution = 0.1
            self.physicsBody!.damping = 1000
            self.physicsBody!.angularDamping = 1000
            self.physicsBody!.friction = 0.1
            break
        case .KINEMATIC:
            self.physicsBody = SCNPhysicsBody.kinematicBody()
            self.physicsBody!.restitution = 0.1
            self.physicsBody!.friction = 0.1
            break
        case .ABSTRACT:
            break
        default:
            if self.physicsBody == nil {
                self.physicsBody = SCNPhysicsBody()//.staticBody()
                self.physicsBody!.restitution = 0.0
            }
        }
        
        self.physicsBody?.mass = RMFloat(4 * PI * self.radius * self.radius)
        
        switch sprite.shapeType {
        case .BOBBLE_MAN:
            self.physicsBody!.angularDamping = 0.99
            break
        case .NULL:
            self.physicsBody?.mass = 0
            break
        default:
            break
        }

        
        
        //self.geometryNode?.physicsBody

        
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var _sprite: RMXSprite?
    
    func test(node: SCNPhysicsContact) {
//         NSLog("\(self.name): \"ouch! I bumped into \(node.name)\"")
        self.collisionActions.removeValueForKey("ouch")
    }
    
    lazy var collisionActions: [String:AiCollisionBehaviour] = [
        "ouch" : self.test
    ]
    
    func collisionAction(contact: SCNPhysicsContact) {
        for collision in self.collisionActions {
            collision.1(contact)
        }
    }
    
    override func runAction(action: SCNAction, forKey key: String?, completionHandler block: (() -> Void)?) {
        super.runAction(action, forKey: key, completionHandler: block)
    }
    
    var isActiveSprite: Bool {
        return self.sprite?.isActiveSprite ?? false
    }
    
    
    var isHeld: Bool {
        return self.sprite?.isLocked ?? false
    }
    
    var holder: RMXSprite? {
        return self.sprite?.holder
    }
    
    
}

extension RMXSprite {

    
    var transform: RMXMatrix4 {
        return self.presentationNode().transform
    }
    
    var position: RMXVector3 {
        return self.presentationNode().position
    }
    
    
    func presentationNode() -> SCNNode {
        return self.node.presentationNode()
    }
    var geometry: SCNGeometry? {
        return self.geometryNode?.geometry ?? self.geometryNode?.geometry
    }
    
    var physicsBody: SCNPhysicsBody? {
        return self.node.physicsBody ?? self.geometryNode?.physicsBody
    }
    
    var physicsField: SCNPhysicsField? {
        return self.node.physicsField ?? self.geometryNode?.physicsField
    }
    
    
    func applyForce(direction: SCNVector3, atPosition: SCNVector3? = nil, impulse: Bool = false) {
        if let atPosition = atPosition {
            self.physicsBody?.applyForce(direction, atPosition: atPosition, impulse: impulse)
        } else {
            self.physicsBody?.applyForce(direction, impulse: impulse)
        }
    }
    
    var orientation: SCNQuaternion {
        return self.presentationNode().orientation
    }
    
    func resetTransform() {
        self.physicsBody?.resetTransform()
    }
   
}





