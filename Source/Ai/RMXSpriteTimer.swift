//
//  RMXSpriteTimer.swift
//  AiScene
//
//  Created by Max Bilbow on 01/06/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation

@available(OSX 10.10, *)
class RMXSpriteTimer : NSObject, RMXTimer {
    var sprite: RMXSprite
    
    var validationTimer: NSTimer!
    init(sprite: RMXSprite){
        self.sprite = sprite
        super.init()
        self.validationTimer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "validate", userInfo: nil, repeats: true)
        self.timers.append(self.validationTimer)
    }
    
    func addTimer(interval: NSTimeInterval = 5, target: AnyObject, selector: Selector, userInfo: AnyObject? = nil, repeats: Bool) {
        let timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: target, selector: selector, userInfo: userInfo, repeats: repeats)
        if repeats {
            self.timers.append(timer)
        }
    }
    
    var timers: [ NSTimer ] = [  ]
    
    func validate() {
        self.sprite.validate()
    }
    
    func activate(node: AnyObject!) -> Void {
        if self.sprite.world.isLive {
            for timer in self.timers {
                if !timer.valid {
                    timer.fire()// = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "validate", userInfo: nil, repeats: true)
                }
            }
        } else {
            for timer in self.timers {
                timer.invalidate()
            }
        }
        
    }
}