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

extension RMXMobileInput {
    func resetTransform(recogniser: UITapGestureRecognizer) {
//        self.activeSprite?.setAngle(roll: 0)
        RMX.ActionProcessor.current.action(UserAction.RESET)
    }
    func printData(recogniser: UITapGestureRecognizer){
        RMX.ActionProcessor.current.action(UserAction.GET_INFO)
    }
    
    func showScores(recogniser: UITapGestureRecognizer){
        RMX.ActionProcessor.current.action(UserAction.TOGGLE_SCORES, speed: 1)
    }
    
    func toggleAi(recogniser: UITapGestureRecognizer){
        RMXScene.current.toggleAi()
    }
    
    
    func zoom(recogniser: UIPinchGestureRecognizer) {        
        RMX.ActionProcessor.current.action(UserAction.ZoomInAnOut, speed: RMFloat(recogniser.velocity))
    }
    
    
    func toggleGravity(recognizer: UITapGestureRecognizer) {
            RMX.ActionProcessor.current.action(UserAction.TOGGLE_GRAVITY, speed: 1)
        }
        
        
    func toggleAllGravity(recognizer: UITapGestureRecognizer) {
        RMX.ActionProcessor.current.action(UserAction.TOGGLE_GRAVITY, speed: 1)
    }
    
    
    ///The event handling method
    func handleOrientation(recognizer: UIPanGestureRecognizer) {
        if recognizer.numberOfTouches() == 1 {
            let point = recognizer.velocityInView(GameView.current)
            
            RMX.ActionProcessor.current.action(.LOOK_AROUND, speed: self.lookSpeed, args: point)
        }
//            _handleRelease(recognizer.state)
    }

    
    func nextCamera(recogniser: UITapGestureRecognizer) {
            RMX.ActionProcessor.current.action(UserAction.NEXT_CAMERA, speed: 1)
    }
    
    func previousCamera(recogniser: UITapGestureRecognizer) {
        RMX.ActionProcessor.current.action(UserAction.PREV_CAMERA, speed: 1)
    }


    func grabOrThrow(recognizer: UITapGestureRecognizer) {
        // retrieve the SCNView
        let scnView = GameView.current//.view as! GameView
        // check what nodes are tapped
        let p = recognizer.locationInView(scnView)
        
        self.processHit(point: p, type: UserAction.THROW_ITEM)

//        self.processHit(scnView.hitTest(p, options: nil))
    }

    
}




