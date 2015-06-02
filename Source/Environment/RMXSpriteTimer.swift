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
    lazy var timers: [ NSTimer ] = [ NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "validate", userInfo: nil, repeats: true) ]

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
        }
        
    }
    
    func activate() {
        for timer in self.timers {
            if !timer.valid {
                timer.fire()// = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "validate", userInfo: nil, repeats: true)
            }
        }
        
    }
}