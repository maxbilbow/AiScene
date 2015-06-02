//
//  RMXModels.swift
//  AiScene
//
//  Created by Max Bilbow on 18/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import SceneKit
//import AppKit



enum ShapeType: Int { case CUBE , SPHERE, CYLINDER,  OILDRUM, BOBBLE_MAN, LAST,ROCK,SPACE_SHIP, PILOT,  PLANE, FLOOR, DOG, AUSFB,PONGO, NULL, SUN, CAMERA }


protocol RMXModelsProtocol {
    static func getNode(shapeType type: ShapeType, mode: RMXSpriteType, radius r: RMFloatB?, height h: RMFloatB?, scale s: RMXSize?, color: NSColor!) -> SCNNode
}


