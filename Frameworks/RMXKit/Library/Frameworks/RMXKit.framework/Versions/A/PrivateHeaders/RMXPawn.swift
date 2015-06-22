//
//  RMXSprite.swift
//  AiSpritee
//
//  Created by Max Bilbow on 08/06/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation

public protocol RMXPawn : RMXObject, NSObjectProtocol {
    var world: RMXWorld { get }
//    var timer: RMXTimer? { get }
    var aiDelegate: RMXAiDelegate? { get }
    var type: RMXSpriteType { get }
    var logic: Array<AiBehaviour> { get }
    var isUnique: Bool { get }
    var isLocalPlayer: Bool { get }
    var isActor: Bool { get }
    
//    func grabItem(object: AnyObject?) -> Bool
//    func throwItem(at object: AnyObject?, withForce strength: RMFloat, tracking: Bool) -> Bool
//    func releaseItem()
    func validate()
}

public protocol RMXTimer : NSObjectProtocol {
    
    func activate(node: AnyObject!) -> Void 
    func validate()
    func addTimer(interval: NSTimeInterval, target: AnyObject, selector: Selector, userInfo: AnyObject?, repeats: Bool)
}



public class RMXAttributes : NSObject , NSCoding {
    public var values: Dictionary<String,String> = [
        RMKeyValue.name   : "",
        RMKeyValue.Health : "100",
        RMKeyValue.Points : "0",
        RMKeyValue.Kills  : "0",
        RMKeyValue.Deaths : "0"
    ]
    
    
    public var keys: [String] {
        return self.values.keys.array
    }
    
    
    public override init() {
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init()
        for value in aDecoder.dictionaryWithValuesForKeys(self.keys) {
            self.values[value.0] = String(value.1)
        }
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        
    }
}