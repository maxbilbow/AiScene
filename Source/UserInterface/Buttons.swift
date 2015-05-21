//
//  Buttoms.swift
//  AiScene
//
//  Created by Max Bilbow on 20/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import UIKit

extension RMXDPad {
    internal func getButton(frame: CGRect) -> UIView {
        let buttonBase = UIView(frame: frame)
        buttonBase.alpha = 0.5
        //        buttonBase.layer.cornerRadius = 50;
        buttonBase.backgroundColor = UIColor.blueColor()
        
        
        
        
        
        
        
        buttonBase.userInteractionEnabled = true
        
        return buttonBase

    }
    
    internal func moveButton(size: CGSize, origin: CGPoint) -> UIView {
        let frame = CGRectMake(origin.x, origin.y, size.width, size.height)
        let baseButton = self.getButton(frame)
        
        let handleMovement: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self,action: "handleMovement:")
        handleMovement.minimumPressDuration = 0.0
        baseButton.addGestureRecognizer(handleMovement)
        return baseButton
    }

    
    func handleMovement(recogniser: UILongPressGestureRecognizer){
        let point = recogniser.locationInView(self.gameView)
        if recogniser.state == .Began {
            self.moveOrigin = point
        } else if recogniser.state == .Ended {
            self.moveButtonPad!.frame = self.moveButtonCenter
            self.action(action: "stop")
        } else {
            let move = CGPoint(x: point.x - self.moveOrigin.x, y: point.y - self.moveOrigin.y)
            
            var bMove = move
            let x = log10(1 + 100 * move.x * move.x)
            let y = log10(1 + 100 * move.y * move.y)
            bMove.x = move.x > 0 ? x : -x
            bMove.y = move.y > 0 ? y : -y
            let rect = self.moveButtonCenter
            self.moveButtonPad!.center = point + move * -0.3 //rect.origin + bMove//self.moveOrigin + move
            self.moveButtonPad?.setNeedsDisplay()
            self.action(action: "move", speed: RMXInterface.moveSpeed, point: [RMFloatB(bMove.x),0, RMFloatB(bMove.y)])
//            NSLog(bMove.print)
        }
        
    }
    
    var moveButtonCenter: CGRect {
        let avg = (self.gameView.bounds.size * 0.15).average
        let size = CGSize(width: avg, height: avg)
        let origin = CGPoint(x: self.gameView.bounds.size.width * 0.15, y: self.gameView.bounds.size.height * 0.78 - size.height)
        let frame = CGRectMake(origin.x, origin.y, size.width, size.height)
        return frame
    }
    
    var boomButtonCenter: CGRect {
        let avg = (self.gameView.bounds.size * 0.10).average
        let size = CGSize(width: avg, height: avg)
        let origin = CGPoint(x: self.gameView.bounds.size.width * 0.82 - size.width / 2, y: self.gameView.bounds.size.height * 0.80 - size.height)
        let frame = CGRectMake(origin.x, origin.y, size.width, size.height)
        return frame
    }
    
    func explode(recogniser: UILongPressGestureRecognizer) {
        //        self.activeSprite?.setAngle(roll: 0)
        if recogniser.state == .Ended {
            self.action(action: "explode", speed: 1)
            //self.actionProcessor.explode(force: self.boomTimer)
            
        } else {
            self.action(action: "explode", speed: 0)
            self.boomTimer++ //TODO: put this in the ActionProcessor class
        }
    }
    
    var jumpButtonCenter: CGRect {
        let avg = (self.gameView.bounds.size * 0.10).average
        let size = CGSize(width: avg, height: avg)
        let origin = CGPoint(x: self.gameView.bounds.size.width * 0.82 + size.width / 2, y: self.gameView.bounds.size.height * 0.75 - size.height)
        let frame = CGRectMake(origin.x, origin.y, size.width, size.height)
        return frame
    }
    
    func jump(recogniser: UITapGestureRecognizer){
        self.action(action: "jump", speed: 1)
    }
}