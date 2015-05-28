//
//  RMXNode.swift
//  RattleGL3-0
//
//  Created by Max Bilbow on 10/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//
import GLKit
import Foundation

import SceneKit
import SpriteKit

#if SceneKit
    
    typealias RMXNode = SCNNode
    #elseif SpriteKit
    
    typealias RMXNode = SKNode
#endif

protocol RMXChildNode {
    var node: RMXNode { get set }
    var parentNode: RMXNode? { get }
    var parentSprite: RMXSprite? { get set }
}


#if SceneKit
extension RMXSprite {

    var transform: RMXMatrix4 {
        return self.node.presentationNode().transform
    }
    
    var position: RMXVector3 {
        return self.node.presentationNode().position
    }

    
    func presentationNode() -> RMXNode {
        return self.node.presentationNode()
    }
    var geometry: SCNGeometry? {
        return self.node.geometry
    }
    
    var physicsBody: SCNPhysicsBody? {
        return self.node.physicsBody
    }
    
    var physicsField: SCNPhysicsField? {
        return self.node.physicsField
    }
    
    
    func applyForce(direction: SCNVector3, atPosition: SCNVector3? = nil, impulse: Bool = false) {
        if let atPosition = atPosition {
            self.node.physicsBody?.applyForce(direction, atPosition: atPosition, impulse: impulse)
        } else {
            self.node.physicsBody?.applyForce(direction, impulse: impulse)
        }
    }
    
    func resetTransform() {
        self.node.physicsBody?.resetTransform()
    }
    func setAngle(yaw: RMFloatB? = nil, pitch: RMFloatB? = nil, roll r: RMFloatB? = nil) {
        //        self.node.eulerAngles = self.getNode().eulerAngles
        //        self.node.eulerAngles = self.getNode().eulerAngles
        self.setPosition(resetTransform: false)
        if let theta = yaw {
            self.node.orientation.y = 0
        }
        if let phi = pitch {
            self.node.orientation.x = 0
        }
        if let roll = r {
            self.node.orientation.z = 0
        }
        self.resetTransform()
        
    }
    
    func lookAround(theta t: RMFloatB? = nil, phi p: RMFloatB? = nil, roll r: RMFloatB? = nil) {
        
        if let theta = t {
            let axis = self.transform.up
            let speed = self.rotationSpeed * theta
            self.node.physicsBody!.applyTorque(SCNVector4Make(axis.x,axis.y,axis.z, -speed), impulse: false)
        }
        if let phi = p {
            let axis = self.transform.left
            let speed = self.rotationSpeed * phi
            self.node.physicsBody!.applyTorque(SCNVector4Make(axis.x,axis.y,axis.z, speed), impulse: false)
        }
        if let roll = r {
            let axis = self.transform.forward
            let speed = self.rotationSpeed * roll
            self.node.physicsBody!.applyTorque(SCNVector4Make(axis.x,axis.y,axis.z, -speed), impulse: false)
            //            self.node.transform *= RMXMatrix4MakeRotation(speed * 0.0001, RMXVector3Make(0,0,1))
        }
        
    }
    var orientation: RMXVector4 {
        return self.node.presentationNode().orientation
    }
    
    func accelerateForward(v: RMFloatB) {
        let vector = self.usesWorldCoordinates ? self.world!.forwardVector : self.forwardVector
        let force = vector * v * self.speed
        let point =  self.usesWorldCoordinates ? self.front : RMXVector3Zero
        self.applyForce(force, atPosition: point)
    }
    
    func accelerateUp(v: RMFloatB) {
        let vector = self.usesWorldCoordinates ? self.world!.upVector : self.upVector
        let force = vector * v * self.speed
        let point =  self.usesWorldCoordinates ? self.front : RMXVector3Zero
        self.applyForce(force, atPosition: point)
    }
    
    
    func accelerateLeft(v: RMFloatB) {
        let vector = self.usesWorldCoordinates ? self.world!.leftVector : self.leftVector
        let force = vector * v * self.speed
        let point =  self.usesWorldCoordinates ? self.front : RMXVector3Zero
        self.applyForce(force, atPosition: point)
    }
    
    
    func completeStop(){
        self.stop()
        self.node.physicsBody!.velocity = RMXVector3Zero
    }
    
    
    ///Stops all acceleration foces, not velocity
    func stop(){
        self.node.physicsBody!.clearAllForces()
//        self.acceleration = nil
    }
    
    var scale: RMXVector3 {
        return self.node.presentationNode().scale
    }
    
    func setRadius(radius: RMFloatB){
        let s = radius * 2
        self.node.scale = RMXVectorMake(s)
    }
    
    var weight: Float {
        return Float(self.node.physicsBody!.mass) * self.world!.gravity.length
    }
    
    func distanceTo(point: RMXVector3 = RMXVector3Zero) -> RMFloatB{
        return RMXVector3Distance(self.position, point)
    }
    
    func distanceTo(object:RMXSprite) -> RMFloatB{
        return RMXVector3Distance(self.position,object.position)
    }
    
    var velocity: RMXVector {
        if let body = self.physicsBody {
            return body.velocity //body.velocity
        } else {
            return RMXVector3Zero
        }
    }
    
    func setPosition(position: RMXVector3? = nil, resetTransform: Bool = true){
        self.node.transform = self.transform
        if let position = position {
            self.node.position = position
        }
        //        self.node.orientation = self.getNode().orientation
        //        self.node.scale = self.getNode().scale
        
        if resetTransform {
            self.node.physicsBody?.resetTransform()
        }
    }

    class func rootNode(node: RMXNode, rootNode: RMXNode) -> RMXNode {
        if node.parentNode == rootNode || node.parentNode == nil {
            RMXLog("RootNode: \(node.name)")
            return node
        } else {
            RMXLog(node.parentNode)
            return self.rootNode(node.parentNode!, rootNode: rootNode)
        }
    }
    
}
    
    
    
    
    #elseif SpriteKit
    extension SKNode {
        func presentationNode() -> SKNode {
            return self
        }
        
        var scale: RMXSize {
            return RMXSize(width: self.xScale, height: self.yScale)
        }
        
        var parentNode: SKNode? {
            return self.parent
        }
        
        var geometry: AnyObject? {
            return nil
        }
    }
    
    extension RMXSprite {
        
        var transform: RMXTransform {
            return SCNVector4Make(RMFloatB(self.node.position.x), RMFloatB(self.node.position.y), RMFloatB(self.node.zPosition), RMFloatB(self.node.zRotation))
        }
        
        var position: RMXPoint {
            return self.node.position
        }

        
        func getNode() -> SKNode {
            return self.node
        }
        var geometry: CGRect? {
            return self.node.frame
        }
        
        var physicsBody: SKPhysicsBody? {
            return self.node.physicsBody
        }
        
        var physicsField: AnyObject? {
            return nil
        }
        
        
        func applyForce(direction: RMXVector, atPosition: RMXPoint? = nil, impulse: Bool = false) {
            let dir = CGVector(dx: CGFloat(direction.x), dy: CGFloat(direction.y))
            if let atPosition = atPosition {
                let pos = CGPoint(x: CGFloat(atPosition.x), y: CGFloat(atPosition.y))
                self.node.physicsBody?.applyForce(dir, atPoint: pos)
            } else {
                self.node.physicsBody?.applyForce(dir)
            }
        }
        
        func applyForce(impulse: RMXVector, atPoint: RMXPoint? = nil) {
            if let atPoint = atPoint {
                self.node.physicsBody?.applyForce(impulse, atPoint: atPoint)
            } else {
                self.node.physicsBody?.applyForce(impulse)
            }
        }

        func resetTransform() {
            RMXLog("self.node.physicsBody?.resetTransform()")
        }
        
        func setAngle(yaw: RMFloatB? = nil, pitch: RMFloatB? = nil, roll r: RMFloatB? = nil) {
            RMXLog("yaw \(yaw), pitch \(pitch), roll \(roll)")
            self.resetTransform()
            
        }
        
        func lookAround(theta t: RMFloatB? = nil, phi p: RMFloatB? = nil, roll r: RMFloatB? = nil) {
            
            if let theta = t {
                let axis = self.upVector
                let speed = self.rotationSpeed * theta
                self.node.physicsBody!.applyTorque(RMFloat(-speed))
            }
        }
        
        var orientation: RMXQuaternion {
            return self.node.zRotation
        }
        
        func accelerateForward(v: RMFloatB) {
            let force = self.forwardVector * -v * self.speed
            //RMXLog("\n Force:\(force.print)")
            self.node.physicsBody!.applyForce(force)
        }
        
        func accelerateUp(v: RMFloatB) {
            let force = self.upVector * -v * self.speed
            // RMXLog(force.print)
            self.node.physicsBody!.applyForce(force)
        }
        
        func accelerateLeft(v: RMFloatB) {
            let force = self.leftVector * -v * self.speed
            //RMXLog(force.print)
            self.node.physicsBody!.applyForce(force)
        }
        
        
        func completeStop(){
            self.stop()
            self.node.physicsBody!.velocity = RMXVectorZero
        }
        ///Stops all acceleration foces, not velocity
        func stop(){
            self.node.physicsBody!.clearAllForces()
        }
        
        var scale: RMXSize {
            return self.node.presentationNode().scale
        }
        
        func setRadius(radius: RMFloatB){
            let s = CGFloat(radius * 2)
            self.node.xScale = s
            self.node.yScale = s
        }
        
        var weight: RMFloatB {
            return RMFloatB(self.node.physicsBody!.mass)// * self.world.gravity
        }
        
        func distanceTo(point: RMXVector3 = RMXVector3Zero) -> RMFloatB{
            return 1//RMXVector3Distance(self.position, point)
        }
        
        func distanceTo(object:RMXSprite) -> RMFloatB{
            return 1//RMXVector3Distance(self.position,object.position)
        }
        
        
        
        
        var velocity: RMXVector {
            if let body = self.physicsBody {
                return body.velocity
            } else {
                return RMXVectorZero
            }
        }
        
        func setPosition(position: RMXPoint? = nil, resetTransform: Bool = true){
            if let position = position {
                self.node.position = position
            }
            //        self.node.orientation = self.getNode().orientation
            //        self.node.scale = self.getNode().scale
    
        }
        
        class func rootNode(node: RMXNode, rootNode: RMXNode) -> RMXNode {
            if node.parentNode == rootNode || node.parentNode == nil {
                RMXLog("RootNode: \(node.name)")
                return node
            } else {
                RMXLog(node.parentNode)
                return self.rootNode(node.parentNode!, rootNode: rootNode)
            }
        }
    }

#endif


extension RMXSprite {
    
    func setRotationSpeed(speed s: RMFloatB){
        self.rotationSpeed = s
    }

}


extension RMXSprite {
    

    
    func addAi(ai: (RMXNode!) -> Void) {
        self.behaviours.append(ai)
        //self.behaviours.last?()
    }
    
    
    var viewPoint: RMXPoint {
        return self.position - self.forwardVector
    }
    

    
    
    var isGrounded: Bool {
        return (self.velocity.y == 0 && self.world?.hasGravity != nil)
    }
    
    var upThrust: RMFloatB {
        return self.node.physicsBody!.velocity.y
    }
    
    
}


extension RMXSprite {
    
    var upVector: RMXVector {
        return self.transform.up
    }
    
    var leftVector: RMXVector {

        return self.transform.left
    }
    
    var forwardVector: RMXVector {
        return self.transform.forward
    }
}


extension RMXSprite {
    
    func grabNode(sprite: RMXSprite?){
        if let sprite = sprite {
            #if SceneKit
            //self.insertChild(sprite)
            sprite.setPosition(position: self.forwardVector)
            #endif
        }
    }
    
}

extension RMXSprite {
    func setColor(col: GLKVector4){
//        #if SceneKit
            let color = NSColor(red: CGFloat(col.x), green:  CGFloat(col.y), blue:  CGFloat(col.z), alpha:  CGFloat(col.w))
            self.setColor(color: color)
        self.color = col
        
//            #else
//            self.shape!.color = col
//        #endif
    }
    
    
    
    func setColor(#color: NSColor){
        #if SceneKit
            self.node.geometry?.firstMaterial!.diffuse.contents = color
            self.node.geometry?.firstMaterial!.diffuse.intensity = 1
            self.node.geometry?.firstMaterial!.specular.contents = color
            self.node.geometry?.firstMaterial!.specular.intensity = 1
            self.node.geometry?.firstMaterial!.ambient.contents = color
            self.node.geometry?.firstMaterial!.ambient.intensity = 1
            self.node.geometry?.firstMaterial!.transparent.intensity = 0
//            if self.isLight {
//                self.node.geometry?.firstMaterial!.emission.contents = color
//                self.node.geometry?.firstMaterial!.emission.intensity = 1
//                //                self.geometry?.firstMaterial!.transparency = 0.5
//            } else {
//                //                self.geometry?.firstMaterial!.doubleSided = true
//                
//                
//            }
            #else
            //self.shape!.color = RMXVector4Make(Float(color.redComponent), Float(color.greenComponent), Float(color.blueComponent), Float(color.brightnessComponent))
        #endif
    }
    
    func makeAsSun(rDist: RMFloatB = 1000, rAxis: RMXVector3 = RMXVector3Make(1,0,0)) -> RMXSprite {
        if self.type == nil {
            self.type = .BACKGROUND
        }
        

        self.setRotationSpeed(speed: 1 * PI_OVER_180 / 10)

        
               
        self.rAxis = rAxis
        #if SceneKit
        self.node.pivot.m43 = -rDist
        #endif
        
        return self
    }
    
   
}


