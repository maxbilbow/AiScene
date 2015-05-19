//
//  RMSWorld.swift
//  RattleGL
//
//  Created by Max Bilbow on 10/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GLKit
#if SceneKit
import SceneKit
    #elseif SpriteKit
    import SpriteKit
#endif


enum RMXWorldType: Int { case NULL = -1, TESTING_ENVIRONMENT, SMALL_TEST, FETCH, DEFAULT }
class RMSWorld  {
    
    #if SceneKit
    static let ZERO_GRAVITY = RMXVector3Zero
    static let EARTH_GRAVITY = RMXVector3Make(0, -9.8, 0)
    #elseif SpriteKit
    static let ZERO_GRAVITY = CGVectorZero
    static let EARTH_GRAVITY = CGVector(dx: 0, dy:-9.8)
    #endif
    
    
    var aiOn = false
    lazy var environments: ChildSpriteArray = ChildSpriteArray(parent: self)

    var children: [RMXSprite] {
        return environments.current
    }
    
    var childSpriteArray: ChildSpriteArray{
        return self.environments
    }
    var hasChildren: Bool {
        return self.children.isEmpty
    }
    
    
    var ground: RMFloatB = RMSWorld.RADIUS
    
    init(scene: RMXScene? = nil){
        self.scene = scene ?? RMSWorld.DefaultScene()
        self.worldDidInitialize()
        
    }
    
    var radius: RMFloatB {
        return RMSWorld.RADIUS
    }
    
    static var RADIUS: RMFloatB = 250
    
    static var TYPE: RMXWorldType = .DEFAULT

    var scene: RMXScene
    
    private let GRAVITY: RMFloatB = 0
    
    
    var activeCamera: RMXNode {
        return self.activeSprite.cameraNode
    }

    lazy var activeSprite: RMXSprite = RMXSprite.new(parent: self,
        node: RMXModels.getNode(shapeType: ShapeType.SPHERE.rawValue, mode: .PLAYER, radius: 5, height: 5, color: NSColor.redColor()),
        type: .PLAYER, isUnique: true).asPlayerOrAI() ///TODO: SetNode must remove replacing node (if told / default?)

    
    lazy var observer: RMXSprite = self.activeSprite
    lazy var poppy: RMXSprite = RMX.makePoppy(world: self)
    
    lazy var players: [String: RMXSprite] = [
        self.activeSprite.name: self.activeSprite
    ]
    
    var type: RMXWorldType = .DEFAULT

    
    
    func worldDidInitialize() {

        //DEFAULT
        self.environments.setType(.DEFAULT)
        
        self.insertChildren(children: self.players)

        self.setWorldType()

    }
  
    func setWorldType(worldType type: RMXWorldType = .DEFAULT){
        self.type = type
        self.environments.setType(type)
    }
    
    
    func closestObjectTo(sender: RMXSprite)->RMXSprite? {
        var closest: Int = -1
        var dista: RMFloatB = RMFloatB.infinity// = sender.body.distanceTo(closest)
        for object in children {
            let child = object
            if child != sender {
                let distb: RMFloatB = sender.distanceTo(child)
                if distb < dista {
                    closest = child.rmxID
                    dista = distb
                }
            }
        }
        if let result = self.childSpriteArray.get(closest) {
                return result
            }
        return nil
    }
    
    func furthestObjectFrom(sender: RMXSprite)->RMXSprite? {
        var furthest: Int = -1
        var dista: RMFloatB = 0// = sender.body.distanceTo(closest)
        for object in children {
            let child = object
            if child != sender {
                let distb: RMFloatB = sender.distanceTo(child)
                if distb > dista {
                    furthest = child.rmxID
                    dista = distb
                }
            }
        }
        if let result = self.childSpriteArray.get(furthest){
                return result
        }   else { return nil }
    }
    
    func insertChild(child: RMXSprite, andNode:Bool = true){
        child.parentSprite = nil
        child.world = self
        if andNode {
            #if SceneKit
            self.scene.rootNode.addChildNode(child.node)
            #endif
        }
        //RMXLog("sprite added to world: \(child.name) ----- Node added to Scene: \(child.node.name)")
        self.childSpriteArray.set(child)
    }
    
    func insertChildren(children: [RMXSprite], insertNodes:Bool = true){
        for child in children {
            self.insertChild(child, andNode: insertNodes)
        }
    }

    func insertChildren(#children: [String:RMXSprite], insertNodes:Bool = true){
        for child in children {
            self.insertChild(child.1, andNode: insertNodes)
        }
    }
  
    var hasGravity: Bool {
        return self.scene.physicsWorld.gravity != RMSWorld.ZERO_GRAVITY
    }
    
    private var _gravity = ZERO_GRAVITY
    
    func toggleGravity() {
            if self.hasGravity {
                let gravity = self.scene.physicsWorld.gravity
                _gravity = gravity == RMSWorld.ZERO_GRAVITY ? RMSWorld.EARTH_GRAVITY : gravity
                self.scene.physicsWorld.gravity = RMSWorld.ZERO_GRAVITY
                NSLog("Gravity off: \(self.scene.physicsWorld.gravity.print)")
            } else {
                if _gravity == RMSWorld.ZERO_GRAVITY {
                     _gravity = RMSWorld.EARTH_GRAVITY
                }
                self.scene.physicsWorld.gravity = _gravity
                NSLog("Gravity on: \(self.scene.physicsWorld.gravity.print)")
            }
    }

    
    
    func getSprite(node n: RMXNode, type: RMXSpriteType? = nil) -> RMXSprite? {
    
        let node = RMXSprite.rootNode(n, rootNode: self.scene.rootNode)
        if node.name == nil || node.name == "" {
            let sprite = RMXSprite.new(parent: self, node: node, type: type ?? .PASSIVE, isUnique: false)
            return sprite
        } else {
            for sprite in self.children {
                if sprite.node.name == node.name {
                    return sprite
                }
            }
        }
        let sprite = RMXSprite.new(parent: self, node: node, type: type ?? .PASSIVE, isUnique: false)
        //sprite.setNode(node)
        return sprite
    }
    
    func animate() {
        for child in self.children {
            child.animate(aiOn: self.aiOn)
        }
    }

}


extension RMSWorld {
    func setBehaviours(areOn: Bool){
        self.aiOn = areOn
        for child in children{
            child.aiOn = areOn
        }
        NSLog("aiOn: \(self.aiOn)")
    }
}
