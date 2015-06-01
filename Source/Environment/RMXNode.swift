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
    
    private var _rmxID: Int?
    
    override var rmxID: Int {
        if let id = _rmxID {
            return id
        } else {
            _rmxID = self.rootNode?.rmxID
            if _rmxID == nil { NSLog("error -1 RMXID") }
            return _rmxID ?? -1
        }
    }
    //        {
    //        return self.sprite?.rmxID
    //    }
    
    static let ID = "Brain"
    internal var rmxSprite: RMXSprite?
    
    func getSprite() -> RMXSprite? {
        return self.rmxSprite
    }
    
    var rootNode: RMXNode? {
        return self.rmxSprite?.node
    }
    
    
    internal func setRmxID(ID: Int) {
        _rmxID = ID
    }
    
    internal func setSprite(sprite: RMXSprite) {
        self.rmxSprite = sprite
        _rmxID = sprite.rmxID
    }
    
    init(geometry: SCNGeometry, sprite: RMXSprite! = nil){
        super.init()
        let node = SCNNode(geometry: geometry)
        self.geometry = node.geometry
        self.physicsBody = node.physicsBody
        _sprite = sprite
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
    
    func test(node: SCNNode!) {
         NSLog("\(self.name): \"ouch! I bumped into \(node.name)\"")
        self.collisionActions.removeValueForKey("ouch")
    }
    
    lazy var collisionActions: [String:AiBehaviour] = [
        "ouch" : self.test
    ]
    
    func collisionAction(receiver: SCNNode!) {
        for collision in self.collisionActions {
            collision.1(receiver)
        }
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
        return self.node.geometry
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





