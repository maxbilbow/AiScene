//
//  RMX.swift
//  AiSpritee
//
//  Created by Max Bilbow on 08/06/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
#if iOS
import UIKit
    #endif


extension RMX {
 
    #if iOS
    static func makeButton(target: NSObject, title: String? = nil, selector: String? = nil, view: UIView, row: (CGFloat, CGFloat), col: (CGFloat, CGFloat)) -> RMButton {
        let btn = RMButton(frame: getRect(withinRect: view, row: row, col: col))//(view!.bounds.width * col.0 / col.1, view!.bounds.height * row.0 / row.1, view!.bounds.width / col.1, view!.bounds.height / row.1))
        if let title = title {
            btn.setTitle(title, forState:UIControlState.Normal)
        }
        if let selector = selector {
            btn.addTarget(target, action: Selector(selector), forControlEvents:UIControlEvents.TouchDown)
        }
        
        btn.enabled = true
        view.addSubview(btn)
        return btn
    }
    #endif
    
    static func getRect(withinRect sender: Any, row: (CGFloat, CGFloat), col: (CGFloat, CGFloat)) -> CGRect {
        var bounds: CGRect!
        if sender is RMView {
            bounds = (sender as! RMView).bounds
        } else if sender is CGRect {
            bounds = sender as! CGRect
        }
        
        return CGRectMake(bounds.width * (col.0 - 1) / col.1, bounds.height * (row.0 - 1) / row.1, bounds.width / col.1, bounds.height / row.1)
    }
    
    static func randomColor() -> RMColor {
        //float rCol[4];
        var rCol = RMColor(
            red: CGFloat(random() % 10)/10,
            green: CGFloat(random() % 10)/10,
            blue: CGFloat(random() % 10)/10,
            alpha: 1.0
        )
        
        return rCol
    }
    
}