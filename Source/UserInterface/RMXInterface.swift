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
    #elseif OSX
    import AppKit
    typealias RMDataView = NSTextView
#endif

import AVFoundation
    import SceneKit

    typealias RendererDelegate = SCNSceneRendererDelegate


class RMXInterface : NSObject, RendererDelegate, RMXControllerProtocol {
    
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
    
    //Interface options
    static let LOCK_CURSOR: String = "lockMouse"
    static let NEXT_CAMERA: String = "nextCamera"
    static let PREV_CAMERA: String = "previousCamera"
    static let PAUSE_GAME: String = "pauseGame"
    static let KEYBOARD_LAYOUT: String = "switchKeyboard"
    
    //Misc: generically used for testing
    static let GET_INFO: String = "information"
    static let ZOOM_IN: String = "zoomIn"
    static let ZOOM_OUT: String = "zoomOut"
    
    //Non-ASCKI commands
    static let MOVE_CURSOR_PASSIVE: String = "mouseMoved"
    static let LEFT_CLICK: String = "Mouse 1"
    static let RIGHT_CLICK: String = "Mouse 2"
    
    lazy var av: RMXCollider = RMXCollider(interface: self)

    var activeCamera: RMXNode? {
        return self.world?.activeCamera
    }
    
    lazy var actionProcessor: RMSActionProcessor = RMSActionProcessor(world: self.world!, gameView: self.gameView)
    private let _isDebugging = false
    var debugData: String = "No Data"
    
    var gvc: GameViewController?
    var gameView: GameView!

   
    var timer: NSTimer? //CADisplayLink?
    var world: RMSWorld?

    static var lookSpeed: RMFloatB = 1
    static var moveSpeed: RMFloatB = 2
    
    var activeSprite: RMXSprite? {
        return self.world?.activeSprite
    }
    internal var keyboard: KeyboardType = .UK
    
    var dataView: RMDataView?
    
//    var activeCamera: RMXCamera? {
//        return self.world?.activeCamera.camera
//    }
//    
        
    init(gvc: GameViewController, scene: RMXScene? = nil){
        super.init()
        self.initialize(gvc)
        self.viewDidLoad(nil)
        RMXLog("\(__FUNCTION__)")
    }
    
    func initialize(gvc: GameViewController, scene: RMXScene? = nil) -> RMXInterface {
        self.gvc = gvc
        self.gameView = gvc.gameView
        
        if self.world == nil {
            self.world = RMSWorld(interface: self)
        }
//        self.world!.clock = RMXClock(world: self.world!, interface: self)

        self.gameView!.delegate = self

        return self
    }
    
    
    func startVideo(sender: AnyObject?){
    
    }
    
    func viewDidLoad(coder: NSCoder!){
        if self.world == nil {
            self.world = RMSWorld(interface: self, scene: RMXScene(coder: coder))
        }
        self.dataView = RMDataView(frame: self.gameView.bounds)
        self.dataView!.hidden = true
//        self.dataView!.backgroundColor = NSColor.blueColor()
//        self.dataView!.enabled = true
        self.gameView.addSubview(self.dataView!)
//        self.dataView!.alpha = 0.5
        self.setUpGestureRecognisers()
    }
    func setUpTimers(){
//        self.timer = NSTimer(target: self, selector: Selector("update"))
//        self.timer!.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    func setUpGestureRecognisers() {
        
    }

    func log(_ message: String = "", sender: String = __FUNCTION__, line: Int = __LINE__) {
        if _isDebugging {
            self.debugData += "  \(sender) on line \(line): \(message)"
        }
    }
    
    func debug() {
        if debugData != ""{
            RMXLog("\(debugData)")
//            self.log("\n x\(leftPanData.x.toData()), y\(leftPanData.y)",sender: "LEFT")
//            self.log("x\(rightPanData.x.toData()), y\(rightPanData.y.toData())",sender: "RIGHT")
        }
        debugData = ""
    }
    
    

    func renderer(aRenderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        self.update()
    }
    
    func printDataToScreen(data: String){
//        RMXPrintToScreen(string: data, self.dataView)
        NSLog(data)
    }
    
    func processHit(point p: CGPoint) {
        if let hitResults = self.gameView.hitTest(p, options: nil) {
            // check that we clicked on at least one object
            if hitResults.count > 0 {
                // retrieved the first clicked object
                let result: AnyObject! = hitResults[0]
//                NSLog(result.)
                
                self.actionProcessor.manipulate(action: "throw", sprite: self.activeSprite, object: result, speed: 18000)
                
                // get its material
                let material = result.node!.geometry!.firstMaterial!
                
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
    
    var scene: RMXScene? {
        return self.world?.scene
    }
    
    var isPaused: Bool {
        return self.scene?.paused ?? true
    }
    
    func update(){
        if !self.isPaused {
            self.actionProcessor.animate()
            self.world?.animate()
            if !self.dataView!.hidden {
    //            let view: NSTextField = dataView!
    //            self.dataView?.display()
                self.printDataToScreen(self.actionProcessor.getData())
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

    func action(action: String = "reset",speed: RMFloatB = 1, point: [RMFloatB] = []) {
        self.actionProcessor.action( action,speed: speed, point: point)
    }
    
    
    func hideButtons(hide: Bool) {
        
    }
    
    func pauseGame(sender: AnyObject?) {
        self.scene?.paused = !self.scene!.paused
//        self.pauseMenu?.hidden = false
//        self.menuAccessBar?.hidden = true
        self.hideButtons(self.scene!.paused)
        
    }
    
    func unPauseGame(sender: AnyObject?) {
        self.scene?.paused = false
//        self.pauseMenu?.hidden = true
//        self.menuAccessBar?.hidden = false
        self.hideButtons(false)
    }
    
    func optionsMenu(sender: AnyObject?) {
        NSLog("Show Options")
        
    }
    
    func exitToMainMenu(sender: AnyObject?) {
        NSLog("End Simulation")

    }
    
    var _switch = true
    func restartSession(sender: AnyObject?) {
        //        self.world?.deleteWorld(backup: false)
        AiCubo.setUpWorld(self, type: _switch ? .EMPTY : .TEST)
        _switch = !_switch
        self.gameView!.scene = self.scene
        self.unPauseGame(sender)
    }
}