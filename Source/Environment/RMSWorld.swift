//
//  RMSWorld.swift
//  RattleGL
//
//  Created by Max Bilbow on 10/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GLKit
import SceneKit

enum RMXWorldType: Int { case NULL = -1, TESTING_ENVIRONMENT, SMALL_TEST, FETCH, DEFAULT }
class RMSWorld  {
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
    
    init(scene: SCNScene? = nil){
        self.scene = scene ?? SCNScene(named: "art.scnassets/ship.dae")!
        self.worldDidInitialize()
        
    }
    
    var radius: RMFloatB {
        return RMSWorld.RADIUS
    }
    
    static var RADIUS: RMFloatB = 250
    
    static var TYPE: RMXWorldType = .DEFAULT

    var scene: SCNScene
    lazy var sun: RMXSprite = RMXSprite.new(parent: self, type: .BACKGROUND, isUnique: true).makeAsSun(rDist: RMSWorld.RADIUS)
    lazy var earth: RMXSprite = RMXSprite.new(parent: self, node: RMXModels.getNode(shapeType: ShapeType.FLOOR.rawValue, mode: .BACKGROUND, radius: RMSWorld.RADIUS * 15, color: NSColor.yellowColor()), type: .BACKGROUND, isUnique: true)
    private let GRAVITY: RMFloatB = 0
    
    
    var activeCamera: SCNNode {
        return self.activeSprite.cameraNode
    }

    lazy var activeSprite: RMXSprite = RMXSprite.new(parent: self, type: .PLAYER, isUnique: true).asShape(radius: 5, height: 5, shape: .SPHERE, color: NSColor.redColor()).asPlayerOrAI()

    
    lazy var observer: RMXSprite = self.activeSprite
    lazy var poppy: RMXSprite = RMX.makePoppy(world: self)
    lazy var players: [Int: RMXSprite] = [
        self.activeSprite.rmxID: self.activeSprite ,
        self.poppy.rmxID: self.poppy,
        self.sun.rmxID: self.sun
    ]
    
    var type: RMXWorldType = .DEFAULT

    
    func worldDidInitialize() {
        let radius = RMSWorld.RADIUS
            self.scene.physicsWorld.gravity = RMXVector3Make(0,-9.8 * 10,0)
        
//            earth.physicsField = SCNPhysicsField.radialGravityField()

//            earth.physicsField!.categoryBitMask = Int(SCNPhysicsCollisionCategory.Default.rawValue)

        self.earth.setName(name: "The Ground")
        self.earth.setPosition(position: RMXVector3Make(0,-RMSWorld.RADIUS * 2.5, 0))
        self.insertChild(self.earth, andNode: true)

        //cameras
        let sunCam: SCNNode = SCNNode()
        self.scene.rootNode.addChildNode(sunCam)
        
        sunCam.camera = RMXCamera()
        sunCam.position = RMXVector3Make(0 , 100, radius)
        self.observer.addCamera(sunCam)
        self.observer.addCamera(self.poppy.node)
            
    
        
        //DEFAULT
        self.environments.setType(.DEFAULT)
        RMXArt.initializeTestingEnvironment(self,withAxis: true, withCubes: 100, radius: 500 + radius)
        self.insertChildren(children: self.players)

        setWorldType()

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
            self.scene.rootNode.addChildNode(child.node)
        }
        //RMXLog("sprite added to world: \(child.name) ----- Node added to Scene: \(child.node.name)")
        self.childSpriteArray.set(child)
    }
    
    func insertChildren(children: [RMXSprite], insertNodes:Bool = true){
        for child in children {
            self.insertChild(child, andNode: insertNodes)
        }
    }

    func insertChildren(#children: [Int:RMXSprite], insertNodes:Bool = true){
        for child in children {
            self.insertChild(child.1, andNode: insertNodes)
        }
    }
  
    var hasGravity: Bool {
        return self.scene.physicsWorld.gravity != SCNVector3Zero
    }
    private var _gravity = SCNVector3Zero
    func toggleGravity() {
            if self.hasGravity {
                let gravity = self.scene.physicsWorld.gravity
                _gravity = gravity == SCNVector3Zero ? SCNVector3Make(0, -2, 0) : gravity
                self.scene.physicsWorld.gravity = SCNVector3Zero
                NSLog("Gravity off: \(self.scene.physicsWorld.gravity.print)")
            } else {
                if _gravity == RMXVector3Zero {
                     _gravity = SCNVector3Make(0, -self.GRAVITY, 0)
                }
                self.scene.physicsWorld.gravity = _gravity
                NSLog("Gravity on: \(self.scene.physicsWorld.gravity.print)")
            }
    }

    
    
    func getSprite(node n: RMXNode, type: RMXSpriteType? = nil) -> RMXSprite? {
        
//        if node.physicsBody == nil || node.physicsBody!.type == .Static {
//            return nil
//        } else
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
//        self.sun.animate()
//        self.poppy.animate()
//        self.activeSprite.animate()
        self.earth.resetTransform()
        for child in self.children {
            child.animate(aiOn: self.aiOn)
        }
//        for child in children {
//            child.animate()
//        }
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
