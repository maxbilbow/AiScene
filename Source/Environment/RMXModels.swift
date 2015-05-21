//
//  RMXModels.swift
//  AiScene
//
//  Created by Max Bilbow on 18/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import SpriteKit
import AppKit


protocol RMXModelsProtocol {
    static func getNode(shapeType type: Int, mode: RMXSpriteType, radius r: RMFloatB?, height h: RMFloatB?, scale s: RMXSize?, color: NSColor!) -> RMXNode
}


