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

    static let MOVE_FORWARD: String = "forward"
    static let MOVE_BACKWARD: String = "back"
    static let MOVE_LEFT: String = "left"
    static let MOVE_RIGHT: String = "right"
    static let MOVE_UP: String = "up"
    static let MOVE_DOWN: String = "down"
    static let ROLL_LEFT: String = "rollLeft"
    static let ROLL_RIGHT: String = "rollRight"
    static let JUMP: String = "jump"
    static let ROTATE: String = "look"
    
    //Interactions
    static let GRAB_ITEM: String = "grab"
    static let THROW_ITEM: String = "throwItem"
    static let BOOM: String = "explode"
    
    //Environmentals
    static let TOGGLE_GRAVITY: String = "toggleAllGravity"
    //static let XXX: String = "toggleGravity", characters: "G", isRepeating: false,speed: ON_KEY_UP),
    static let TOGGLE_AI: String = "toggleAI"
    static let RESET: String = "reset"
    static let RESET_CAMERA: String = "resetCamera"
    
    //Interface options
    static let LOCK_CURSOR: String = "lockMouse"
    static let NEXT_CAMERA: String = "nextCamera"
    static let PREV_CAMERA: String = "previousCamera"
    static let PAUSE_GAME: String = "pauseGame"
    static let KEYBOARD_LAYOUT: String = "switchKeyboard"
    static let SHOW_SCORES: String = "ShowScoreboard"
    static let HIDE_SCORES: String = "HideScoreboard"
    static let TOGGLE_SCORES: String = "toggleScores"
    
    //Misc: generically used for testing
    static let GET_INFO: String = "information"
    static let ZOOM_IN: String = "zoomIn"
    static let ZOOM_OUT: String = "zoomOut"
    static let INCREASE: String = "increase"
    static let DECREASE: String = "decrease"
    static let NEW_GAME: String = "newGame"
    //Non-ASCKI commands
    static let MOVE_CURSOR_PASSIVE: String = "mouseMoved"
    static let LEFT_CLICK: String = "Mouse 1"
    static let RIGHT_CLICK: String = "Mouse 2"
    static let KEY_LEFT: String = "123"
    static let KEY_RIGHT: String = "124"
    static let KEY_DOWN: String = "125"
    static let KEY_UP: String = "126"
    static let KEY_BACKSPACE: String = "\u{7F}"
    static let KEY_ESCAPE: String = "\u{1B}"
    
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

    static var lookSpeed: RMFloatB = 1
    static var moveSpeed: RMFloatB = 2
    
    var activeSprite: RMXSprite {
        return self.world.activeSprite
    }
    internal var keyboard: KeyboardType = .UK
    
    private var _dataView: SKLabelNode! = nil
    var dataView: SKLabelNode {
        if _dataView != nil {
            return _dataView
        } else {
            _dataView = SKLabelNode(text: "Hello, World!")
            _dataView.position.x = self.skView.scene!.size.width / 10
            _dataView.position.y = self.skView.scene!.size.height * 9 / 10
            _dataView.alpha = 0.5
            _dataView.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
            _dataView.verticalAlignmentMode = .Top
            _dataView.fontSize /= 2
            _dataView.fontColor = RMColor.whiteColor()
            _dataView.hidden = true
            return _dataView
        }

    }
    
    private var _scoreboard: SKView! = nil
    let line1 = SKLabelNode(text: "line1")
    let line2 = SKLabelNode(text: "line2")
    let line3 = SKLabelNode(text: "line3")

    lazy var skScene: SKScene = SKScene(size: self.gameView!.bounds.size)
    
    var scoreboard: SKView {
        if _scoreboard != nil {
            return _scoreboard
        } else {
            _scoreboard = SKView(frame: self.gameView!.bounds)

            _scoreboard.hidden = true

            self.line1.verticalAlignmentMode = .Top
            self.line1.fontSize /= 2
            self.line1.fontColor = RMColor.whiteColor()
            self.line1.position.x = self.skView.scene!.size.width / 2
            self.line1.position.y = self.skView.scene!.size.height / 2 - 10
            
            self.line2.verticalAlignmentMode = .Center
            self.line2.fontSize /= 2
            self.line2.fontColor = RMColor.whiteColor()
            self.line2.position.x = self.skView.scene!.size.width / 2
            self.line2.position.y = self.skView.scene!.size.height / 2
            
            self.line3.verticalAlignmentMode = .Bottom
            self.line3.fontSize /= 2
            self.line3.fontColor = RMColor.whiteColor()
            self.line3.position.x = self.skView.scene!.size.width / 2
            self.line3.position.y = self.skView.scene!.size.height / 2 + 10
            
            _scoreboard.presentScene(self.skScene)
            _scoreboard.scene!.addChild(self.line1)
            _scoreboard.scene!.addChild(self.line2)
            _scoreboard.scene!.addChild(self.line3)
            return _scoreboard
        }
    }

    
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
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateScoreboard", userInfo: nil, repeats: true)
    }
    
    func setUpTimers(){
//        self.timer = NSTimer(target: self, selector: Selector("update"))
//        self.timer!.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    lazy var skView: SKView = SKView(frame: self.gameView!.bounds)
    
    func setUpViews() {
        self.gameView!.addSubview(self.skView)
        self.skView.presentScene(self.skScene)

        self.skView.allowsTransparency = true
        
        self.skView.addSubview(self.scoreboard)
        self.skView.scene?.addChild(self.dataView)
        self.skView.hidden = true
        
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
    
    var availableGames: [ GameType ] = [ .TEAM_GAME, .TEST, .EMPTY ]
    
    var activeGames: [GameType: RMSWorld] = Dictionary<GameType,RMSWorld>()
    
    private var _world: RMSWorld?
    
    func destroyWorld() -> RMSWorld? {
        return nil //_world?.destroy()
    }
    var world: RMSWorld {
        return _world ?? _newGame()
    }
    
    ///Swictches between gamemode without deleting or duplicating environments.
    func newGame(type: GameType? = nil) {
        self.pauseGame(nil)
        _world = _newGame(type: type)
        _world?.calibrate()
        self.unPauseGame(nil)
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
        RMXLog.printAndFlush()
    }
    
    func updateDataView(){
//        let text = self.actionProcessor.getData()
//        NSLog(text)
    }
    
    func processHit(point p: CGPoint) {
        if let hitResults = self.gameView?.hitTest(p, options: nil) {
            // check that we clicked on at least one object
            if hitResults.count > 0 {
                // retrieved the first clicked object
                let result: AnyObject! = hitResults[0]
//                NSLog(result.)
                
                if self.actionProcessor.throwOrGrab(result) {//.manipulate(action: "throw", sprite: self.activeSprite, object: result, speed: 18000) {
                
                    // get its material
                    if let material = result.node.geometryNode?.geometry?.firstMaterial {
                        
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
            }
        }

    }
    
//    var scene: RMXScene? {
//        return self.gameView?.scene
//    }
    
    func updateScoreboard() {
//        NSLog(self.actionProcessor.getData(type: .SCORES))
        if self.scoreboard.hidden || self.skView.hidden {
            return
        }
        if let world = _world {
            if let team1 = self.world.teams[1] {
                if let team2 = self.world.teams[2] {
                    self.line3.text = self.activeSprite.attributes.printScore
                    self.line2.text = team1.printScore
                    self.line1.text = team2.printScore
                    return
                }
            }
        } else {
            self.line3.text = "Hello!"
            self.line2.text = "Unfortunately this isn't \"Team Mode\""
            self.line1.text = "Try pausing and restarting (top left)"
        }

    }
    
    func update(){
        if _world != nil && !_world!.paused {//.scene.paused {
            self.actionProcessor.animate()
            _world?.animate()
            if !self.dataView.hidden {
                self.updateDataView()
            }
        }

    }
    
    enum KeyboardType { case French, UK }
    func setKeyboard(type: KeyboardType = .UK)  {
        self.keyboard = type
    }
    ///Stop all inputs (i.e. no gestures received)
    ///@virtual
    func handleRelease(arg: AnyObject, args: AnyObject ...) { }

    func action(action: String = "reset",speed: RMFloatB = 1, point: [RMFloatB] = []) -> Bool {
        return self.actionProcessor.action( action,speed: speed, point: point)
    }
    
    
    func hideButtons(hide: Bool) {
        
    }
    
    var isPaused: Bool {
        return _world != nil && _world!.paused//.scene.paused
    }
    
    var isRunning: Bool {
        return _world != nil && !_world!.paused//scene.paused
    }
    
    func pauseGame(sender: AnyObject?) -> Bool {
        if _world?.pause() != nil {
            self.updateScoreboard()
            self.updateDataView()
            self.action(action: RMXInterface.SHOW_SCORES, speed: 1)
            self.hideButtons(true)
            return true
        }
        return true
    }
    
    func unPauseGame(sender: AnyObject?) -> Bool {
        if _world?.unPause() != nil {
            self.action(action: RMXInterface.HIDE_SCORES, speed: 1)
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
}