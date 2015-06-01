//
//  GameViewController.swift
//  SceneCubo
//
//  Created by Max Bilbow on 05/04/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import SceneKit
import QuartzCore
import GameKit

#if iOS
    typealias ViewController = UIViewController
    #elseif OSX
    typealias ViewController = NSViewController
    #endif


class GameViewController: ViewController , SCNSceneRendererDelegate {
    #if iOS
    weak var gameView: GameView! {
        return self.view as? GameView
    }
    #elseif OSX
    @IBOutlet weak var gameView: GameView?
    #endif
    
//    var gameKit: RMXGameManager = RMXGameManager()
    
    var interface: RMXInterface?
    
    var world: RMSWorld? {
        return self.interface?.world
    }
   
    override func awakeFromNib(){
        // create a new scene
        #if iOS
            
            
            
        self.view = GameView(frame: self.view.bounds)
        #endif
//        self.gameView?.initialize(self, interface: self.interface!)
        self.gameView?.gvc = self
        self.interface  = RMX.Controller(self)
        

//        self.gameView?.delegate = self.interface
//        self.world?.setWorldType()
//        let scene = self.world.scene
        
        // create and add a camera to the scene
//        let cameraNode = self.world.activeCamera
//
//        self.gameView?.pointOfView = cameraNode
//        
        // create and add a light to the scene
        
        
        
        
        
        

        // set the scene to the view

        
        // allows the user to manipulate the camera
        self.gameView?.allowsCameraControl = false
        
        // show statistics such as fps and timing information
        self.gameView?.showsStatistics = true
        
        // configure the view
        self.gameView?.backgroundColor = NSColor.blackColor()


    }
    
    func somethingHappened(thing: AnyObject){
        RMXLog(thing)
    }
    
}
