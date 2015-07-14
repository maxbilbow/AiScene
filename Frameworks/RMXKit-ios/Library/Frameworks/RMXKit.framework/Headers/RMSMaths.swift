//
//  RMSMaths.swift
//  RattleGL
//
//  Created by Max Bilbow on 13/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation

import GLKit
import SceneKit

public let SCNMatrix4Zero = SCNMatrix4MakeScale(0,0,0)
public let GLKVector3Zero = GLKVector3Make(0,0,0)
public let GLKVector4Zero = GLKVector4Make(0,0,0,0)
public let CGVectorZero = CGVector(dx: 0,dy: 0)

public func SCNVector3Make(x:RMFloat, y:RMFloat, z:RMFloat) -> SCNVector3 {
   return SCNVector3Make(x,y,z)
}

public func SCNVector3Make(n: RMFloat) -> SCNVector3 {
    return SCNVector3Make(n,y: n,z: n)
}

public func RMXVector2Make(n: CGFloat) -> CGVector {
    return CGVector(dx: n, dy: n)
}

public func SCNVector3Length(v: SCNVector3) -> RMFloat {
    return RMFloat(GLKVector3Length(SCNVector3ToGLKVector3(v)))
}


@available(OSX 10.10, *)
public func SCNMatrix4Transpose(mat: SCNMatrix4)->SCNMatrix4 {
    return SCNMatrix4FromGLKMatrix4(GLKMatrix4Transpose(SCNMatrix4ToGLKMatrix4(mat)))
}

@available(OSX 10.10, *)
public func SCNMatrix4Make(row1: SCNVector3, row2: SCNVector3, row3: SCNVector3, row4: SCNVector3 = SCNVector3Zero) -> SCNMatrix4 {
        return SCNMatrix4(
            m11: row1.x, m12: row1.y, m13: row1.z, m14: 0,
            m21: row2.x, m22: row2.y, m23: row2.z, m24: 0,
            m31: row3.x, m32: row3.y, m33: row3.z, m34: 0,
            m41: row4.x, m42: row4.y, m43: row4.z, m44: 1
            )
}

public func GLKMatrix4Make(row1: GLKVector3, row2: GLKVector3, row3: GLKVector3, row4: GLKVector3 = GLKVector3Zero) -> GLKMatrix4 {
    return GLKMatrix4MakeWithColumns(
        GLKVector4MakeWithVector3(row1, 0),
        GLKVector4MakeWithVector3(row2, 0),
        GLKVector4MakeWithVector3(row3, 0),
        GLKVector4MakeWithVector3(row4, 1)
    )

}

@available(OSX 10.10,*)
public func SCNMatrix4MultiplyVector3(mat: SCNMatrix4, v: SCNVector3) -> SCNVector3{
        return SCNVector3FromGLKVector3(GLKMatrix4MultiplyVector3(GLKMatrix4Transpose(SCNMatrix4ToGLKMatrix4(mat)),SCNVector3ToGLKVector3(v)))
}

public func SCNVector3Divide(n:SCNVector3, d: SCNVector3) -> SCNVector3 {
    return SCNVector3FromGLKVector3(GLKVector3Divide(SCNVector3ToGLKVector3(n),SCNVector3ToGLKVector3(d)))
}

public func + (lhs: SCNVector3, rhs: SCNVector3)->SCNVector3{
    return SCNVector3Make(
        lhs.x + rhs.x,
        lhs.y + rhs.y,
        lhs.z + rhs.z
    )
}

public func - (lhs: SCNVector3, rhs: SCNVector3)->SCNVector3{
    return SCNVector3Make(
        lhs.x - rhs.x,
        lhs.y - rhs.y,
        lhs.z - rhs.z
    )
}


public func + (lhs: GLKVector3, rhs: Float)->GLKVector3{
    return GLKVector3AddScalar(lhs, rhs)
}

public func + (lhs: GLKVector3, rhs: GLKVector3)->GLKVector3{
    return GLKVector3Add(lhs, rhs)
}

public func + (lhs: GLKVector3, rhs: SCNVector3)->SCNVector3{
    return SCNVector3FromGLKVector3(lhs) + rhs
}

public func + (lhs: SCNVector3, rhs: GLKVector3)->SCNVector3 {
    return lhs + SCNVector3FromGLKVector3(rhs)
}

public func - (lhs: GLKVector3, rhs: GLKVector3) -> GLKVector3 {
    return GLKVector3Subtract(lhs, rhs)
}
public func += (inout lhs: GLKVector3, rhs: GLKVector3) {
    lhs = GLKVector3Add(lhs, rhs)
}

public func += (inout lhs: GLKVector3, rhs: SCNVector3) {
    lhs = GLKVector3Add(lhs, SCNVector3ToGLKVector3(rhs))
}

public func += (inout lhs: SCNVector3, rhs: GLKVector3) {
    lhs.x += RMFloat(rhs.x)
    lhs.y += RMFloat(rhs.y)
    lhs.z += RMFloat(rhs.z)
}

public func += (inout lhs: SCNVector3, rhs: SCNVector3) {
        lhs.x += rhs.x
        lhs.y += rhs.y
        lhs.z += rhs.z
}

public func * (lhs: SCNVector3, rhs: RMFloat) -> SCNVector3 {
    return SCNVector3MultiplyScalar(lhs, s: rhs)
}

public func *= (inout lhs: SCNVector3, rhs: RMFloat) {
    lhs = SCNVector3MultiplyScalar(lhs, s: rhs)
}

public func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

public func * (lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
    return SCNVector3FromGLKVector3(GLKVector3Multiply(SCNVector3ToGLKVector3(lhs), SCNVector3ToGLKVector3(rhs)))
}

public func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
}

public func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
}


public func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
    return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
}

public func * (lhs: CGPoint, rhs: CGSize) -> CGPoint {
    return CGPoint(x: lhs.x * rhs.width, y: lhs.y * rhs.height)
}

public func + (lhs: CGSize, rhs: CGSize) -> CGSize {
    return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
}

public func + (lhs: CGPoint, rhs: CGSize) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
}

public func *= (inout lhs: SCNVector3, rhs: SCNVector3) {
    lhs = lhs * rhs
}

public func * (lhs: GLKVector3, rhs: GLKVector3) -> GLKVector3 {
    return GLKVector3Multiply(lhs, rhs)
}

///Dot Product
public func o (lhs: GLKVector3, rhs: GLKVector3) -> Float {
    return GLKVector3DotProduct(lhs, rhs)
}


public func + (lhs: GLKMatrix4, rhs: GLKMatrix4) -> GLKMatrix4 {
    return GLKMatrix4Add(lhs,rhs)
}

@available(OSX 10.10,*)
public func + (lhs: SCNMatrix4, rhs: SCNMatrix4) -> SCNMatrix4 {
    return SCNMatrix4FromGLKMatrix4(GLKMatrix4Add(SCNMatrix4ToGLKMatrix4(lhs),SCNMatrix4ToGLKMatrix4(rhs)))
}

public func * (lhs:GLKMatrix4, rhs:GLKMatrix4) -> GLKMatrix4 {
    return GLKMatrix4Multiply(lhs, rhs)
}

@available(OSX 10.10,*)
public func * (lhs:SCNMatrix4, rhs:SCNMatrix4) -> SCNMatrix4 {
    return SCNMatrix4Mult(lhs,rhs)
}

public func *= (inout lhs:GLKMatrix4, rhs:GLKMatrix4) {
    lhs = GLKMatrix4Multiply(rhs, lhs)
}

@available(OSX 10.10,*)
public func *= (inout lhs:SCNMatrix4, rhs:SCNMatrix4) {
    lhs = SCNMatrix4Mult(rhs,lhs)
}

public func * (lhs: CGVector, rhs: CGFloat) -> CGVector {
    return CGVector(dx: lhs.dx * rhs, dy: lhs.dy * rhs)
}

public func * (lhs: CGVector, rhs: Float) -> CGVector {
    return CGVector(dx: lhs.dx * CGFloat(rhs), dy: lhs.dy * CGFloat(rhs))
}

public func - (lhs: CGPoint, rhs: CGVector) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.dx, y: lhs.y - rhs.dy)
}

public func + (lhs: CGPoint, rhs: CGVector) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy)
}

public func <= (lhs: CGFloat, rhs: Float) -> Bool {
    return Float(lhs) <= rhs
}

public func * (lhs: CGVector, rhs: CGVector) -> CGVector {
    return CGVector(dx: lhs.dx * rhs.dx, dy: lhs.dy * rhs.dy)
}



public func + (lhs: CGVector, rhs: CGVector) -> CGVector {
    return CGVector(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
}


public func SCNVector3Normalize(vector: SCNVector3) -> SCNVector3 {
    return SCNVector3FromGLKVector3(GLKVector3Normalize(SCNVector3ToGLKVector3(vector)))
}

public func SCNVector3Distance(a:SCNVector3,b:SCNVector3)->RMFloat {
    #if true
        let A = SCNVector3ToGLKVector3(a); let B = SCNVector3ToGLKVector3(b)
        return RMFloat(GLKVector3Distance(A,B))
        #else
        return GLKVector3Distance(a,b)
    #endif
}
@available(OSX 10.10,*)
public func SCNMatrix4RotateY(matrix: SCNMatrix4, theta: RMFloat) -> SCNMatrix4 {
    return SCNMatrix4Rotate(matrix, angle: theta,x: 0,y: 1,z: 0)
}

@available(OSX 10.10,*)
public func SCNMatrix4Rotate(mat: SCNMatrix4, angle: RMFloat, x: RMFloat, y: RMFloat, z: RMFloat)-> SCNMatrix4{
    return SCNMatrix4Rotate(mat, angle, x, y, z)
}

@available(OSX 10.10,*)
public func SCNMatrix4MakeRotation(radians: RMFloat,v: SCNVector3) -> SCNMatrix4 {
    return SCNMatrix4MakeRotation(radians, v.x,v.y,v.z)
}

@available(OSX 10.10,*)
public func SCNMatrix4RotateWithVector3(mat: SCNMatrix4, angle: RMFloat, vector: SCNVector3) -> SCNMatrix4{
    return SCNMatrix4Rotate(mat, angle, vector.x, vector.y, vector.z)
}

public func SCNMatrix4Translate(mat: SCNMatrix4, v: SCNVector3)-> SCNMatrix4 {
    return SCNMatrix4Translate(mat, v.x, v.y, v.z)
}

@available(OSX 10.10,*)
public func SCNMatrix4Normalize(mat: SCNMatrix4) -> SCNMatrix4{
    let mat = GLKMatrix4MakeWithRows(
        GLKVector4Normalize(GLKVector4Make(Float(mat.m11),Float(mat.m12),Float(mat.m13),Float(mat.m14))),
        GLKVector4Normalize(GLKVector4Make(Float(mat.m21),Float(mat.m22),Float(mat.m23),Float(mat.m24))),
        GLKVector4Normalize(GLKVector4Make(Float(mat.m31),Float(mat.m32),Float(mat.m33),Float(mat.m34))),
        GLKVector4Zero
    )
    return SCNMatrix4FromGLKMatrix4(mat)
}

public func SCNVector3MakeNormal(x:RMFloat,y:RMFloat,z:RMFloat) -> SCNVector3 {
    var v = SCNVector3Make(x,y: y,z: z)
        v = SCNVector3FromGLKVector3(GLKVector3Normalize(SCNVector3ToGLKVector3(v)))
    return v
}
public func SCNMatrix4SetPosition(m4:SCNMatrix4, v3 row: SCNVector3) -> SCNMatrix4{
    return SCNMatrix4SetPosition(m4, v4: SCNVector4Make(row.x, row.y, row.z, 0))
}

public func RMXSetOrientation(m1:SCNMatrix4, orientation m4: SCNMatrix4) -> SCNMatrix4 {
    #if true
        return SCNMatrix4(
        m11: m4.m11, m12: m4.m12, m13: m4.m13, m14: m4.m14,
        m21: m4.m21, m22: m4.m22, m23: m4.m23, m24: m4.m24,
        m31: m4.m31, m32: m4.m32, m33: m4.m33, m34: m4.m34,
        m41: m1.m41, m42: m1.m42, m43: m1.m43, m44: m1.m44
        )
        #else
        return GLKMatrix4Make(
            m4.m00, m4.m01, m4.m02, m4.m03,
            m4.m10, m4.m11, m4.m12, m4.m13,
            m4.m20, m4.m21, m4.m22, m4.m23,
            m1.m31, m1.m31, m1.m32, m1.m33
        )
    #endif
}
public func SCNMatrix4SetPosition(m4:SCNMatrix4, v4 row: SCNVector4) -> SCNMatrix4{
    #if true
    return SCNMatrix4(
        m11: m4.m11, m12: m4.m12, m13: m4.m13, m14: m4.m14,
        m21: m4.m21, m22: m4.m22, m23: m4.m23, m24: m4.m24,
        m31: m4.m31, m32: m4.m32, m33: m4.m33, m34: m4.m34,
        m41: row.x,  m42: row.y,  m43: row.z,  m44: row.w
        )
    #else
    return GLKMatrix4Make(
        m4.m00, m4.m01, m4.m02, m4.m03,
        m4.m10, m4.m11, m4.m12, m4.m13,
        m4.m20, m4.m21, m4.m22, m4.m23,
        row.x,  row.y,  row.z,  row.w
        )
    #endif
}


public func RMXGetTheta(vectorA A: GLKVector2, vectorB B: GLKVector2) -> RMFloat{
    let delta = GLKVector2Subtract(B, A)
    let r: Float = GLKVector2Length(delta)
    let alpha: Float = asinf(delta.x/r)
    let beta: Float = acosf(delta.y/r)
//    let theta: Float = GLKMathRadiansToDegrees(atanf(delta.x/delta.y))
    let result = alpha * beta >= 0 ? beta : TWO_PIf - beta
    return RMFloat(alpha.isNaN ? 0 : result)
}

public func RMXGetPhi(vectorA A: GLKVector2, vectorB B: GLKVector2) -> RMFloat{
    let delta = GLKVector2Subtract(B, A)
    let r: Float = GLKVector2Length(delta)
    let alpha: Float = asinf(delta.x/r)
    let result = alpha //alpha * beta >= 0 ? beta : TWO_PI - beta
    return RMFloat(alpha.isNaN ? 0 : result)
}

public func RMXGetTheta(vectorA U: SCNVector3, vectorB V: SCNVector3) -> RMFloat{
    let A = GLKVector2Make(Float(U.x), Float(U.z)); let B = GLKVector2Make(Float(V.x), Float(V.z))
    return RMXGetTheta(vectorA: A,vectorB: B)
}



public func RMXGetPhi(vectorA U: GLKVector3, vectorB V: GLKVector3) -> RMFloat{
    let A = GLKVector2Make(U.z, U.y); let B = GLKVector2Make(V.z, V.y)
    return RMXGetPhi(vectorA: A,vectorB: B)
}

public func x (lhs: GLKVector3, rhs: GLKVector3) -> GLKVector3 {
    return GLKVector3CrossProduct(lhs, rhs)
}

public func SCNVector4MakeWithVector3(v: SCNVector3, w: RMFloat) -> SCNVector4{
    return SCNVector4Make(v.x,v.y,v.z,w)
}

public func == (lhs: SCNVector3, rhs: SCNVector3) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
}

public func != (lhs: SCNVector3, rhs: SCNVector3) -> Bool {
    return lhs.x != rhs.x || lhs.y != rhs.y || lhs.z != rhs.z
}


public func SCNVector3MultiplyScalar(v: SCNVector3, s: RMFloat) -> SCNVector3{
    return SCNVector3Make(
        v.x * s,
        v.y * s,
        v.z * s
    )
}



public func SCNVector3Random(max: CGFloat, min: CGFloat, div: CGFloat = 1, setY: CGFloat?) -> SCNVector3 {
    return SCNVector3Random(Double(max), min: Double(min), div: Double(div), setY: setY != nil ? Double(setY!) : nil)
}

public func SCNVector3Random(max: Float, min: Float, div: Float = 1, setY: Float?) -> SCNVector3 {
    return SCNVector3Random(Double(max), min: Double(min), div: Double(div), setY: setY != nil ? Double(setY!) : nil)
}

public func SCNVector3Random(max: Double, min: Double, div: Double = 1, setY: Double?) -> SCNVector3 {
    return SCNVector3Random(Int(max), min: Int(min), div: Int(div), setY: setY != nil ? Int(setY!) : nil )
}

public func SCNVector3Random(max: Int, min: Int, div: Int = 1, setY: Int?) -> SCNVector3 {

    
    return SCNVector3Make(
        RMFloat(((random() % (2 * max)) + min) / div),
        RMFloat(setY ?? ((random() % (2 * max)) - min) / div),
        RMFloat(((random() % (2 * max)) + min) / div)
    )
    
}




