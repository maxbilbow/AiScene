//
//  RMXInterface.swift
//  RattleGLES
//
//  Created by Max Bilbow on 25/03/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
import QuartzCore
    import GLKit
import RMXKit

import AVFoundation
    import SceneKit
import SpriteKit

    

@available(OSX 10.10, *)
class RMXInterface : NSObject, RendererDelegate, RMXInterfaceProtocol {

    var lockCursor = false
    
    lazy var collider: RMXCollider = RMXCollider(interface: self)
    lazy var av: RMXAudioVideo = RMXAudioVideo(interface: self)
    
    
    
    lazy var actionProcessor: RMSActionProcessor = RMSActionProcessor(interface: self)
    private let _isDebugging = false
    var debugData: String = "No Data"
    
//    var gvc: GameViewController!
    
    
    var timer: NSTimer? //CADisplayLink?
    //    var world: RMXScene?
    
    //    internal static let lookSpeed: RMFloat = 1
    internal static let moveSpeed: RMFloat = 2
    
    
    
    var keyboard: KeyboardType = .UK
    //    private var _scoreboard: SKView! = nil
    var lines: [SKLabelNode] = [ SKLabelNode(text: "") , SKLabelNode(text: ""), SKLabelNode(text: ""), SKLabelNode(text: "") ]
    //    let line1 = SKLabelNode(text: "line1")
    //    let line2 = SKLabelNode(text: "line2")
    //    let line3 = SKLabelNode(text: "line3")
    
    
    
    var scoreboard: SKView!
    
    var availableGames: [ GameType ] = [ .TEAM_GAME, .TEAM_GAME_2, .WEAPONS, .TEST, .EMPTY ]
    
    var activeGames: [GameType: RMXScene] = Dictionary<GameType,RMXScene>()
    
    var gameView: GameView? {
        return GameViewController.current.gameView
    }
    
    var activeCamera: SCNNode {
        return self.world.activeCamera
    }
    
    var activeSprite: RMXSprite {
        return self.world.activeSprite
    }

    
//    var activeCamera: RMXCamera? {
//        return self.world?.activeCamera.camera
//    }
//    
    override class func new() -> Self {
        fatalError("call New() instead")
    }
    
    
    
    override init() {
        super.init()
        if (RMXInterface._current != nil) {
            fatalError(RMXException.Singleton.rawValue)
        } else {
            RMXInterface._current = self
            self.setUpViews()
            self.newGame(RMXInterface.DEFAULT_GAME)
            self.viewDidLoad()
        }
    }
    
    class func destroy() {
        if self === RMXInterface._current {
            RMXInterface._current = nil
        }
    }
    
    deinit {
        RMXInterface.destroy()
    }
    
    private static var _current: RMXInterface?
    
    static var current: RMXDPadOrKeys? {
        return RMXInterface._current as? RMXDPadOrKeys ?? RMXDPadOrKeys()
    }

    //    var world2D: SKView?
    func startVideo(sender: AnyObject?){}
    
    ///Run this last when overriding
    func viewDidLoad(){
        self.gameView!.delegate = self
        
    }
    
    private var _scoreboardRect: CGRect {
        var bounds = self.gameView!.bounds
        bounds.size.height = bounds.size.height * 0.3
        bounds.origin = CGPoint(x: bounds.size.width / 3, y: bounds.size.height / 3)
        return bounds
    }
    
    func setUpViews() {
        let bounds = _scoreboardRect
        let skScene: SKScene = SKScene(size: bounds.size)
        //            bounds.height =
        self.scoreboard = SKView(frame: bounds)
        self.scoreboard.presentScene(skScene)
        self.scoreboard.hidden = true
        for line in self.lines {
            self.scoreboard.scene?.addChild(line)
        }
        self.scoreboard.allowsTransparency = true
        self.gameView!.addSubview(self.scoreboard)
        self.scoreboard.hidden = true
        
        
    }
    
    private static let DEFAULT_GAME: GameType = .TEAM_GAME_2
    
    
    
    private var _world: RMXScene?
    
    func destroyWorld() -> RMXScene? {
        return nil //_world?.destroy()
    }
    var world: RMXScene {
        return _world ?? _newGame()
    }
    private var isNewGame = true
    ///Swictches between gamemode without deleting or duplicating environments.
    func newGame(type: GameType? = nil) {
        self.pauseGame()
        _world = _newGame(type)
        self.isNewGame = true
        _world?.calibrate()
        
//        self.organiseLines()
//        self.unPauseGame(nil)
        self.pauseGame()
    }
    
    private func _newGame(type: GameType? = nil) -> RMXScene! {

        RMLog("World: \(_world?.rmxID)")
        if let type = type {
            if let world = self.activeGames[type] {
                _world = world
                RMLog("This game exists. We're done: \(type.hashValue) - \(_world?.rmxID) (done)")
                return _world
            } else {
                _world = AiCubo.setUpWorld(self, type: type)
                self.activeGames[type] = _world
                RMLog("Creating a new game of type: \(type.hashValue) - : \(_world!.rmxID) (done)")
                return _world
            }
            
            
        } else {
            let n = random() % self.availableGames.count
            let type = self.availableGames[n]
            if let newWorld = self.activeGames[type] {
                if _world != nil && _world! === newWorld && self.availableGames.count > 1 {
                    RMLog("Game matched the current world - try again: \(n) of \(self.availableGames.count) - \(_world?.rmxID) - \(newWorld.rmxID) (fail)")
                    return self._newGame(nil)
                } else {
                    RMLog("SUCCESS - Game exits: \(n) of \(self.availableGames.count) - \(_world?.rmxID) - \(newWorld.rmxID) (done)")
                    _world = newWorld
                    return newWorld
                }
            } else {
                RMLog("SUCCESS - A new instance of this game: \(n) of \(self.availableGames.count) - \(_world?.rmxID) (done)")
                _world = AiCubo.setUpWorld(self, type: type)
                self.activeGames[type] = _world
                return _world
            }
        }
        
    }
    
    func renderer(aRenderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        if !(_world?.paused ?? true) {//.scene.paused {
            self.actionProcessor.animate()
            self.world.renderer(aRenderer, updateAtTime: time)
        }
        self.update()
        RMXLog.printAndFlush()
    }
    

    func animateHit(node: SCNNode){
        if let material = node.geometry?.firstMaterial {
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.setAnimationDuration(0.5)
            
            // on completion - unhighlight
            SCNTransaction.setCompletionBlock {
                SCNTransaction.begin()
                SCNTransaction.setAnimationDuration(0.5)
                
                material.emission.contents = RMColor.blackColor()
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = RMColor.redColor()
            
            SCNTransaction.commit()
        }
    }
    
    func resetButton() {
        self.world.reset()
    }
    
    func processHit(point p: CGPoint, type: UserAction) -> Bool {
        if let hitResults = self.gameView?.hitTest(p, options: nil) {
            // check that we clicked on at least one object
            if hitResults.count > 0 {
                // retrieved the first clicked object
                if let node: SCNNode = hitResults[0].node {
//                NSLog(result.)
                
//                    var animate: Bool = false
                    if type == .THROW_ITEM {
                        if self.actionProcessor.throwOrGrab(node, tracking: true) {
                            self.animateHit(node)
                        } else {
                            self.actionProcessor.throwOrGrab(hitResults[0].worldCoordinates, tracking: false) //activeSprite.throwItem(atPosition: hitResults[0].worldCoordinates, withForce: 1)
                        }
                    } else if self.actionProcessor.throwOrGrab(node, tracking: false) {
                        self.animateHit(node)
                    }
                }
            }
        }
        return false

    }
    
//    var scene: RMXScene? {
//        return self.gameView?.scene
//    }
    
    private var lineCount = 0
    func updateScoreboard(lines: [String]?) {
        if !self.scoreboard.hidden && _world != nil{
            var lns: [String] = lines ?? [ self.world.name ?? "Unknown Gamemode", self.activeSprite.attributes.printScore ]
            if self.world.teams.count > 0 {
                for team in self.world.teams {
                    lns.append(team.1.print)
                }
            }
            if lns.count <= 2 {
                lns.append("Try selecting a defferent game mode")
                lns.append("Numbers 0..9 in OSX or fromt' pause menu in iOS")
            }
            
            
            if self.lineCount != lns.count {
                self.lineCount = lns.count
                for line in self.lines {
                    line.text = ""
                }
                let diff = lns.count - self.lines.count
                if diff > 0 {
                    for var i = 0; i < diff ; ++i {
                        self.lines.append(SKLabelNode(text: ""))
                        self.scoreboard.scene?.addChild(self.lines.last!)
                    }
                }
               
                self.updateSKLabels(self.lines, withText: lns)
                self.organiseLines()
                self.isNewGame = false
            } else {
                self.updateSKLabels(self.lines, withText: lns)
            }
            
//            self.scoreboard.setNeedsDisplay()
        }

    }
    
    func updateSKLabels(labels: [SKLabelNode], withText lns: [String]) {
        var count = 0
        for text in lns {
            labels[count++].text = text
        }
    }
    
    func organiseLines() {
        let lnHeight = self.scoreboard.bounds.size.height / CGFloat(self.lineCount + 2)
        var yPos: CGFloat = self.scoreboard.bounds.size.height - lnHeight * 1.7
        for label in self.lines {
            if label.text == "" {
                label.hidden = true
            } else {
                label.hidden = false
                label.fontSize = lnHeight * 0.9
                label.horizontalAlignmentMode = .Left
                label.fontColor = RMColor.whiteColor()
                label.position.x = 10 // self.scoreboard.bounds.size.width / 2 //self.skView.scene!.size.width / 2
                label.position.y = yPos
                yPos -= lnHeight
            }
        }
            
        
        
    }
    
    
    func update(){
        if _willUpdateScoreboard {
            if let msg = self.world.gameOverMessage?(world) {
                self.pauseGame()
                self.updateScoreboard(msg)
            } else if !self.scoreboard.hidden {
                self.updateScoreboard(nil)
            }
            _willUpdateScoreboard = false
        }
    }
    
    
    func setKeyboard(type: KeyboardType = .UK)  {
        self.keyboard = type
    }
    
    ///Stop all inputs (i.e. no gestures received)
    ///@virtual
    func handleRelease(arg: AnyObject, args: AnyObject ...) { }

    
    ///@virtual
    func hideButtons(hide: Bool) {}
    
    var isPaused: Bool {
        return _world != nil && _world!.paused//.scene.paused
    }
    
    var isRunning: Bool {
        return _world != nil && !_world!.paused//scene.paused
    }
    
    ///When overriding, call super last
    func pauseGame(sender: AnyObject? = nil) -> Bool {
//        if sender is RMXObject { RMLog("Pause requested by \(sender?.uniqueID)") }
        
        // self.action(action: RMXInterface.SHOW_SCORES, speed: 1)
        self.hideButtons(true)
        self.scoreboard.hidden = false
        self.updateScoreboard(nil)
        _world?.pause()
        return true
    }
    
    ///When overriding, call super last
    func unPauseGame(sender: AnyObject? = nil) -> Bool {
        self.scoreboard.hidden = true //self.action(action: RMXInterface.HIDE_SCORES, speed: 1)
        self.hideButtons(false)
        _world?.unPause()
        return true
    }
    
    func optionsMenu(sender: AnyObject?) {
        RMLog("Show Options")
        
    }
    
    func exitToMainMenu(sender: AnyObject?) {
        RMLog("End Simulation")

    }
    

    func restartSession(sender: AnyObject?) {
        self.newGame()
    }
    
    func getRect(withinRect bounds: CGRect? = nil, row: (CGFloat, CGFloat), col: (CGFloat, CGFloat)) -> CGRect {
        let bounds = bounds ?? self.gameView!.bounds
        return CGRectMake(bounds.width * (col.0 - 1) / col.1, bounds.height * (row.0 - 1) / row.1, bounds.width / col.1, bounds.height / row.1)
    }
    
    private var _willUpdateScoreboard = false
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [NSObject : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        switch keyPath! {
        case RMXScene.kvScores:
            _willUpdateScoreboard = true
            break
        default:
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            break
        }
    }
}