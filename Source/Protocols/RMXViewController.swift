//
//  RMXViewController.swift
//  RattleGLES
//
//  Created by Max Bilbow on 26/03/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
import GLKit
import SceneKit
import RMXKit

@available(OSX 10.10, *)
extension RMX {
#if iOS
    /* static func Controller(view: GameView, world: RMXScene) -> RMXDPad {
        return RMXDPad(view: view, world: world)
    } */
    static func Controller(gvc: GameViewController) -> RMXDPad {
        return RMXDPad(gvc: gvc)//.initialize(gvc, gameView: gvc.gameView) as! RMXDPad
    }
    #elseif OSX
    static func Controller(gvc: GameViewController) -> RMSKeys {
        return RMSKeys(gvc: gvc)//.initialize(gvc, gameView: gvc.gameView) as! RMSKeys
    }
#endif
}

