//
//  Buttoms.swift
//  AiScene
//
//  Created by Max Bilbow on 20/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import UIKit

#if iOS
    typealias RMImage = UIImage
    #elseif OSX
    typealias RMImage = NSImage
    #endif

extension RMXModels {
    
    class func getImage() -> RMImage {
        return RMImage(named: "art.scnassets/2D/circle_shape.png")!
    }
    
}

extension RMXDPad {
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
        let point = recogniser.locationInView(self.gameView)
        if recogniser.state == .Began {
            self.moveOrigin = point
        } else if recogniser.state == .Ended {
            self.moveButtonPad!.frame = self.moveButtonCenter
            self.action(UserAction.STOP_MOVEMENT)
        } else {
            var move = CGPoint(x: point.x - self.moveOrigin.x, y: point.y - self.moveOrigin.y)
            var bMove = move
            
            let rect = self.moveButtonCenter
            
            let limX = rect.size.width * 0.5 ; let limY = rect.size.height * 0.5
            
            move.x = _limit(move.x, limit: limX) /// limX //move.x > 0 ? x : -x
            move.y = _limit(move.y, limit: limY) /// limY //move.y > 0 ? y : -y
            
            var percentage = CGPoint(x: move.x / limX, y: move.y / limY)
            self.moveButtonPad!.center = rect.origin + rect.size * 0.5 + move * 1
//            self.moveButtonPad?.setNeedsDisplay()
            self.action(UserAction.MOVE, speed: 1, args: percentage * CGFloat(RMXInterface.moveSpeed))
//            NSLog("FWD: \((x / limX).toData()), SIDE: \((y / limY).toData())),  TOTAL: \(1)")
        }
        
    }
    
    var moveButtonCenter: CGRect {
        let avg = (self.gameView!.bounds.size * 0.13).average
        let size = CGSize(width: avg, height: avg)
        let origin = CGPoint(x: self.gameView!.bounds.size.width * 0.07, y: self.gameView!.bounds.size.height * 0.88 - size.height)
        let frame = CGRectMake(origin.x, origin.y, size.width, size.height)
        return frame
    }
    
    var boomButtonCenter: CGRect {
        let avg = (self.gameView!.bounds.size * 0.10).average
        let size = CGSize(width: avg, height: avg)
        let origin = CGPoint(x: self.gameView!.bounds.size.width * 0.82 - size.width / 2, y: self.gameView!.bounds.size.height * 0.88 - size.height)
        let frame = CGRectMake(origin.x, origin.y, size.width, size.height)
        return frame
    }
    
    func explode(recogniser: UILongPressGestureRecognizer) {
        //        self.activeSprite?.setAngle(roll: 0)
        if recogniser.state == .Ended {
            if self.activeSprite.hasItem {
                self.actionProcessor.throwOrGrab(nil, withForce: 1, tracking: false)
                self.activeSprite.throwItem(force: 1)
            } else {
                self.action(UserAction.BOOM, speed: 1)
            }
            //self.actionProcessor.explode(force: self.boomTimer)
            
        } else {
            self.action(UserAction.BOOM, speed: 0)
            self.boomTimer++ //TODO: put this in the ActionProcessor class
        }
    }
    
    var jumpButtonCenter: CGRect {
        let avg = (self.gameView!.bounds.size * 0.10).average
        let size = CGSize(width: avg, height: avg)
        let origin = CGPoint(x: self.gameView!.bounds.size.width * 0.82 + size.width / 2, y: self.gameView!.bounds.size.height * 0.85 - size.height)
        let frame = CGRectMake(origin.x, origin.y, size.width, size.height)
        return frame
    }
    
    func jump(recogniser: UILongPressGestureRecognizer){
        let speed: RMFloat = recogniser.state == .Ended ? 1 : 0
        self.action(UserAction.JUMP, speed: speed)
    }
}