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
    #elseif OSX
    
#endif


    import SceneKit

    typealias RendererDelegate = SCNSceneRendererDelegate


class RMXInterface : NSObject, RendererDelegate, RMXControllerProtocol {
    lazy var actionProcessor: RMSActionProcessor = RMSActionProcessor(world: self.world!, gameView: self.gameView)
    private let _isDebugging = false
    var debugData: String = "No Data"
    
    var gvc: GameViewController?
    var gameView: GameView!

   
    var timer: NSTimer? //CADisplayLink?
    var world: RMSWorld?

    static var lookSpeed: RMFloatB = 1
    static var moveSpeed: RMFloatB = 1
    
    var activeSprite: RMXSprite? {
        return self.world?.activeSprite
    }
    
    #if iOS
    var view: UIView {
        return self.gvc!.gameView!
    }
    #endif

    
    
    var activeCamera: RMXCamera? {
        return self.world?.activeCamera.camera as? RMXCamera
    }
    
    init(gvc: GameViewController, scene: RMXScene? = nil){
        super.init()
        self.initialize(gvc)
        self.viewDidLoad(nil)
        NSLog("\(__FUNCTION__)")
    }
    
    func initialize(gvc: GameViewController, scene: RMXScene? = nil) -> RMXInterface {
        self.gvc = gvc
        self.gameView = gvc.gameView
        
        if self.world == nil {
            self.world = RMSWorld(scene: scene)
        }
//        self.world!.clock = RMXClock(world: self.world!, interface: self)

        self.gameView!.delegate = self

        return self
    }
    
    
    func viewDidLoad(coder: NSCoder!){
        if self.world == nil {
            self.world = RMSWorld(scene: RMXScene(coder: coder))
        }
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
            println("\(debugData)")
//            self.log("\n x\(leftPanData.x.toData()), y\(leftPanData.y)",sender: "LEFT")
//            self.log("x\(rightPanData.x.toData()), y\(rightPanData.y.toData())",sender: "RIGHT")
        }
        debugData = ""
    }
    
    

    func renderer(aRenderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        self.update()
    }

    
    func update(){
        self.actionProcessor.animate()
        self.world?.animate()
    }
    
    ///Stop all inputs (i.e. no gestures received)
    ///@virtual
    func handleRelease(arg: AnyObject, args: AnyObject ...) { }

    func action(action: String = "reset",speed: RMFloatB = 1, point: [RMFloatB] = []) {
        self.actionProcessor.movement( action,speed: speed, point: point)
    }
}