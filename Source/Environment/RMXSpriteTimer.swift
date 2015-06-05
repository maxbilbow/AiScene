//
//  RMXSpriteTimer.swift
//  AiScene
//
//  Created by Max Bilbow on 01/06/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation

class RMXSpriteTimer : NSObject {
    var sprite: RMXSprite
    
    
    init(sprite: RMXSprite){
        self.sprite = sprite
        super.init()
    }
    
    func addTimer(interval: NSTimeInterval = 5, target: AnyObject, selector: Selector, userInfo: AnyObject? = nil, repeats: Bool) {
        let timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: target, selector: selector, userInfo: userInfo, repeats: repeats)
        if repeats {
            self.timers.append(timer)
        }
    }
    
    private lazy var timers: [ NSTimer ] = [ NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "validate", userInfo: nil, repeats: true) ]
    
    func validate() {
        if self.sprite.world.isLive {
            if !self.sprite.world.validate(self.sprite) {
//                NSLog("reset \(sprite.name)")
                let lim = Int(self.sprite.world.radius / 2)
                self.sprite.setPosition(position: RMXVector3Random(lim, -lim), resetTransform: true)
                self.sprite.releaseItem()
            }
        } else {
//             NSLog("\(self.timer.valid)")
            for timer in self.timers {
                timer.invalidate()
            }
            self.shouldActivate = true
        }
        
    }
    
    var shouldActivate: Bool = true
    func activate() {
        if shouldActivate {
            for timer in self.timers {
                if !timer.valid {
                    timer.fire()// = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "validate", userInfo: nil, repeats: true)
                }
            }
        }
        self.shouldActivate = false
        
    }
}