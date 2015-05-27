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
class RMSWorld   {
    
    #if SceneKit
    static let ZERO_GRAVITY = RMXVector3Zero
    static let EARTH_GRAVITY = RMXVector3Make(0, -9.8, 0)
    #elseif SpriteKit
    static let ZERO_GRAVITY = CGVectorZero
    static let EARTH_GRAVITY = CGVector(dx: 0, dy:-9.8)
    #endif
    
    var cameras: Array<RMXNode> = Array<RMXNode>()
    
    var activeCamera: RMXNode? {
        return self.cameras[self.cameraNumber]
    }
    
    func getNextCamera() -> RMXNode {
        self.cameraNumber = self.cameraNumber + 1 >= self.cameras.count ? 0 : self.cameraNumber + 1
        let cameraNode = self.cameras[self.cameraNumber]
        return cameraNode
    }
    
    func getPreviousCamera() -> RMXNode {
        self.cameraNumber = self.cameraNumber - 1 < 0 ? self.cameras.count - 1 : self.cameraNumber - 1
        let cameraNode = self.cameras[self.cameraNumber]
        return cameraNode
    }
    
    var cameraNumber: Int = 0

    
    var aiOn = false
    
    @availability(*,unavailable)
    lazy var environments: SpriteArray = SpriteArray(parent: self)

    var children: Array<RMXSprite> = Array<RMXSprite>()
//    var children: [RMXSprite] {
//        return environments.current
//    }
    
    var hasChildren: Bool {
        return self.children.isEmpty
    }
    
    func deleteWorld(backup: Bool = false) {
        self.children.removeAll()
        self.cameras.removeAll()
        self._gravity = RMSWorld.ZERO_GRAVITY
        self.setScene()
        self.activeSprite = nil
        self.aiOn = false//TODO check if this is right as default
        self.cameraNumber = 0
    }
    
    var ground: RMFloatB = RMSWorld.RADIUS
    
    var interface: RMXInterface
    
    init(interface: RMXInterface, scene: RMXScene? = nil){
        self.interface = interface
//        super.init()
        self.setScene(scene: scene)
        self.worldDidInitialize()
    }
    
    var radius: RMFloatB {
        return RMSWorld.RADIUS
    }
    
    static var RADIUS: RMFloatB = 250
    
    static var TYPE: RMXWorldType = .DEFAULT

    var scene: RMXScene {
        return self._scene
    }
    
    func setScene(scene: RMXScene? = nil){
        self._scene = scene ?? RMSWorld.DefaultScene()
        self._scene.physicsWorld.contactDelegate = self.interface.collider
        self.interface.gameView.scene = self._scene
    }
    
    private var _scene: RMXScene! = nil
    
    private let GRAVITY: RMFloatB = 0
    
    
    

    var activeSprite: RMXSprite?
    
    var observer: RMXSprite? {
        return self.activeSprite ?? self.children.first
    }
    
//    lazy var players: [String: RMXSprite] = [
//        self.activeSprite.name: self.activeSprite
//    ]
    
    var type: RMXWorldType = .DEFAULT
    
    func worldDidInitialize() {
        
    }
  
    @availability(*,deprecated=1)
    func setWorldType(worldType type: RMXWorldType = .DEFAULT){
        self.type = type
//        self.environments.setType(type)
    }
    
    @availability(*,deprecated=1)
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
        if let result = SpriteArray.get(closest, inArray: self.children) {
                return result
            }
        return nil
    }
    @availability(*,deprecated=1)
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
        if let result = SpriteArray.get(furthest, inArray: self.children){
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
//        self.childSpriteArray.set(child)
        self.children.append(child)
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
    
    var gravity: RMXVector3 {
        return self.scene.physicsWorld.gravity
    }
    
    func toggleGravity() {
            if self.hasGravity {
                let gravity = self.scene.physicsWorld.gravity
                _gravity = gravity == RMSWorld.ZERO_GRAVITY ? RMSWorld.EARTH_GRAVITY : gravity
                self.scene.physicsWorld.gravity = RMSWorld.ZERO_GRAVITY
                RMXLog("Gravity off: \(self.scene.physicsWorld.gravity.print)")
            } else {
                if _gravity == RMSWorld.ZERO_GRAVITY {
                     _gravity = RMSWorld.EARTH_GRAVITY
                }
                self.scene.physicsWorld.gravity = _gravity
                RMXLog("Gravity on: \(self.scene.physicsWorld.gravity.print)")
            }
    }

    
    @availability(*,unavailable)
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
        self.scene.physicsWorld.updateCollisionPairs()
    }

    
}


extension RMSWorld {
   @availability(*,unavailable)
    func setBehaviours(areOn: Bool){
        self.aiOn = areOn
        for child in children{
            child.aiOn = areOn
        }
        RMXLog("aiOn: \(self.aiOn)")
    }
}

extension RMSWorld {

    var forwardVector: RMXVector {
        return self.activeCamera!.presentationNode().worldTransform.forward// ?? RMXVector3Make(0,0,-1)
    }
    
    var upVector: RMXVector {
        return self.activeCamera!.presentationNode().worldTransform.up// ?? RMXVector3Make(0,1,0)
    }
    
    var leftVector: RMXVector {
        return self.activeCamera!.presentationNode().worldTransform.left// ?? RMXVector3Make(-1,0,0)
    }
    
}
