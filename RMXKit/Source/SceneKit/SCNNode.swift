//
//  SCNNode.swift
//  AiScene
//
//  Created by Max Bilbow on 13/06/2015.
//  Copyright © 2015 Rattle Media. All rights reserved.
//

import Foundation
import SceneKit

extension SCNNode : RMXLocatable  {
    
//    public var uniqueID: String? {
//        let parentID = self.parentNode?.uniqueID ?? ""
//        return "\(parentID)/\(self.name ?? self.description)"
//    }
    
//    public var print: String {
//        return self.uniqueID!
//    }
    
    public func getPosition() -> SCNVector3 {
        return self.presentationNode().position
    }

    var pawn: RMXPawn? {
        return self as? RMXPawn ?? self.parentNode?.pawn
    }
    
}