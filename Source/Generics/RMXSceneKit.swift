//
//  RMXSceneKit.swift
//  AiScene
//
//  Created by Max Bilbow on 08/06/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import SceneKit

typealias RendererDelegate = SCNSceneRendererDelegate

typealias AiBehaviour = (SCNNode!) -> Void
@available(OSX 10.10, *)
typealias AiCollisionBehaviour = (SCNPhysicsContact) -> Void
typealias RMSceneRenderer = SCNSceneRenderer
@available(OSX 10.10, *)
typealias RMXWorld = RMSWorld