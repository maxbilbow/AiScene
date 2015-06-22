//
//  RMXTemplates.swift
//  RMXKit
//
//  Created by Max Bilbow on 13/06/2015.
//  Copyright © 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
import SceneKit

public protocol RMXWorld {
    
//    var interface: RMXInterfaceProtocol { get }
    @objc var pawns: Array<AnyObject> { get }
    var aiOn: Bool { get }
    
    var isLive: Bool { get }
    
    
}

public protocol RMXInterfaceProtocol {
    
}