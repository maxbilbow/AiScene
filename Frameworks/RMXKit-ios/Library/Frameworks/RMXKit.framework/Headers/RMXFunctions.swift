//
//  RMX.swift
//  AiSpritee
//
//  Created by Max Bilbow on 08/06/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import SpriteKit
    
@available(OSX 10.10, *)
extension RMX {
 
    
    public static func getRect(withinRect sender: Any, row: (CGFloat, CGFloat), col: (CGFloat, CGFloat)) -> CGRect {
        var bounds: CGRect!
        if sender is RMView {
            bounds = (sender as! RMView).bounds
        } else if sender is CGRect {
            bounds = sender as! CGRect
        }
        
        return CGRectMake(bounds.width * (col.0 - 1) / col.1, bounds.height * (row.0 - 1) / row.1, bounds.width / col.1, bounds.height / row.1)
    }
    
    public static func randomColor() -> RMColor {
        //float rCol[4];
        let rCol = RMColor(
            red: CGFloat(random() % 10)/10,
            green: CGFloat(random() % 10)/10,
            blue: CGFloat(random() % 10)/10,
            alpha: 1.0
        )
        
        return rCol
    }
    
}