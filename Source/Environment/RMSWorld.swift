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
class RMSWorld : NSObject, RMXUniqueEntity {
    
    var teams: [Int : RMXTeam] = Dictionary<Int,RMXTeam>()
    lazy var rmxID: Int? = RMXSprite.COUNT++
    #if SceneKit
    static let ZERO_GRAVITY = RMXVector3Zero
    static let EARTH_GRAVITY = RMXVector3Make(0, -9.8, 0)
    #elseif SpriteKit
    static let ZERO_GRAVITY = CGVectorZero
    static let EARTH_GRAVITY = CGVector(dx: 0, dy:-9.8)
    #endif
    
    var cameras: Array<SCNNode> = Array<SCNNode>()
    
    var activeCamera: SCNNode {
        return self.cameras[self.cameraNumber]
    }
    
    func getNextCamera() -> SCNNode {
        self.cameraNumber = self.cameraNumber + 1 >= self.cameras.count ? 0 : self.cameraNumber + 1
        let cameraNode = self.cameras[self.cameraNumber]
        return cameraNode
    }
    
    func getPreviousCamera() -> SCNNode {
        self.cameraNumber = self.cameraNumber - 1 < 0 ? self.cameras.count - 1 : self.cameraNumber - 1
        let cameraNode = self.cameras[self.cameraNumber]
        return cameraNode
    }
    
    var cameraNumber: Int = 0

    private var _aiOn = false
    var aiOn: Bool {
        return _aiOn
    }

    var children: Array<RMXSprite> = Array<RMXSprite>()
//    var children: [RMXSprite] {
//        return environments.current
//    }
    
    var hasChildren: Bool {
        return self.children.isEmpty
    }
    
    private func destroy() -> RMSWorld {
        self.children.removeAll()
        self.cameras.removeAll()
        self._gravity = RMSWorld.ZERO_GRAVITY
        _activeSprite = nil
        self.setScene()
        _aiOn = false//TODO check if this is right as default
        return self
    }
    

    
    var interface: RMXInterface
    
    init(interface: RMXInterface){
        self.interface = interface
        super.init()
        self.setScene()
        self.worldDidInitialize()
    }
    
    private var _radius: RMFloatB?
    var radius: RMFloatB {
        return _radius ?? RMSWorld.RADIUS
    }
    
    static var RADIUS: RMFloatB = 250
    


    var scene: RMXScene {
        return self._scene ?? self.setScene()
    }
    
    ///Note: May become public
    private func setScene(scene: RMXScene? = nil) -> RMXScene {
        self._scene = scene ?? RMSWorld.DefaultScene()
        self.cameras += self.activeSprite.cameras// + self.cameras
        self._scene.physicsWorld.contactDelegate = self.interface.collider
        self.calibrate()
        return self._scene
    }
    var ground: RMFloatB = 0
    func calibrate() -> RMXScene {
        _aiOn = false
        self.interface.gameView!.scene = self._scene
        self.cameraNumber = 0
        self.interface.gameView!.pointOfView = self.activeCamera
        
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "switchOnAi", userInfo: nil, repeats: false)
        return _scene
    }
    
    func pause() -> Bool {
        if !self.scene.paused {
            self.scene.paused = true
            self.switchOffAi()
        }
        return true
    }
    
    func unPause() -> Bool {
        if self.scene.paused {
            self.scene.paused = false
            NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "switchOnAi", userInfo: nil, repeats: false)
            
        }
        return true
    }
    
    var isLive: Bool {
        return self.interface.world.rmxID == self.rmxID
    }
    
    
    func switchOnAi() {
        if self.isLive {
            _aiOn = true
        }
    }
    
    func switchOffAi() {
        if self.isLive {
            _aiOn = false
        }
    }
    
    func toggleAi() {
        if self.isLive {
            _aiOn = !_aiOn
        }
    }
    
    private var _scene: RMXScene! = nil
    
    private let GRAVITY: RMFloatB = 0
    
    
    private var _activeSprite: RMXSprite!

    var activeSprite: RMXSprite {
        return _activeSprite ?? _defaultPlayer
    }
    
    private var _defaultPlayer: RMXSprite  {
        _activeSprite = AiCubo.simplePlayer(self, asAi: false, unique: true)
        _activeSprite.setName(name: "Player")
        return _activeSprite
    }
    
    func worldDidInitialize() {
        
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
                    closest = child.rmxID!
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
                    furthest = child.rmxID!
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

    
    func animate() {
        if !self.hasGravity {
            let activeCamera = self.activeCamera
            if activeCamera.isPOV {
                if activeCamera.eulerAngles.x > 0.01 {
                    activeCamera.eulerAngles.x -= 0.01
                } else if activeCamera.eulerAngles.x < -0.01 {
                    activeCamera.eulerAngles.x += 0.01
                }
            }
        }
        
        if !self.scene.paused {
            for child in self.children {
                child.animate()
            }
            self.scene.physicsWorld.updateCollisionPairs()
        }
    }
    
    private var _ground: RMFloatB?
    func validate(sprite: RMXSprite) -> Bool {
        var valid = true
        if let radius = _radius {
            var position = sprite.position
            position.y = 0
            if radius > 0 && position.distanceTo(RMXVector3Zero) > radius {
                return false
            }
        } else if let earth = self._scene.rootNode.childNodeWithName("Earth", recursively: true) as? RMXNode {
            _radius = earth.radius
            _ground = earth.sprite?.top.y
            self.validate(sprite)
        }
        if let ground = _ground {
            valid = sprite.position.y < ground
        }
        return valid
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
