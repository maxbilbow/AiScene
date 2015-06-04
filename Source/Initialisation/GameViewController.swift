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


class GameViewController: ViewController , SCNSceneRendererDelegate, RMXObject {
    
    var rmxID: Int?; var uniqueID, name: String? ; var print: String = classForCoder().description()
    
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
        
        for player in self.world!.children {
            player.attributes.addObserver(self, forKeyPath: "isAlive", options: NSKeyValueObservingOptions.Old, context: UnsafeMutablePointer<Void>())
            player.attributes.addObserver(self, forKeyPath: "health", options: NSKeyValueObservingOptions.Initial, context: UnsafeMutablePointer<Void>())
            player.attributes.addObserver(self, forKeyPath: "points", options: NSKeyValueObservingOptions.New, context: GameViewController.context)
        }


    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if let attributes = object as? SpriteAttributes {
//            if !attributes.isAlive {
                NSLog("\(keyPath) \(attributes.sprite.name!) just died!")
//                attributes.deRetire()
//            }
        }
    }
    func somethingHappened(thing: AnyObject?){
      
    }
    static var context = UnsafeMutablePointer<Void>()
}
