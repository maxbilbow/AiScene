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
#if iOS
    import UIKit
    typealias RMDataView = UITextView
    typealias RMLabel = UIButton
    #elseif OSX
    import AppKit
    typealias RMDataView = NSTextView
    typealias RMLabel = NSButton
#endif

import AVFoundation
    import SceneKit
import SpriteKit

    typealias RendererDelegate = SCNSceneRendererDelegate


class RMXInterface : NSObject, RendererDelegate {

    
    lazy var collider: RMXCollider = RMXCollider(interface: self)
    lazy var av: RMXAudioVideo = RMXAudioVideo(interface: self)

    var activeCamera: SCNNode {
        return self.world.activeCamera
    }
    
    lazy var actionProcessor: RMSActionProcessor = RMSActionProcessor(interface: self)
    private let _isDebugging = false
    var debugData: String = "No Data"
    
    var gvc: GameViewController
    var gameView: GameView? {
        return self.gvc.gameView
    }

   
    var timer: NSTimer? //CADisplayLink?
//    var world: RMSWorld?

    internal static var lookSpeed: RMFloat = 1
    internal static var moveSpeed: RMFloat = 2
    
    var activeSprite: RMXSprite {
        return self.world.activeSprite
    }
    internal var keyboard: KeyboardType = .UK
    
   
    
//    private var _scoreboard: SKView! = nil
    var lines: [SKLabelNode] = [ SKLabelNode(text: "") , SKLabelNode(text: ""), SKLabelNode(text: ""), SKLabelNode(text: "") ]
//    let line1 = SKLabelNode(text: "line1")
//    let line2 = SKLabelNode(text: "line2")
//    let line3 = SKLabelNode(text: "line3")

    
    
    var scoreboard: SKView!

    
//    var activeCamera: RMXCamera? {
//        return self.world?.activeCamera.camera
//    }
//    
        
    init(gvc: GameViewController){
        self.gvc = gvc
        super.init()
        self.setUpViews()
        self.newGame(type: RMXInterface.DEFAULT_GAME)
        self.viewDidLoad()
        RMXLog()
    }

    
    func startVideo(sender: AnyObject?){}
    
    ///Run this last when overriding
    func viewDidLoad(){
        self.gameView!.delegate = self
       // NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateScoreboard", userInfo: nil, repeats: true)
    }
    
    func setUpTimers(){
//        self.timer = NSTimer(target: self, selector: Selector("update"))
//        self.timer!.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    private var _scoreboardRect: CGRect {
        var bounds = self.gameView!.bounds
        bounds.size.height = bounds.size.height * 0.3
        bounds.origin = CGPoint(x: bounds.size.width / 3, y: bounds.size.height / 3)
        return bounds
    }
    
    func setUpViews() {
        let bounds = _scoreboardRect
        var skScene: SKScene = SKScene(size: bounds.size)
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

    func log(_ message: String = "", sender: String = __FUNCTION__, line: Int = __LINE__) {
        if _isDebugging {
            self.debugData += "  \(sender) on line \(line): \(message)"
        }
    }
    
    func debug() {
        if debugData != ""{
            RMLog("\(debugData)")
//            self.log("\n x\(leftPanData.x.toData()), y\(leftPanData.y)",sender: "LEFT")
//            self.log("x\(rightPanData.x.toData()), y\(rightPanData.y.toData())",sender: "RIGHT")
        }
        debugData = ""
    }
    
    private static let DEFAULT_GAME: GameType = .TEAM_GAME
    
    var availableGames: [ GameType ] = [ .TEAM_GAME, .WEAPONS, .TEST, .EMPTY ]
    
    var activeGames: [GameType: RMSWorld] = Dictionary<GameType,RMSWorld>()
    
    private var _world: RMSWorld?
    
    func destroyWorld() -> RMSWorld? {
        return nil //_world?.destroy()
    }
    var world: RMSWorld {
        return _world ?? _newGame()
    }
    private var isNewGame = true
    ///Swictches between gamemode without deleting or duplicating environments.
    func newGame(type: GameType? = nil) {
        self.pauseGame()
        _world = _newGame(type: type)
        self.isNewGame = true
        _world?.calibrate()
        self.updateScoreboard()
//        self.organiseLines()
//        self.unPauseGame(nil)
        self.pauseGame()
    }
    
    private func _newGame(type: GameType? = nil) -> RMSWorld! {

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
                if _world != nil && _world! == newWorld && self.availableGames.count > 1 {
                    RMLog("Game matched the current world - try again: \(n) of \(self.availableGames.count) - \(_world?.rmxID) - \(newWorld.rmxID) (fail)")
                    return self._newGame(type: nil)
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
        self.update()
        self.world.renderer(aRenderer, updateAtTime: time)
        RMXLog.printAndFlush()
    }
    
    func updateDataView(){
//        let text = self.actionProcessor.getData()
//        NSLog(text)
    }
    
    func animateHit(node: SCNNode){
        if let material = node.geometryNode?.geometry?.firstMaterial {
            
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
    
    func processHit(point p: CGPoint, type: UserAction) -> Bool {
        if let hitResults = self.gameView?.hitTest(p, options: nil) {
            // check that we clicked on at least one object
            if hitResults.count > 0 {
                // retrieved the first clicked object
                if let node: SCNNode = hitResults[0].node {
//                NSLog(result.)
                
                    var animate: Bool = false
                    if type == .THROW_ITEM {
                        if self.actionProcessor.throwOrGrab(node.sprite, tracking: true) {
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
    func updateScoreboard() {
        if self.scoreboard.hidden {
            return
        }
        if let world = _world {
            var min = 0
            var lns: [String] = [ self.world.name ?? "Unknown Gamemode", self.activeSprite.attributes.printScore ]
            if self.world.teams.count > 0 {
                for team in self.world.teams {
                    lns.append(team.1.print)
                }
            }
            lns.append("Try selecting a defferent game mode")
            lns.append("Numbers 0..9 in OSX or fromt' pause menu in iOS")
            
            
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
        var lnHeight = self.scoreboard.bounds.size.height / CGFloat(self.lineCount + 2)
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
        if _world != nil && !_world!.paused {//.scene.paused {
            self.actionProcessor.animate()
        }

    }
    
    enum KeyboardType { case French, UK }
    func setKeyboard(type: KeyboardType = .UK)  {
        self.keyboard = type
    }
    ///Stop all inputs (i.e. no gestures received)
    ///@virtual
    func handleRelease(arg: AnyObject, args: AnyObject ...) { }

    func action(action: RMInputKeyValue ,speed: RMFloat = 1, args: Any? = nil) -> Bool {
        return self.actionProcessor.action( action,speed: speed, args: args)
    }
    
    
    func hideButtons(hide: Bool) {
        
    }
    
    var isPaused: Bool {
        return _world != nil && _world!.paused//.scene.paused
    }
    
    var isRunning: Bool {
        return _world != nil && !_world!.paused//scene.paused
    }
    
    func pauseGame(_ sender: AnyObject? = nil) -> Bool {
//        if sender is RMXObject { RMLog("Pause requested by \(sender?.uniqueID)") }
        if _world?.pause() != nil {
//            self.updateScoreboard()
            self.updateDataView()
            if self.lines.count > 0 {
                self.scoreboard.hidden = false// self.action(action: RMXInterface.SHOW_SCORES, speed: 1)
                self.updateScoreboard()
            }
            self.hideButtons(true)
            return true
        }
        return true
    }
    
    func unPauseGame(_ sender: AnyObject? = nil) -> Bool {
//        if sender is RMXObject { RMLog("UnPause requested by \(sender?.uniqueID)") }
        if _world?.unPause() != nil {
            self.scoreboard.hidden = true //self.action(action: RMXInterface.HIDE_SCORES, speed: 1)
            self.hideButtons(false)
            return true
        }
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
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        switch keyPath {
        case RMSWorld.kvScores:
            self.updateScoreboard()
            break
        default:
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            break
        }
    }
}