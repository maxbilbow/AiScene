//
//  iOS.swift
//  RMXKit
//
//  Created by Max Bilbow on 13/06/2015.
//  Copyright © 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

public typealias RMFloat = Float
public typealias RMButton = UIButton
public typealias RMView = UIView
public typealias RMColor = UIColor
public typealias RMDataView = UITextView
public typealias RMLabel = UIButton

public func * (lhs: SCNVector3, rhs: CGFloat) -> SCNVector3 {
    return lhs * Float(rhs)
}


public extension RMX {
    
    public static func makeButton(target: NSObject, title: String? = nil, selector: String? = nil, view: UIView, row: (CGFloat, CGFloat), col: (CGFloat, CGFloat)) -> RMButton {
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
}