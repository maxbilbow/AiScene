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
import RMXKit

import UIKit

extension RMXDPad {
    
    
    func resetTransform(recogniser: UITapGestureRecognizer) {
//        self.activeSprite?.setAngle(roll: 0)
        self.actionProcessor.action(UserAction.RESET)
    }
    func printData(recogniser: UITapGestureRecognizer){
        self.actionProcessor.action(UserAction.GET_INFO)
    }
    
    func showScores(recogniser: UITapGestureRecognizer){
        self.actionProcessor.action(UserAction.TOGGLE_SCORES, speed: 1)
    }
    
    func toggleAi(recogniser: UITapGestureRecognizer){
        self.world.toggleAi()
    }
    
    
    func zoom(recogniser: UIPinchGestureRecognizer) {        
        self.actionProcessor.action(UserAction.ZoomInAnOut, speed: RMFloat(recogniser.velocity))
    }
    
    
    func toggleGravity(recognizer: UITapGestureRecognizer) {
            self.actionProcessor.action(UserAction.TOGGLE_GRAVITY, speed: 1)
        }
        
        
    func toggleAllGravity(recognizer: UITapGestureRecognizer) {
        self.actionProcessor.action(UserAction.TOGGLE_GRAVITY, speed: 1)
    }
    
    
   
    
    
    
        ///The event handling method
        func handleOrientation(recognizer: UIPanGestureRecognizer) {
            if recognizer.numberOfTouches() == 1 {
                let point = recognizer.velocityInView(self.gameView)
                
                self.actionProcessor.action(.LOOK_AROUND, speed: self.lookSpeed, args: point)
            }
//            _handleRelease(recognizer.state)
        }
    
    
    func nextCamera(recogniser: UITapGestureRecognizer) {
            self.actionProcessor.action(UserAction.NEXT_CAMERA, speed: 1)
    }
    
    func previousCamera(recogniser: UITapGestureRecognizer) {
        self.actionProcessor.action(UserAction.PREV_CAMERA, speed: 1)
    }


    func grabOrThrow(recognizer: UITapGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.gameView//.view as! GameView
        // check what nodes are tapped
        let p = recognizer.locationInView(scnView)
        
        self.processHit(point: p, type: UserAction.THROW_ITEM)

//        self.processHit(scnView.hitTest(p, options: nil))
    }

    
}




