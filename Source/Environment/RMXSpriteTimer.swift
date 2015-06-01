//
//  RMXSpriteTimer.swift
//  AiScene
//
//  Created by Max Bilbow on 01/06/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation

class RMXSpriteTimer : NSObject {
    lazy var timer: NSTimer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "validate", userInfo: nil, repeats: true)
    var sprite: RMXSprite
    
    init(sprite: RMXSprite){
        self.sprite = sprite
        super.init()
    }
    

    func validate() {
        if self.sprite.world.isLive {
            if !self.sprite.world.validate(self.sprite) {
                let lim = Int(self.sprite.world.radius / 2)
                self.sprite.setPosition(position: RMXVector3Random(lim, -lim), resetTransform: true)
            }
        } else {
            self.timer.invalidate()
        }
        
    }
    
    func activate() {
        if !self.timer.valid {
            self.timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "validate", userInfo: nil, repeats: true)
        }
    }
}