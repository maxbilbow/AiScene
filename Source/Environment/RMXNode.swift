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
   

protocol RMXChildNode {
    var node: RMXNode { get set }
    var parentNode: RMXNode? { get }
    var parentSprite: RMXSprite? { get set }
}

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
    
    var rootNode: RMXNode? {
        return self.rmxSprite?.node
    }
    
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
    
    internal func setSprite(sprite: RMXSprite) {
        self.rmxSprite = sprite
        _rmxID = sprite.rmxID
    }
    
    init(geometry node: SCNNode, sprite: RMXSprite! = nil){
        super.init()
//        let node = SCNNode(geometry: geometry)
//        self.geometry = node.geometry
        self.physicsBody = node.physicsBody
        self._geometryNode = node
        _sprite = sprite
        self.addChildNode(node)
    }
    
    
    override init(){
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var _sprite: RMXSprite?
    internal var spriteDirect: RMXSprite? {
        return _sprite
    }
    
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
    
    var boundingSphere: (center: RMXVector3, radius: RMFloatB) {
        var center: RMXVector3 = RMXVector3Zero
        var radius: RMFloat = 0
        self._geometryNode.getBoundingSphereCenter(&center, radius: &radius)
        return (center, RMFloatB(radius))
    }
    
    var boundingBox: (min: RMXVector, max: RMXVector) {
        var min: RMXVector3 = RMXVector3Zero
        var max: RMXVector3 = RMXVector3Zero
        self._geometryNode.getBoundingBoxMin(&min, max: &max)
        return (min, max)
    }
    
    var radius: RMFloatB {
        // let radius = RMXVector3Length(self.boundingBox.max * self.scale)
        return self.boundingSphere.radius * RMFloatB(self.scale.average)//radius
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
        return self.node.presentationNode().transform
    }
    
    var position: RMXVector3 {
        return self.node.presentationNode().position
    }
    
    
    func presentationNode() -> SCNNode {
        return self.node.presentationNode()
    }
    var geometry: SCNGeometry? {
        return self.geometryNode?.geometry
    }
    
    var physicsBody: SCNPhysicsBody? {
        return self.node.physicsBody
    }
    
    var physicsField: SCNPhysicsField? {
        return self.node.physicsField
    }
    
    
    func applyForce(direction: SCNVector3, atPosition: SCNVector3? = nil, impulse: Bool = false) {
        if let atPosition = atPosition {
            self.node.physicsBody?.applyForce(direction, atPosition: atPosition, impulse: impulse)
        } else {
            self.node.physicsBody?.applyForce(direction, impulse: impulse)
        }
    }
    
    var orientation: SCNQuaternion {
        return self.presentationNode().orientation
    }
    
    func resetTransform() {
        self.node.physicsBody?.resetTransform()
    }
   
}





