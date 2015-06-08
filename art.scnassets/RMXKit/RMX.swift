//
//  RMX.swift
//  RattleGL
//
//  Created by Max Bilbow on 17/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation

enum PoppyState: Int32 { case IDLE = 1, READY_TO_CHASE , CHASING, FETCHING }
enum RMXSpriteType: Int { case  AI = 0, PLAYER, BACKGROUND, PASSIVE, ABSTRACT, KINEMATIC, CAMERA }


public struct RMX {

    static var COUNT: Int = 0
}


protocol RMXObject {
    var name: String? { get }
    var rmxID: Int? { get }
    var uniqueID: String? { get }
    var print: String { get }
    
}



#if iOS
    import UIKit
    typealias RMButton = UIButton
    typealias RMView = UIView
#elseif OSX
    import AppKit
    typealias RMButton = NSButton
    typealias RMView = NSView
#endif

