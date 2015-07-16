//
//  ChildSpriteArray.swift
//  AiCubo
//
//  Created by Max Bilbow on 18/04/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation

@available(OSX 10.10, *)
extension RMX {
    static func spriteWith(ID ID: Int, inArray array: Array<RMXNode>) -> RMXNode? {
        for sprite in array {
            if sprite.rmxID == ID {
                return sprite
            }
        }
        return nil
//        return array.filter({ (sprite: RMXNode) -> Bool in
//            return sprite.rmxID == ID
//        }).first
    }
}

/*
@availability(*,deprecated=1)
class SpriteArray {
    var parent: AnyObject
    private var type: GameType {
        return (self.parent as? RMSWorld)!.type ?? .NULL
    }

    private var _key: Int = 0
    
    //        var current: UnsafeMutablePointer<[Int:RMXNode]> {
    //            return nodeArray[type.rawValue]
    //        }
    private var spriteArray: [ [RMXNode] ] = [ Array<RMXNode>() ]
    var current:[RMXNode] {
        return spriteArray[_key]
    }
    
    class func get(key: Int, inArray array: Array<RMXNode>) -> RMXNode? {
        for node in array {
            if node.rmxID == key{
                return node
            }
        }
        return nil
    }
    
    func get(key: Int) -> RMXNode? {
        for (index, node) in enumerate(self.spriteArray[_key]) {
            if node.rmxID == key{
                return node
            }
        }
        return nil
    }
    
    func set(node: RMXNode) {
        self.spriteArray[_key].append(node)
    }
    
    func remove(key: Int) -> RMXNode? {
        for (index, node) in enumerate(self.spriteArray[_key]) {
            if node.rmxID == key{
                self.spriteArray[_key].removeAtIndex(index)
                return node
            }
        }
        return nil
    }
    
    func plusOne(){
        if self._key + 1 > GameType.DEFAULT.rawValue {
            self._key = 0
        } else {
            self._key += 1
        }
    }
    
    func setType(type: GameType){
        self._key = type.rawValue
    }
    
    func getCurrent() ->[RMXNode]? {
        return self.current
    }
    
    func makeFirst(node: RMXNode){
        self.remove(node.rmxID)
        self.spriteArray[_key].insert(node, atIndex: 0)
    }
    init(parent p: AnyObject){
        self.parent = p
        if let parent = p as? RMSWorld {
            self.spriteArray.reserveCapacity(GameType.DEFAULT.rawValue)
            for (var i = 1; i <= GameType.DEFAULT.rawValue ; ++i){
                let dict = Array<RMXNode>()
                self.spriteArray.append(dict)
            }
        }
    }
}
*/