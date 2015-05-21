//
//  RMXModels.swift
//  AiScene
//
//  Created by Max Bilbow on 18/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import SpriteKit


protocol RMXModelsProtocol {
    static func getNode(shapeType type: Int, mode: RMXSpriteType, radius r: RMFloatB?, height h: RMFloatB?, scale s: RMXSize?, color: NSColor!) -> RMXNode
}


extension RMXModels {
    
    class func getImage() -> UIImage {
       return UIImage(named: "art.scnassets/2D/circle_shape.png")!
    }
    
}