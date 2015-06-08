//
//  RMXAiDelegate.swift
//  AiScene
//
//  Created by Max Bilbow on 08/06/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation

enum AiState { case MOVING, TURNING, IDLE }

protocol RMXAiDelegate : NSObjectProtocol {
    var state: String? { get }
    var args: [RMXSpriteType] { get }
    var spriteLogic: [AiBehaviour] { get }
    var sprite: RMXSprite { get }
    init(sprite: RMXSprite)
    func run(sender: AnyObject?, updateAtTime time: NSTimeInterval) -> Void
    func getTarget(args: RMXSpriteType ...) -> RMXSprite?
}


class RMXAi : NSObject, RMXAiDelegate {
    
    private var _state: String?
    
    func setState(state: String?) {
        self._state = state
    }
    
    var state: String? {
        return self.state
    }
    
    var world: RMXWorld {
        return self.sprite.world
    }
    
    var args: [RMXSpriteType] {
        return [ RMXSpriteType.PASSIVE ]
    }
    
    var spriteLogic: [AiBehaviour] {
        return self.sprite.spriteLogic
    }
    
    private var _sprite: RMXSprite
    
    var sprite: RMXSprite {
        return _sprite
    }
    
    required init(sprite: RMXSprite) {
        _sprite = sprite
        super.init()
    }
    
    internal func getTarget(args: RMXSpriteType ...) -> RMXSprite? {
        return RMXAi.randomSprite(self.world, not: self.sprite, type: args.count == 0 ? self.args : args)
    }
    
    func run(sender: AnyObject?, updateAtTime time: NSTimeInterval) {
        for logic in self.spriteLogic {
            logic(self.sprite.node)
        }
        self.sprite.timer.activate()
    }
    
    class func randomSprite(world: RMXWorld, not: RMXSprite, type: [RMXSpriteType]?) -> RMXSprite? {
        if let types = type {
            let array = world.sprites.filter { (child) -> Bool in
                for type in types {
                    if child.type == type && child.rmxID != not.rmxID {
                        return true
                    }
                }
                return false
            }
            return array.count == 0 ? nil : array[random() % array.count]
        }
        return nil
    }
    
}