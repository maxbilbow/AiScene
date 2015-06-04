//
//  RMXDebugger.swift
//  RattleGL
//
//  Created by Max Bilbow on 15/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import SceneKit

extension RMXLog {
    static let isDebugging: Bool = false

}

extension RMX {
    
    
    static var log: [String:RMXLogEntry] = [ RMXLog.DEBUG : RMXLogEntry(sender: nil, function: __FUNCTION__, filename: (__FILE__ as String).lastPathComponent, line: "\(__LINE__)") ]
}

protocol RMXObject {
    var name: String? { get }
    var rmxID: Int? { get }
    var uniqueID: String? { get }
    var print: String { get }
    
}

class RMXLogEntry {
    var senderID, message: String?
    var function, filename: String
    var line: String
    var heading: String {
        return "BEGIN >> RMXLogEntry::\(self.filename) >> ln\(self.line) >> \(self.function)"
    }
    
    init(sender: RMXObject?, function: String, filename: String, line: String) {
        self.senderID = sender?.uniqueID
        self.filename = filename
        self.function = function
        self.line = line
    }
    
    func append(msg: AnyObject?) {
        if let string = msg?.description {
            if string.isEmpty {
                return
            }
            if self.message == nil {
                self.message = ""
            }
            self.message! += string
        }
    }
    
    var print: String? {
        if let message = self.message?.stringByReplacingOccurrencesOfString("\n", withString: "\n  -  ", options: NSStringCompareOptions.LiteralSearch) {
            let msg = message.stringByReplacingOccurrencesOfString("***", withString: "   ", options: .LiteralSearch)
            return "\(self.heading)\(msg)\nEND\n"
        } else {
            return nil //self.heading + " << END"
        }
    }
    
    func add(_ message: AnyObject? = "", sender: RMXObject? = nil, function: String = __FUNCTION__, file: String = __FILE__, line: String = "\(__LINE__)") -> Bool? {
        if let message = message?.description {
            if message.isEmpty {
                return false
            } else {
                var msg = ""
                msg += "\n\(file.lastPathComponent)/\(function)/ on line \(line):: "
               
                msg += "***\(message)"
                if let id = sender?.uniqueID {
                    msg += "*** ::ID: \(id)"
                }
                self.append(msg)
            }
        }
        return true
    }
    
}


typealias RMXDebugCallback = (AnyObject?, sender: RMXObject?, String, String, Int) -> Bool?

class RMXLog {// : NSObject {
    static let DEBUG = "DEBUG"//classForCoder().description()
    
//    #if DEBUG
    
    
    static let nul = ""
    
    static var current: Int = 0
//    #endif
    
   
//    @availability(*,unavailable)
//    static func print(_ message: AnyObject = "", sender: RMXObject? = nil, function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__) -> Bool? {
//        #if DEBUG
//        if self.isDebugging {
//            let br = "\n"
//            
//            let heading: String = "BEGIN >> \(self.classForCoder().description())::\(file.lastPathComponent) >> ln\(line) >> \(function) <-- \(sender?.uniqueID ?? nul)"
//
//            let msg = (br + message.description).stringByReplacingOccurrencesOfString("\n", withString: "\n  -  ", options: NSStringCompareOptions.LiteralSearch)
//
//            println("\(heading)\(msg)\nEND\n")
//        
//            return true
//        }
//        #endif
//        return nil
//    }
    
    
    
    
    static func flush(){
        for l in RMX.log {
            l.1.message = nil
        }
    }
    
    static func printAndFlush() {
        if let data = self.data {
            println("\n\(data)")
        }
        self.flush()
    }
    
    static var data: String? {
        #if DEBUG
            return Array(RMX.log.values)[current].print
        #else
            
        return nil
        #endif
    }

    
    
    static func next() {
        self.current++
        if self.current == RMX.log.count {
            self.current = 0
        }
    }
    
    static func previous() {
        self.current--
        if self.current < 0 {
            self.current = RMX.log.count - 1
        }
    }
    
}


func RMLog(_ message: AnyObject? = "", sender: RMXObject? = nil, id: String = RMXLog.DEBUG, function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__) -> Bool? {
    #if DEBUG
        if RMXLog.isDebugging && id == Array(RMX.log.keys)[RMXLog.current] {
            if let entry = RMX.log[id] {
                entry.add(message, sender: sender, function: "\(function)", file: "\(file)", line: "\(line)")
            } else {
                let entry = RMXLogEntry(sender: sender, function: "\(function)", filename: "\(file)".lastPathComponent, line: "\(line)")
                let key = sender?.uniqueID ?? RMXLog.DEBUG
                entry.append(message)
                RMX.log[key] = entry
                
            }
            return true
        }
    #endif
    
    return nil
}