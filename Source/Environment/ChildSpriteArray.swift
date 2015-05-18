//
//  ChildSpriteArray.swift
//  AiCubo
//
//  Created by Max Bilbow on 18/04/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation

class ChildSpriteArray {
    var parent: AnyObject
    private var type: RMXWorldType {
        return (self.parent as? RMSWorld)!.type ?? .NULL
    }

    private var _key: Int = 0
    
    //        var current: UnsafeMutablePointer<[Int:RMXSprite]> {
    //            return nodeArray[type.rawValue]
    //        }
    private var spriteArray: [ [RMXSprite] ] = [ Array<RMXSprite>() ]
    var current:[RMXSprite] {
        return spriteArray[_key]
    }
    func get(key: Int) -> RMXSprite? {
        for (index, node) in enumerate(self.spriteArray[_key]) {
            if node.rmxID == key{
                return node
            }
        }
        return nil
    }
    
    func set(node: RMXSprite) {
        self.spriteArray[_key].append(node)
    }
    
    func remove(key: Int) -> RMXSprite? {
        for (index, node) in enumerate(self.spriteArray[_key]) {
            if node.rmxID == key{
                self.spriteArray[_key].removeAtIndex(index)
                return node
            }
        }
        return nil
    }
    
    func plusOne(){
        if self._key + 1 > RMXWorldType.DEFAULT.rawValue {
            self._key = 0
        } else {
            self._key += 1
        }
    }
    
    func setType(type: RMXWorldType){
        self._key = type.rawValue
    }
    
    func getCurrent() ->[RMXSprite]? {
        return self.current
    }
    
    func makeFirst(node: RMXSprite){
        self.remove(node.rmxID)
        self.spriteArray[_key].insert(node, atIndex: 0)
    }
    init(parent p: AnyObject){
        self.parent = p
        if let parent = p as? RMSWorld {
            self.spriteArray.reserveCapacity(RMXWorldType.DEFAULT.rawValue)
            for (var i = 1; i <= RMXWorldType.DEFAULT.rawValue ; ++i){
                let dict = Array<RMXSprite>()
                self.spriteArray.append(dict)
            }
        }
    }
}