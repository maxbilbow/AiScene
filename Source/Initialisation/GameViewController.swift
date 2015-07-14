//
//  GameViewController.swift
//  SceneCubo
//
//  Created by Max Bilbow on 05/04/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import SceneKit
import QuartzCore
import RMXKit

#if iOS
    typealias ViewController = UIViewController
    #elseif OSX
    typealias ViewController = NSViewController
    #endif

//@available(OSX 10.10, *)
class GameViewController: ViewController , SCNSceneRendererDelegate {
    
    var rmxID: Int?; var uniqueID, name: String? ; var print: String = classForCoder().description()
    
    #if iOS
    weak var gameView: GameView! {
        return self.view as? GameView
    }
    #elseif OSX
    @IBOutlet weak var gameView: GameView?
    #endif
    
   
    static var current: GameViewController!
    override func awakeFromNib(){
        // create a new scene
        #if iOS
        self.view = GameView(frame: self.view.bounds)
        #endif

        
        if GameViewController.current == nil {
            GameViewController.current = self
        } else {
            fatalError("Should not be possible to have > 1 GVC yet.")
        }

        if let _ = RMXInterface.current {
            NSLog("Interface initiated")
        }
        
        
        // allows the user to manipulate the camera
        self.gameView?.allowsCameraControl = false
        
        // show statistics such as fps and timing information
        self.gameView?.showsStatistics = true
        
        // configure the view
        self.gameView?.backgroundColor = RMColor.blackColor()
        


    }
    
      
    #if iOS
    override func didReceiveMemoryWarning() {
        //self.gameView.world?.rootNode.childNodeWithName("sun", recursively: true)?.light?.shadowMapSize = CGSizeZero
        
        super.didReceiveMemoryWarning()
    }
    #endif
    

}
