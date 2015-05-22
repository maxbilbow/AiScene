//
//  RMXDebugger.swift
//  RattleGL
//
//  Created by Max Bilbow on 15/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import SceneKit

public class RMXDebugger  {
    

}
extension RMX {
    static var isDebugging: Bool { return false }
}

public func RMXLog(_ message: AnyObject? = "", sender: AnyObject = __FUNCTION__, file: AnyObject = __FILE__){
    if RMX.isDebugging{
        let msg: AnyObject? = message ?? ""
        println("\(file.lastPathComponent)::\(sender): \(msg)")
    }
}

var textStorage: NSTextStorage = NSTextStorage()
/*

public func RMXPrintToScreen(string: AnyObject! = nil, window: RMDataView?) {
//    textStorage.setAttributedString(NSAttributedString) = string
    if let view: RMDataView = window {
        NSLog(string.description)
        let text = NSTextContainer()
//        text.string
        view.string = string.description
        NSLog(view.string!)
    } else {
        NSLog("hello")
    }
}

*/