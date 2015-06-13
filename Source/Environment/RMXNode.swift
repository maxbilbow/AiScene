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

@available(OSX 10.10, *)
class RMXNode : SCNNode {
    
    private var _rmxID: Int?
    

    var rmxSprite: RMXSprite {
        return self._sprite
    }
    
    func getSprite() -> RMXSprite? {
        return self.rmxSprite
    }
    
    func addCollisionAction(named name: String, removeAfterTime time: NSTimeInterval = 3, action: AiCollisionBehaviour) {
        self.collisionActions[name] = action
        if time > 0 {
            NSTimer.scheduledTimerWithTimeInterval(time, target: self, selector: "removeDueCollisionAction:", userInfo: name, repeats: false)
        }
    }
    
    
    
    func removeDueCollisionAction(timer: NSTimer) {
        
        if let name = timer.userInfo as? String {
            RMLog("Collision Action: \(name) was removed from \(self.name!)", id: "Collisions")
            self.collisionActions.removeValueForKey(name)
        }
    }
    
//    func removeCollisionAction(name: String) {
//        if self.rmxSprite?.tracker.isStuck ?? true {
//            self.collisionActions.removeValueForKey(name)
//        } else {
//            NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: "removeCollisionActions", userInfo: nil, repeats: false)
//        }
//    }
    
    func removeCollisionActions() {
        self.collisionActions.removeAll(keepCapacity: true)
//        if self.rmxSprite?.tracker.isStuck ?? true {
//            NSLog(__FUNCTION__)
//            self.collisionActions.removeAll()
//        } else {
//            NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: "removeCollisionActions", userInfo: nil, repeats: false)
//        }
    }
    
        
    internal func setRmxID(ID: Int) {
        _rmxID = ID
    }
   
    init(sprite: RMXSprite){
        self._sprite = sprite
        super.init()
        self._rmxID = sprite.rmxID
//        self._geometryNode = sprite.geometryNode// ?? RMXModels.getNode(shapeType: .CUBE, mode: .PASSIVE, radius: 5)
//        self._geometryNode.name = "\(sprite.name)/geometry"
        sprite.setNode(self)
//        self.addChildNode(self._geometryNode)

        
        
        //self.geometryNode?.physicsBody

        
    }

    func setGeometryNode(node: SCNNode) {
        node.name = "geometry"
        self.addChildNode(node)
        switch self._sprite.type {
            
        case _ where self.sprite!.isPlayerOrAi || self.sprite!.type == .PASSIVE:
            self.physicsBody = SCNPhysicsBody.dynamicBody()
            self.physicsBody?.friction = 0.1
            self.physicsBody?.mass = CGFloat(4 * PI * self.radius * self.radius)
            break
        case .AI, .PASSIVE:
            self.physicsBody?.damping = 0.3
            self.physicsBody?.angularDamping = 0.2
            //            self.physicsBody?.restitution = 0.1
        case _ where self.sprite!.isPlayerOrAi:
            self.physicsBody?.damping = 0.5
            self.physicsBody?.angularDamping = 0.5
            break
        case .PLAYER:
            self.physicsBody?.angularDamping = 0.99
            break
        case .BACKGROUND:
            self.physicsBody = SCNPhysicsBody.staticBody()
            self.physicsBody!.friction = 0.1
            break
        case .KINEMATIC:
            self.physicsBody = SCNPhysicsBody.kinematicBody()
            break
        case .ABSTRACT, .CAMERA:
            self.physicsBody?.mass = 0
            break
        default:
            fatalError()
//        case .:
//            if self.physicsBody == nil {
//                self.physicsBody = SCNPhysicsBody()//.staticBody()
//                self.physicsBody!.restitution = 0.0
//            }
//            break
        }
        
        
        
        switch self._sprite.shapeType {
        case .BOBBLE_MAN:
            
            break
        case .NULL:
            
            break
        default:
            break
        }
        

    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var _sprite: RMXSprite!
    
    func test(node: SCNPhysicsContact) {
//         NSLog("\(self.name): \"ouch! I bumped into \(node.name)\"")
        self.collisionActions.removeValueForKey("ouch")
    }
    
    private lazy var collisionActions: [String:AiCollisionBehaviour] = [
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
            
                
                
@available(OSX 10.10, *)
extension RMXSprite {
    
    
    var transform: SCNMatrix4 {
        return self.node.presentationNode().transform
    }
    
    var position: SCNVector3 {
        return self.node.presentationNode().position//.getPosition()
    }
    
    
//    func presentationNode() -> SCNNode {
//        return self.node.presentationNode()
//    }
    
    var geometry: SCNGeometry? {
        return self.node.geometry ?? self.node.childNodeWithName("geometry", recursively: false)?.geometry
//        return  self.geometryNode?.geometry ?? self.geometryNode?.geometry
    }
    
    var physicsBody: SCNPhysicsBody? {
        return self.node.physicsBody
    }
    
    var physicsField: SCNPhysicsField? {
        return self.node.physicsField
    }
    
    
    func applyForce(direction: SCNVector3, atPosition: SCNVector3? = nil, impulse: Bool = false) {
        if let atPosition = atPosition {
            self.physicsBody?.applyForce(direction, atPosition: atPosition, impulse: impulse)
        } else {
            self.physicsBody?.applyForce(direction, impulse: impulse)
        }
    }
    
    var orientation: SCNQuaternion {
        return self.node.presentationNode().orientation
    }
    
    func resetTransform() {
        self.physicsBody?.resetTransform()
    }
   
}





