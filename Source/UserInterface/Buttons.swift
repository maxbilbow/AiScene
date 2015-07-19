//
//  Buttoms.swift
//  AiScene
//
//  Created by Max Bilbow on 20/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import UIKit
import RMXKit

#if iOS
    typealias RMImage = UIImage
    #elseif OSX
    typealias RMImage = NSImage
    #endif


    extension RMXMobileInput {
        
        static func getImage() -> RMImage {
            return RMImage(named: "art.scnassets/2D/circle_shape.png")!
        }
        internal func getButton(frame: CGRect) -> UIView {
            let buttonBase = UIView(frame: frame)
            buttonBase.alpha = 0.5
            buttonBase.layer.cornerRadius = 20
            buttonBase.backgroundColor = UIColor.blueColor()
    //        buttonBase.userInteractionEnabled = true
            
            return buttonBase

        }
        
        internal func moveButton(size: CGSize, origin: CGPoint) -> UIView {
            let frame = CGRectMake(origin.x, origin.y, size.width, size.height)
            let baseButton = self.getButton(frame)
            
            
            return baseButton
        }

        private func _limit(x: CGFloat, limit lim: CGFloat) -> CGFloat {
            let limit: CGFloat = lim// ?? 2// CGFloat(RMXInterface.moveSpeed)
            if x > limit {
                return limit
            } else if x < -limit {
                return -limit
            } else {
                return x
            }
        }
        func handleMovement(recogniser: UILongPressGestureRecognizer){
            let point = recogniser.locationInView(GameView.current)
            if recogniser.state == .Began {
                self.moveOrigin = point
            } else if recogniser.state == .Ended {
                self.moveButtonPad!.frame = self.moveButtonCenter
                RMX.ActionProcessor.current.action(.STOP_MOVEMENT)
            } else {
                var move = CGPoint(x: point.x - self.moveOrigin.x, y: point.y - self.moveOrigin.y)

                
                let rect = self.moveButtonCenter
                
                let limX = rect.size.width * 0.5 ; let limY = rect.size.height * 0.5
                
                move.x = _limit(move.x, limit: limX) /// limX //move.x > 0 ? x : -x
                move.y = _limit(move.y, limit: limY) /// limY //move.y > 0 ? y : -y
                
                let percentage = CGPoint(x: move.x / limX, y: move.y / limY)
                self.moveButtonPad!.center = rect.origin + rect.size * 0.5 + move * 1
    //            self.moveButtonPad?.setNeedsDisplay()
                RMX.ActionProcessor.current.action(.MOVE, speed: 1, args: percentage * self.moveSpeed)
    //            NSLog("FWD: \((x / limX).toData()), SIDE: \((y / limY).toData())),  TOTAL: \(1)")
            }
            
        }
        
        var moveButtonCenter: CGRect {
            let avg = (GameView.current!.bounds.size * 0.13).average
            let size = CGSize(width: avg, height: avg)
            let origin = CGPoint(x: GameView.current!.bounds.size.width * 0.07, y: GameView.current!.bounds.size.height * 0.88 - size.height)
            let frame = CGRectMake(origin.x, origin.y, size.width, size.height)
            return frame
        }
        
        var boomButtonCenter: CGRect {
            let avg = (GameView.current!.bounds.size * 0.10).average
            let size = CGSize(width: avg, height: avg)
            let origin = CGPoint(x: GameView.current!.bounds.size.width * 0.82 - size.width / 2, y: GameView.current!.bounds.size.height * 0.88 - size.height)
            let frame = CGRectMake(origin.x, origin.y, size.width, size.height)
            return frame
        }
        
        func explode(recogniser: UILongPressGestureRecognizer) {
            //        RMXNode.current?.setAngle(roll: 0)
            if recogniser.state == .Ended {
                if RMXNode.current?.isHoldingItem ?? false {
                    RMX.ActionProcessor.current.throwOrGrab(nil, withForce: 1, tracking: false)
                    RMXNode.current?.throwItem(force: 1)
                } else {
                    RMX.ActionProcessor.current.action(UserAction.BOOM, speed: 1)
                }
                //RMX.ActionProcessor.current.explode(force: self.boomTimer)
                
            } else {
                RMX.ActionProcessor.current.action(UserAction.BOOM, speed: 0)
                self.boomTimer++ //TODO: put this in the ActionProcessor class
            }
        }
        
        var jumpButtonCenter: CGRect {
            let avg = (GameView.current!.bounds.size * 0.10).average
            let size = CGSize(width: avg, height: avg)
            let origin = CGPoint(x: GameView.current!.bounds.size.width * 0.82 + size.width / 2, y: GameView.current!.bounds.size.height * 0.85 - size.height)
            let frame = CGRectMake(origin.x, origin.y, size.width, size.height)
            return frame
        }
        
        func jump(recogniser: UILongPressGestureRecognizer){
            let speed: RMFloat = recogniser.state == .Ended ? 1 : 0
            RMX.ActionProcessor.current.action(UserAction.JUMP, speed: speed)
        }
    }
