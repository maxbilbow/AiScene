//
//  GameViewController.swift
//  SceneCubo
//
//  Created by Max Bilbow on 05/04/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import SceneKit
import QuartzCore
//, world: self.gameView.world!)
#if iOS
    typealias ViewController = UIViewController
//    typealias NSColor = UIColor
    #elseif OSX
    typealias ViewController = NSViewController
    #endif
import AVFoundation
class GameViewController: ViewController, SCNSceneRendererDelegate {
    #if iOS
    weak var gameView: GameView? {
        return self.view as? GameView
    }
    #elseif OSX
    @IBOutlet weak var gameView: GameView?
    #endif
    
    
    lazy var interface: RMXInterface? = RMX.Controller(self)
    
    var world: RMSWorld? {
        return self.interface!.world
    }
   
    override func awakeFromNib(){
        // create a new scene
        #if iOS
            
            
            
        self.view = GameView(frame: self.view.bounds)
        #endif
        self.gameView!.initialize(self, interface: self.interface!)
//        self.world?.setWorldType()
        let scene = self.world!.scene
        
        // create and add a camera to the scene
        let cameraNode = self.world!.activeCamera

        self.gameView?.pointOfView = cameraNode
        
        // create and add a light to the scene
        
        
        
        
        
        
//        scene.rootNode.addChildNode(self.world!.node)
        // set the scene to the view
        self.gameView!.scene = scene
        
        // allows the user to manipulate the camera
        self.gameView!.allowsCameraControl = false
        
        // show statistics such as fps and timing information
        self.gameView!.showsStatistics = true
        
        // configure the view
        self.gameView!.backgroundColor = NSColor.blackColor()


        #if OSX
//        RMX.setKeyboard(self.interface as! RMSKeys, type: .French)
        #endif
    }
    
    func somethingHappened(thing: AnyObject){
        RMXLog(thing)
    }
    
}
