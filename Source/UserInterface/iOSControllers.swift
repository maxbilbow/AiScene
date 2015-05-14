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
    
    func toggleAi(recogniser: UITapGestureRecognizer){
        self.world!.aiOn = !self.world!.aiOn
        NSLog("aiOn: \(self.world!.aiOn)")
        //self.world!.setBehaviours(self.world!.hasBehaviour)
    }
    
    func jump(recogniser: UITapGestureRecognizer){
        self.action(action: "jump", speed: 1)
    }
    
        private func _handleRelease(state: UIGestureRecognizerState) {
            if state == UIGestureRecognizerState.Ended {
                self.action(action: "stop")
                self.action(action: "extendArm", speed: 0)
                self.log()
            }
        }
    
        func handleTapLeft(recognizer: UITapGestureRecognizer) {
            self.log("Left Tap")
            self.action(action: "grab")
            _handleRelease(recognizer.state)
        }
    
        func noTouches(recognizer: UIGestureRecognizer) {
            if recognizer.state == UIGestureRecognizerState.Ended {
                self.action(action: "stop")
                self.log("noTouches?")
            }
            _handleRelease(recognizer.state)
        }

        
        func toggleGravity(recognizer: UITapGestureRecognizer) {
            self.log()
            self.action(action: "toggleGravity", speed: 1)
            _handleRelease(recognizer.state)
        }
        
        
    func toggleAllGravity(recognizer: UITapGestureRecognizer) {
        self.log()
        self.action(action: "toggleAllGravity", speed: 1)
        _handleRelease(recognizer.state)
    }
    
    
    func handleMovement(recogniser: UILongPressGestureRecognizer){
        let point = recogniser.locationInView(recogniser.view)
        if recogniser.state == .Began {
            self.moveOrigin = point
        } else if recogniser.state == .Ended {
            _handleRelease(recogniser.state)
        } else {
            let forward = RMFloatB(point.y - self.moveOrigin.y)
            let sideward = RMFloatB(point.x - self.moveOrigin.x)
            self.action(action: "move", speed: self.moveSpeed, point: [sideward,0, forward])
        }
        
    }
    
        ///The event handling method
        func handleOrientation(recognizer: UIPanGestureRecognizer) {
            if recognizer.numberOfTouches() == 1 {
                let point = recognizer.velocityInView(self.view)
                    #if SceneKit
                        let yDir:Float = -1
                        #else
                        let yDir:Float = 1
                        #endif
                self.action(action: "look", speed: self.lookSpeed, point: [Float(point.x), yDir * Float(point.y)])
            }
//            _handleRelease(recognizer.state)
        }
    
    func handlePinch(recognizer: UIPinchGestureRecognizer) {
            let x: Float = Float(recognizer.scale) * 0.2
            self.log()
            self.action(action: "enlargeItem", speed: x)
            _handleRelease(recognizer.state)
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
        func longPressLeft(recognizer: UILongPressGestureRecognizer) {
            self.log()
            if recognizer.state == UIGestureRecognizerState.Began {
                self.action(action: "extendArm", speed: -1)
                self.action(action: "toggleAllGravity")
            } else if recognizer.state == UIGestureRecognizerState.Ended {
                self.action(action: "extendArm", speed: 0)
            }
            _handleRelease(recognizer.state)
        }
        
        func longPressRight(recognizer: UILongPressGestureRecognizer) {
            self.log()
            if recognizer.state == UIGestureRecognizerState.Began {
                self.action(action: "extendArm", speed: 1)
                self.action(action: "toggleAllGravity")
            } else if recognizer.state == UIGestureRecognizerState.Ended {
                self.action(action: "extendArm", speed: 0)
            }
            _handleRelease(recognizer.state)
        }
    
    func grabOrThrow(recognizer: UIGestureRecognizer) {
        let spriteAction = self.world!.activeSprite
        if let item = spriteAction.item  {
            spriteAction.throwItem(20)
            return
        }
        
        #if SceneKit
            // retrieve the SCNView
            let scnView = self.view as! GameView
            // check what nodes are tapped
            let p = recognizer.locationInView(scnView)

            if let hitResults = scnView.hitTest(p, options: nil) {
            // check that we clicked on at least one object
            if hitResults.count > 0 {
                // retrieved the first clicked object
                let result: AnyObject! = hitResults[0]
                
                ///TODO: GrabItem (and not itself)
//                if self.activeSprite!.hasItem {
//                    NSLog("Node is thrown: \(self.activeSprite!.item!.name)")
//                    self.action(action: "throw", speed: 20)
//                    return
//                } else
                
                if let node = result.node {
                    if let body = node.physicsBody {
                        switch (body.type){
                        case .Static:
                            NSLog("Node is static")
                            return
                        case .Dynamic:
                            NSLog("Node is Dynamic")
                            break
                        case .Kinematic:
                            NSLog("Node is Kinematic")
                            break
                        default:
                            fatalError("Something went wrong")
                        }
                    }
                    let rootNode = RMXSprite.rootNode(node, rootNode: self.world!.scene.rootNode)
                    if rootNode == self.activeSprite?.node {
                        NSLog("Node is self")
                        //return
                    } else {
                        if let item = self.world!.getSprite(node: node) {
                            if let itemInHand = self.activeSprite!.item {
                                if item.name == itemInHand.name {
                                    self.action(action: "throw", speed: 20 * item.mass)
                                    NSLog("Node \(item.name) was thrown with force: 20 x \(item.mass)")
                                } else {
//                                   self.world?.observer.grabItem(item: item)
                                    NSLog("Node is grabbable: \(item.name) but holding node: \(itemInHand.name)")
                                }
                            } else if item.type != RMXSpriteType.BACKGROUND {
                                self.world?.observer.grabItem(item: item)
                                NSLog("Node is grabbable: \(item.name)")
                            } else {
                                NSLog("Node was NOT grabbable: \(item.name)")
                            }
                        }
                    }
                }
                
  
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
            #else
            spriteAction.grabItem()
            
        #endif
    }

    
    }



#endif


