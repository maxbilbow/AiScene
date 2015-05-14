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
    lazy var sun: RMXSprite = RMXSprite.Unique(self, asType: .BACKGROUND).makeAsSun(rDist: RMSWorld.RADIUS)
    private let GRAVITY: RMFloatB = 0
    
    
    var activeCamera: SCNNode {
        return self.activeSprite.cameraNode
    }
    
    lazy var activeSprite: RMXSprite = RMXSprite.Unique(self, asType: .PLAYER).asShape(radius: 5, height: 15, shape: .CYLINDER, color: NSColor.yellowColor()).asPlayerOrAI()

    
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
//            self.scene.physicsWorld.gravity = RMXVector3Zero
            let earth = RMXModels.getNode(shapeType: ShapeType.FLOOR.rawValue, mode: .BACKGROUND, radius: radius * 10)
//            earth.physicsField = SCNPhysicsField.radialGravityField()

//            earth.physicsField!.categoryBitMask = Int(SCNPhysicsCollisionCategory.Default.rawValue)
    
            self.scene.rootNode.addChildNode(earth)

            //cameras
            let sunCam: SCNNode = SCNNode()
            self.scene.rootNode.addChildNode(sunCam)
            
            sunCam.camera = RMXCamera()
            sunCam.position = RMXVector3Make(0,0,self.sun.node.pivot.m41)
            self.observer.addCamera(sunCam)
            self.observer.addCamera(poppy.node)
            
    
        
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
    
    func insertChild(child: RMXSprite, insertNode:Bool = true){
        child.parentSprite = nil
        child.world = self
            if insertNode {
                self.scene.rootNode.addChildNode(child.node)
            }
        self.childSpriteArray.set(child)
    }
    
    func insertChildren(children: [RMXSprite], insertNodes:Bool = true){
        for child in children {
            self.insertChild(child, insertNode: insertNodes)
        }
    }

    func insertChildren(#children: [Int:RMXSprite], insertNodes:Bool = true){
        for child in children {
            self.insertChild(child.1, insertNode: insertNodes)
        }
    }
  
    private var _hasGravity: Bool {
        return self.scene.physicsWorld.gravity != SCNVector3Zero
    }
    private var _gravity = SCNVector3Zero
    func toggleGravity() {
        #if SceneKit
            if _hasGravity {
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
            #else
        for object in children {
            let child = object
            if (child != self.observer) && !(child.isLight) {
                child.hasGravity = !child.hasGravity
            }
        }
        #endif
    }

    
    
    func getSprite(#node: RMXNode) -> RMXSprite? {
        
//        if node.physicsBody == nil || node.physicsBody!.type == .Static {
//            return nil
//        } else

        if node.name == nil || node.name!.isEmpty {
            let n = RMXSprite.rootNode(node, rootNode: self.scene.rootNode)
            let sprite = RMXSprite.new(parent: self, node: n)
            return sprite
        } else {
            for sprite in self.children {
                if sprite.name == node.name {
                    return sprite
                }
            }
        }
        let sprite = RMXSprite.new(parent: self)
        sprite.setNode(node)
        return sprite
    }
    
    func animate() {
        self.sun.animate()
        if self.aiOn {
            for child in self.children {
                child.processAi(aiOn: self.aiOn)
            }
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
