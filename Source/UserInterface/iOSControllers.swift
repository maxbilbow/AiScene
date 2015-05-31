//
//  iOSControllers.swift
//  RattleGLES
//
//  Created by Max Bilbow on 25/03/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
import GLKit
import SceneKit

#if iOS
import UIKit

extension RMXDPad {
    
    
    
    func resetTransform(recogniser: UITapGestureRecognizer) {
//        self.activeSprite?.setAngle(roll: 0)
        self.action(action: "reset")
    }
    func printData(recogniser: UITapGestureRecognizer){
        self.action(action: "information")
    }
    
    func showScores(recogniser: UITapGestureRecognizer){
        if self.scoreBoard == nil {
            let bounds = self.getRect(withinRect: self.gameView.bounds, row: (2,6), col: (2, 3))
            self.scoreBoard = UILabel(frame: bounds)
            self.gameView!.addSubview(self.scoreBoard!)
        }
        self.action(action: RMXInterface.SHOW_SCORE)
    }
    
    func toggleAi(recogniser: UITapGestureRecognizer){
        self.world!.aiOn = !self.world!.aiOn
        RMXLog("aiOn: \(self.world!.aiOn)")
        //self.world!.setBehaviours(self.world!.hasBehaviour)
    }
    
    
    func zoom(recogniser: UIPinchGestureRecognizer) {        
        self.action(action: "zoom", speed: -RMFloatB(recogniser.velocity))//, point: <#[RMFloatB]#>)
    }
    
    @availability(*,deprecated=1)
        internal func _handleRelease(state: UIGestureRecognizerState) {
            if state == UIGestureRecognizerState.Ended {
                self.action(action: "stop")
                self.action(action: "extendArm", speed: 0)
                self.log()
            }
        }
    
    @availability(*,deprecated=1)
        func noTouches(recognizer: UIGestureRecognizer) {
            if recognizer.state == UIGestureRecognizerState.Ended {
                self.action(action: "stop")
                self.log("noTouches?")
            }
//            _handleRelease(recognizer.state)
        }

        
        func toggleGravity(recognizer: UITapGestureRecognizer) {
            self.log()
            self.action(action: "toggleGravity", speed: 1)
//            _handleRelease(recognizer.state)
        }
        
        
    func toggleAllGravity(recognizer: UITapGestureRecognizer) {
        self.log()
        self.action(action: "toggleAllGravity", speed: 1)
//        _handleRelease(recognizer.state)
    }
    
    
   
    
    
    
        ///The event handling method
        func handleOrientation(recognizer: UIPanGestureRecognizer) {
            if recognizer.numberOfTouches() == 1 {
                let point = recognizer.velocityInView(self.gameView)
                
                self.action(action: "look", speed: RMXInterface.lookSpeed, point: [-Float(point.x), Float(point.y)])
            }
//            _handleRelease(recognizer.state)
        }
    
    
    func nextCamera(recogniser: UITapGestureRecognizer) {
            self.action(action: "nextCamera", speed: 1)
    }
    
    func previousCamera(recogniser: UITapGestureRecognizer) {
        self.action(action: "previousCamera", speed: 1)
    }

    
        func extendArm(recognizer: UILongPressGestureRecognizer) {
            self.log()
            if recognizer.state == UIGestureRecognizerState.Began {
                self.action(action: "extendArm", speed: 1)
            } else if recognizer.state == UIGestureRecognizerState.Ended {
                self.action(action: "extendArm", speed: 0)
            }
           
        }
    
    func grabOrThrow(recognizer: UITapGestureRecognizer) {
        let spriteAction = self.world!.activeSprite


        // retrieve the SCNView
        let scnView = self.gameView//.view as! GameView
        // check what nodes are tapped
        let p = recognizer.locationInView(scnView)
        
        self.processHit(point: p)

//        self.processHit(scnView.hitTest(p, options: nil))
    }

    
}



#endif


