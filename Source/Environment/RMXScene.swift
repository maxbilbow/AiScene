//
//  RMXScene.swift
//  RattleGL
//
//  Created by Max Bilbow on 10/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GLKit
import SceneKit
import RMXKit

//typealias AiCubo
//enum GameType: Int { case NULL = -1, TESTING_ENVIRONMENT, SMALL_TEST, FETCH, DEFAULT }
@available(OSX 10.9, *)
class RMXScene : SCNScene, RMXWorld, RMXObject {

    var collisionTrackers: Array<RMXTracker> = Array<RMXTracker>()
    
    static var current: RMXScene {
        return Interface.current.world
    }
    
    static let kvScores = "teamScores"
    
    let rmxID: Int? = RMX.COUNT++
    lazy var uniqueID: String? = "\(self.name)/\(self.rmxID)";
    var name: String? = classForCoder().description() ;
    
    lazy var print: String = self.uniqueID!
    
    internal var _teams: Dictionary<String ,RMXTeam> = Dictionary<String ,RMXTeam>()
    
    
    static let ZERO_GRAVITY = SCNVector3Zero
    static let EARTH_GRAVITY = SCNVector3Make(0, -9.8, 0)
    
    var gameOverMessage: ((AnyObject?) -> [String]?)?
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

    @objc var pawns: Array<AnyObject> {
        return self.sprites
    }
    
    private var _earth: SCNNode?
    var earth: SCNNode? {
        if self._earth != nil {
            return self._earth
        } else {
            self._earth = self.rootNode.childNodeWithName("Earth", recursively: true)
            return self._earth
        }
    }
    
    @available(*,deprecated=1,message="Use sprites")
    var children: Array<RMXNode> {
        return self.sprites
    }
    
    var sprites: Array<RMXNode> = Array<RMXNode>()
//    var children: [RMXNode] {
//        return environments.current
//    }
    
    var hasChildren: Bool {
        return self.sprites.isEmpty
    }
    
    private func destroy() -> RMXScene {
        self.sprites.removeAll()
        self.cameras.removeAll()
        self._gravity = RMXScene.ZERO_GRAVITY
        _activeSprite = nil
        self.setScene()
        
        _aiOn = false//TODO check if this is right as default
        return self
    }
    

    func setRadius(radius: RMFloat?) {
        self._radius = radius
    }
    
    override init(){
        super.init()
        self.setScene()
        self.worldDidInitialize()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var _radius: RMFloat?
    var radius: RMFloat {
        return _radius ?? RMXScene.RADIUS
    }
    
    private static var RADIUS: RMFloat = 1250
    
    
    ///Note: May become public
    private func setScene(scene: SCNScene? = nil) -> SCNScene {
//        self._scene = scene ?? RMXScene.DefaultScene()
        self.cameras += self.activeSprite.cameras// + self.cameras
        self.physicsWorld.contactDelegate = self
        self.calibrate()
        return self
    }
    var ground: RMFloat = 0
    
    func reset(withArgs args: AnyObject? = nil) {
        for sprite in self.sprites {
            sprite.reinitialize()
        }
        if self.teams.count > 1 {
            self.resetTeams(withArgs: args)
        }
        self.calibrate()
        self.unPause()
    }
    
    func resetTeams(withArgs args: AnyObject? = nil) {
        let teams = self.teams ; let teamPlayers = self.teamPlayers
        let noTeams = teams.count; let noPlayers = teamPlayers.count
        let playersPerTeam = noPlayers / noTeams; var count = 0
        for player in teamPlayers {
            for team in teams {
                if !player.attributes.isTeamCaptain {
                    team.1.addPlayer(player)
                    if ++count >= playersPerTeam {
                        break
                    }
                }
            }
        }
//        AiCubo.addPlayers(self, noOfPlayers: self.players.count, teams: self.teams.count)
    }
    
    func calibrate() -> SCNScene {
        _aiOn = false
        GameViewController.current.gameView!.scene = self//._scene
        self.cameraNumber = 0
        GameViewController.current.gameView!.pointOfView = self.activeCamera
//        self.shouldTurnOnAi = true
        return self
    }
    var shouldTurnOnAi = true
    func pause() -> Bool {
        if !self.shouldTurnOnAi {
            self.shouldTurnOnAi = self._aiOn
        }
        self._aiOn = false
        self.paused = true
        return true
    }
    var aiTimer: NSTimer?
    func unPause() -> Bool {
        self.paused = false
        if self.shouldTurnOnAi {
            if !(self.aiTimer?.valid ?? true) {
//                    self.aiTimer?.fire()
                self.switchOnAi()
            } else {
                self.aiTimer = NSTimer.scheduledTimerWithTimeInterval(4, target: self, selector: "switchOnAi", userInfo: nil, repeats: false)
            }
            self.shouldTurnOnAi = false
        }
        return true
    }
    
    var isLive: Bool {
        return Interface.current.world.rmxID == self.rmxID && self.paused == false
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

    
    private let GRAVITY: RMFloat = 0
    
    
    private var _activeSprite: RMXNode!

    var activeSprite: RMXNode {
        return _activeSprite ?? _defaultPlayer
    }
    
    private var _defaultPlayer: RMXNode  {
        _activeSprite = AiCubo.simplePlayer(self, asAi: false, unique: true, safeInit: true)
        _activeSprite.addCameras()
        _activeSprite.updateName("Player")
        return _activeSprite
    }
    
    func worldDidInitialize() {
        //Set the render delegate
    }
  
    
    func insertChild(child: RMXNode, andNode:Bool = true){
        self.sprites.append(child)
        if andNode {
            self.rootNode.addChildNode(child)
        }
    }
    
    func insertChildren(children: [RMXNode], insertNodes:Bool = true){
        for child in children {
            self.insertChild(child, andNode: insertNodes)
        }
    }

    func insertChildren(children children: [String:RMXNode], insertNodes:Bool = true){
        for child in children {
            self.insertChild(child.1, andNode: insertNodes)
        }
    }
  
    var hasGravity: Bool {
        return (self).physicsWorld.gravity != RMXScene.ZERO_GRAVITY
    }
    
    private var _gravity = ZERO_GRAVITY
    
    var gravity: SCNVector3 {
        return (self).physicsWorld.gravity
    }
    
    
    func gravityOff() {
        if self.hasGravity {
            self.toggleGravity()
        }
    }
    
    func gravityOn() {
        if !self.hasGravity {
            self.toggleGravity()
        }
    }
    
    func toggleGravity() {
            if self.hasGravity {
                let gravity = (self).physicsWorld.gravity
                _gravity = gravity == RMXScene.ZERO_GRAVITY ? RMXScene.EARTH_GRAVITY : gravity
                (self).physicsWorld.gravity = RMXScene.ZERO_GRAVITY
                (self.activeCamera as? RMXCameraNode)?.orientationNeedsReset()
                RMLog("Gravity off: \((self).physicsWorld.gravity.print)")
            } else {
                if _gravity == RMXScene.ZERO_GRAVITY {
                     _gravity = RMXScene.EARTH_GRAVITY
                }
                (self).physicsWorld.gravity = _gravity
                RMLog("Gravity on: \((self).physicsWorld.gravity.print)")
            }
    }
    
    func renderer(aRenderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        for child in self.sprites {
            child.aiDelegate?.run(aRenderer, updateAtTime: time)
        }

    }
    
    private var _ground: RMFloat?

    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [NSObject : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if object is SpriteAttributes {
            switch keyPath! {
            case "points":
                self.willChangeValueForKey(RMXScene.kvScores)
                self.didChangeValueForKey(RMXScene.kvScores)
                break
            default:
                super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
                break
            }
        }
    }
}

@available(OSX 10.10, *)
extension RMXScene {

    var forwardVector: SCNVector3{
        return self.activeCamera.presentationNode().worldTransform.forward// ?? SCNVector3Make(0,0,-1)
    }
    
    var upVector: SCNVector3 {
        return self.activeCamera.presentationNode().worldTransform.up// ?? SCNVector3Make(0,1,0)
    }
    
    var leftVector: SCNVector3 {
        return self.activeCamera.presentationNode().worldTransform.left// ?? SCNVector3Make(-1,0,0)
    }
    
}
