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

    func switchEnvironment(recogniser: UITapGestureRecognizer){
            world?.environments.plusOne()
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

        if let hitResults = scnView.hitTest(p, options: nil) {
        // check that we clicked on at least one object
            if hitResults.count > 0 {
                // retrieved the first clicked object
                let result: AnyObject! = hitResults[0]
                
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
                    
                    material.emission.contents = UIColor.blackColor()
                    
                    SCNTransaction.commit()
                }
                
                material.emission.contents = UIColor.redColor()
                
                SCNTransaction.commit()
            }
        }
    }

    
}



#endif


