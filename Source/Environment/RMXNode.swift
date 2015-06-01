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
    init(geometry: SCNGeometry){
        super.init()
        let node = SCNNode(geometry: geometry)
        self.geometry = node.geometry
        self.physicsBody = node.physicsBody
        _sprite = sprite
    }
    
    ///this doens not add the node to the sprite. However the reverse is true
    func setSprite(sprite: RMXSprite) {
        _sprite = sprite
    }
  
    override init() {
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var _sprite: RMXSprite?
    
    func getSprite() -> RMXSprite? {
        return _sprite
    }
    
    override func addChildNode(child: SCNNode) {
        if let child = child as? RMXNode {
            child._sprite = self._sprite
        }
        super.addChildNode(child)
    }
    
    override func removeFromParentNode() {
        _sprite = nil
        super.removeFromParentNode()
    }

}






