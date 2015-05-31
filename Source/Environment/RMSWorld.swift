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


//enum GameType: Int { case NULL = -1, TESTING_ENVIRONMENT, SMALL_TEST, FETCH, DEFAULT }
class RMSWorld : RMXUniqueEntity {
    
    var teams: [Int : RMXTeam] = Dictionary<Int,RMXTeam>()
    lazy var rmxID: Int = RMXSprite.COUNT++
    #if SceneKit
    static let ZERO_GRAVITY = RMXVector3Zero
    static let EARTH_GRAVITY = RMXVector3Make(0, -9.8, 0)
    #elseif SpriteKit
    static let ZERO_GRAVITY = CGVectorZero
    static let EARTH_GRAVITY = CGVector(dx: 0, dy:-9.8)
    #endif
    
    var cameras: Array<RMXCameraNode> = Array<RMXCameraNode>()
    
    var activeCamera: RMXCameraNode {
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

    var children: Array<RMXSprite> = Array<RMXSprite>()
//    var children: [RMXSprite] {
//        return environments.current
//    }
    
    var hasChildren: Bool {
        return self.children.isEmpty
    }
    
    internal func destroy() -> RMSWorld {
        self.children.removeAll()
        self.cameras.removeAll()
        self._gravity = RMSWorld.ZERO_GRAVITY
        _activeSprite = nil
        self.setScene()
        self.aiOn = true//TODO check if this is right as default
        return self
    }
    
    
    var ground: RMFloatB = RMSWorld.RADIUS
    
    var interface: RMXInterface
    
    init(interface: RMXInterface){
        self.interface = interface
        self.worldDidInitialize()
    }
    
    var radius: RMFloatB {
        return RMSWorld.RADIUS
    }
    
    static var RADIUS: RMFloatB = 250
    


    var scene: RMXScene {
        return self._scene ?? self.setScene()
    }
    
    ///Note: May become public
    private func setScene(scene: RMXScene? = nil) -> RMXScene {
        self._scene = scene ?? RMSWorld.DefaultScene()
        self.cameras = self.activeSprite.cameras +  self.cameras
        self.cameraNumber = 0
        self._scene.physicsWorld.contactDelegate = self.interface.collider
        self.calibrate()
        return self._scene
    }
    
    func calibrate() {
        self.interface.gameView!.scene = self._scene
        self.interface.gameView!.pointOfView = self.activeCamera
        self.interface.pauseGame(self)
        self.interface.unPauseGame(self)
    }
    
    private var _scene: RMXScene! = nil
    
    private let GRAVITY: RMFloatB = 0
    
    
    private var _activeSprite: RMXSprite!

    var activeSprite: RMXSprite {
        return _activeSprite ?? _defaultPlayer
    }
    
    private var _defaultPlayer: RMXSprite  {
        _activeSprite = AiCubo.simpleUniquePlayer(self)
        _activeSprite.setName(name: "Player")
        return _activeSprite
    }
    
    func worldDidInitialize() {
        self.setScene()
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
       return RMX.spriteWith(ID: closest, inArray: self.children)
    
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
        return RMX.spriteWith(ID: furthest, inArray: self.children)
    }
    
    func insertChild(child: RMXSprite, andNode:Bool = true){
        self.children.append(child)
        if andNode {
            self.scene.rootNode.addChildNode(child.node)
        }
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
            let sprite = RMXSprite.new(inWorld: self, node: node, type: type ?? .PASSIVE, isUnique: false)
            return sprite
        } else {
            for sprite in self.children {
                if sprite.node.name == node.name {
                    return sprite
                }
            }
        }
        let sprite = RMXSprite.new(inWorld: self, node: node, type: type ?? .PASSIVE, isUnique: false)
        //sprite.setNode(node)
        return sprite
    }
    
    func animate() {
        for child in self.children {
            child.animate()
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
        return self.activeCamera.presentationNode().worldTransform.forward// ?? RMXVector3Make(0,0,-1)
    }
    
    var upVector: RMXVector {
        return self.activeCamera.presentationNode().worldTransform.up// ?? RMXVector3Make(0,1,0)
    }
    
    var leftVector: RMXVector {
        return self.activeCamera.presentationNode().worldTransform.left// ?? RMXVector3Make(-1,0,0)
    }
    
}
