//
//  RMXCoreExtensions.swift
//  OC to Swift oGL
//
//  Created by Max Bilbow on 17/02/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
import SceneKit

func +=(inout lhs: RMXNumber, rhs: RMXNumber) {
    lhs = (lhs.ns.doubleValue + rhs.ns.doubleValue)
}

func -=(inout lhs: RMXNumber, rhs: RMXNumber) {
    lhs = (lhs.ns.doubleValue - rhs.ns.doubleValue)
}

func *=(inout lhs: RMXNumber, rhs: RMXNumber) {
    lhs = (lhs.ns.doubleValue * rhs.ns.doubleValue)
}

func /=(inout lhs: RMXNumber, rhs: RMXNumber) {
    lhs = (lhs.ns.doubleValue / rhs.ns.doubleValue)
}


func + (lhs: RMXNumber, rhs: RMXNumber) -> RMXNumber {
    return (lhs.ns.doubleValue + rhs.ns.doubleValue)
}

func - (lhs: RMXNumber, rhs: RMXNumber) -> RMXNumber {
    return(lhs.ns.doubleValue - rhs.ns.doubleValue)
}

func * (lhs: RMXNumber, rhs: RMXNumber) -> RMXNumber {
    return (lhs.ns.doubleValue * rhs.ns.doubleValue)
}

func / (lhs: RMXNumber, rhs: RMXNumber) -> RMXNumber{
    return (lhs.ns.doubleValue / rhs.ns.doubleValue)
}




protocol RMXNumber  {
    var ns: NSNumber { get }

    
}

class RMXValue<T: Comparable> {
   // var n: NSValue = 0
    class func isNegative(n:Int) -> Bool {
        return n < 0
    }
    
    class func isNegative(n:Float) -> Bool {
        return n < 0
    }
    
    class func isNegative(n:Double) -> Bool {
        return n < 0
    }
    
    class func isNegative(n:T) -> Bool {
        return false
    }
    
    class func toData(sender:T, dp:String) -> String {
        
        
//        func isNegative(n:Double) -> Bool {
//            return n < 0.0
//        }
        //switch sender
        var s: String = ""
        if sender is Int {
            //s = isNegative(sender as Int) ? "" : " "
            s += String(format: "\(s)%\(dp)i",sender as! Int)
        } else if sender is Float {
            //s = isNegative(sender as Float) ? "" : " "
            s += String(format: "\(s)%\(dp)f",sender as! Float)
        } else if sender is CGFloat {
            //s = isNegative(sender as Float) ? "" : " "
            s += String(format: "\(s)%\(dp)f",Float(sender as! CGFloat) )
        }else if sender is Double {
            //s = isNegative(sender as Double) ? "" : " "
            s += String(format: "\(s)%\(dp)f",sender as! Double)
        } else {
            s = "ERROR: number is not Int, Foat of Double. "
        }
        return s
    }

}



extension Int : RMXNumber {
    func toData(dp:String="05") -> String {
        return RMXValue.toData(self, dp: dp)///NSString(format: "%.\(dp)f", self)
    }
    
    var print: String {
        return self.toData()
    }
    
    var ns: NSNumber {
        return NSNumber(integer: self)
    }
    
    
    
    
}

extension Float: RMXNumber {
    func toData(dp:String="05.2") -> String {
        return RMXValue.toData(self, dp: dp)///NSString(format: "%.\(dp)f", self)
    }
    
    var print: String {
        return self.toData()
    }
    
    var size: Float {
        return fabs(self)
    }
    
    var ns: NSNumber {
        return NSNumber(float: self)
    }
}
extension Double: RMXNumber {
    func toData(dp:String="05.2") -> String {
        return RMXValue.toData(self, dp: dp)
    }
    
    var print: String {
        return self.toData()
    }
    
    var ns: NSNumber {
        return NSNumber(double: self)
    }
}

extension CGFloat: RMXNumber {
    func toData(dp:String="05.2") -> String {
        return RMXValue.toData(self, dp: dp)
    }
    
    var print: String {
        return self.toData()
    }
    
    var ns: NSNumber {
        return NSNumber(double: Double(self))
    }
}

extension GLKVector3 {
    var print: String {
        return "\(x.toData()) \(y.toData()) \(z.toData())"
    }
    
    func negate() -> GLKVector3{
        return GLKVector3Negate(self)
    }
    
    func distanceTo(v: GLKVector3) -> Float{
        return GLKVector3Distance(self, v)
    }
}

extension SCNVector3 {
    var print: String {
        return "\(x.toData()) \(y.toData()) \(z.toData())"
    }
    
    var normalised: SCNVector3 {
        return RMXVector3Normalize(self)
    }
    
    var asDegrees: String {
        let pitch   = x / PI_OVER_180
        let yaw     = y / PI_OVER_180
        let roll    = z / PI_OVER_180
        return "\(pitch.toData()) \(yaw.toData()) \(roll.toData())"
    }
    
    func negate() -> SCNVector3{
        return SCNVector3Make(-x,-y,-z)
    }
    
    func distanceTo(v: SCNVector3) -> RMFloatB{
        let A = SCNVector3ToGLKVector3(self); let B = SCNVector3ToGLKVector3(v)
        return RMFloatB(GLKVector3Distance(A,B))
        //return RMXVector3Distance(self, v)
    }
    
    var length: Float {
        return Float(self.distanceTo(SCNVector3Zero))
    }
    
    var velocity: Float {
        return (self.sum > 0 ? 1 : -1) * self.length
    }
    
    var sum: RMFloatB {
        return x + y + z
    }
    
    var average: RMFloatB {
        return self.sum / 3
    }
}

extension GLKVector4 {
    var print: String {
        return "\(x.toData()) \(y.toData()) \(z.toData()) \(w.toData())"
    }
    
    func negate() -> GLKVector4{
        return GLKVector4Negate(self)
    }
    
    func distanceTo(v: GLKVector4) -> Float{
        return GLKVector4Distance(self, v)
    }
}

extension GLKQuaternion {
    var print: String {
        return "\(x.toData()) \(y.toData()) \(z.toData()) \(w.toData()) V: \(v.print)"
    }
}


extension SCNVector4 {
    var print: String {
        return "\(x.toData()) \(y.toData()) \(z.toData()) \(w.toData())"
    }
    
    func negate() -> SCNVector4{
        return SCNVector4Make(-x,-y,-z,-w)
    }
    
    func distanceTo(v: SCNVector4) -> CGFloat{
        return CGFloat(GLKVector4Distance(SCNVector4ToGLKVector4(self), SCNVector4ToGLKVector4(v)))
    }
}


extension SCNMatrix4 : RMXLocatable {
    var print: String {
        let row1 = "   ROW1: \(m11.toData()) \(m12.toData()) \(m13.toData()) \(m14.toData())"
        let row2 = "   ROW2: \(m21.toData()) \(m22.toData()) \(m23.toData()) \(m24.toData())"
        let row3 = "   ROW3: \(m31.toData()) \(m32.toData()) \(m33.toData()) \(m34.toData())"
        let row4 = "   ROW4: \(m41.toData()) \(m42.toData()) \(m43.toData()) \(m44.toData())"
        return "\(row1)\n\(row2)\n\(row3)\n\(row4)\n"
    }
    
    var up: SCNVector3 {
        return SCNVector3Make(m21, m22, m23)
    }
    
    var left: SCNVector3 {
        return SCNVector3Make(-m11, -m12, -m13)
    }
    
    var forward: SCNVector3 {
        return SCNVector3Make(-m31, -m32, -m33)
    }
    
    var position: SCNVector3 {
        return SCNVector3Make(m41, m42, m43)
    }
    
    func getPosition() -> SCNVector3 {
        return self.position
    }
    
    func leftTo(position: SCNVector3) -> SCNVector3 {
//        let mat = RMXMatrix4Make(self.left, self.up, self.forward, row4: self.position - position)
        return self.left * (self.position - position)
    }
}


extension GLKMatrix4 {
    var print: String {
        let row1 = "   ROW1: \(m00.toData()) \(m01.toData()) \(m02.toData()) \(m03.toData())"
        let row2 = "   ROW2: \(m10.toData()) \(m11.toData()) \(m12.toData()) \(m13.toData())"
        let row3 = "   ROW3: \(m20.toData()) \(m21.toData()) \(m22.toData()) \(m23.toData())"
        let row4 = "   ROW4: \(m30.toData()) \(m31.toData()) \(m32.toData()) \(m33.toData())"
        return "\(row1)\n\(row2)\n\(row3)\n\(row4)\n"
    }
}


extension CGVector {
    var print: String {
        return "\(dx.toData()) \(dy.toData())"
    }
    
    var x: Float {
        return Float(dx)
    }
    
    var y: Float {
        return Float(dy)
    }
}


extension SCNQuaternion {
    var up: CGVector  {
        return CGVector(dx: RMFloat(x * sin(w)), dy: RMFloat(y * cos(w)))
    }
    
    var left: CGVector {
        return CGVector(dx: 0, dy: 0)
    }
    
    var forward: CGVector {
        return CGVector(dx: RMFloat(x * cos(w)), dy: RMFloat(y * sin(w)))
    }

}


extension CGSize {
    var average: CGFloat {
        return (width + height) / 2
    }
}

extension CGPoint {
    var print: String {
        return "\(x.toData()) \(y.toData())"
    }
    
}
