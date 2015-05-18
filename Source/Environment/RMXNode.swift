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

    func getNode() -> RMXNode {
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
            let axis = self.upVector
            let speed = self.rotationSpeed * theta
            self.node.physicsBody!.applyTorque(SCNVector4Make(axis.x,axis.y,axis.z, -speed), impulse: false)
        }
        if let phi = p {
            let axis = self.leftVector
            let speed = self.rotationSpeed * phi
            self.node.physicsBody!.applyTorque(SCNVector4Make(axis.x,axis.y,axis.z, speed), impulse: false)
        }
        if let roll = r {
            let axis = self.forwardVector
            let speed = self.rotationSpeed * roll
            self.node.physicsBody!.applyTorque(SCNVector4Make(axis.x,axis.y,axis.z, -speed), impulse: false)
            //            self.node.transform *= RMXMatrix4MakeRotation(speed * 0.0001, RMXVector3Make(0,0,1))
        }
        
    }
    var orientation: RMXVector4 {
        return self.node.presentationNode().orientation
    }
    
    func accelerateForward(v: RMFloatB) {
        let force = self.forwardVector * -v * self.speed
        //RMXLog("\n Force:\(force.print)")
        self.node.physicsBody!.applyForce(force, impulse: false)
    }
    
    func accelerateUp(v: RMFloatB) {
        let force = self.upVector * -v * self.speed
        // RMXLog(force.print)
        self.node.physicsBody!.applyForce(force, impulse: false)
    }
    
    func accelerateLeft(v: RMFloatB) {
        let force = self.leftVector * -v * self.speed
        //RMXLog(force.print)
        self.node.physicsBody!.applyForce(force, impulse: false)
    }
    
    
    func completeStop(){
        self.stop()
        self.node.physicsBody!.velocity = RMXVector3Zero
    }
    ///Stops all acceleration foces, not velocity
    func stop(){
        self.node.physicsBody!.clearAllForces()
    }
    
    var scale: RMXVector3 {
        return self.node.presentationNode().scale
    }
    
    class func rootNode(node: RMXNode, rootNode: RMXNode) -> RMXNode {
        if node.parentNode == rootNode || node.parentNode == nil {
            RMXLog("RootNode: \(node.name)")
            return node
        } else {
            println(node.parentNode)
            return self.rootNode(node.parentNode!, rootNode: rootNode)
        }
    }
    
}
    
    
    
    
    #elseif SpriteKit
    extension RMXSprite {
        
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
        
        
        func applyForce(direction: RMXVector3, atPosition: RMXVector3? = nil, impulse: Bool = false) {
            let dir = CGVector(dx: CGFloat(direction.x), dy: CGFloat(direction.y))
            if let atPosition = atPosition {
                let pos = CGPoint(x: CGFloat(atPosition.x), y: CGFloat(atPosition.y))
                self.node.physicsBody?.applyForce(dir, atPoint: pos)
            } else {
                self.node.physicsBody?.applyForce(dir)
            }
        }
        
        func applyForce(impulse: CGVector, atPoint: CGPoint? = nil) {
            if let atPoint = atPoint {
                self.node.physicsBody?.applyForce(impulse, atPoint: atPoint)
            } else {
                self.node.physicsBody?.applyForce(impulse)
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
                let axis = self.upVector
                let speed = self.rotationSpeed * theta
                self.node.physicsBody!.applyTorque(SCNVector4Make(axis.x,axis.y,axis.z, -speed), impulse: false)
            }
            if let phi = p {
                let axis = self.leftVector
                let speed = self.rotationSpeed * phi
                self.node.physicsBody!.applyTorque(SCNVector4Make(axis.x,axis.y,axis.z, speed), impulse: false)
            }
            if let roll = r {
                let axis = self.forwardVector
                let speed = self.rotationSpeed * roll
                self.node.physicsBody!.applyTorque(SCNVector4Make(axis.x,axis.y,axis.z, -speed), impulse: false)
                //            self.node.transform *= RMXMatrix4MakeRotation(speed * 0.0001, RMXVector3Make(0,0,1))
            }
            
        }
        
        var orientation: RMXVector4 {
            return self.node.presentationNode().orientation
        }
        
        func accelerateForward(v: RMFloatB) {
            let force = self.forwardVector * -v * self.speed
            //RMXLog("\n Force:\(force.print)")
            self.node.physicsBody!.applyForce(force, impulse: false)
        }
        
        func accelerateUp(v: RMFloatB) {
            let force = self.upVector * -v * self.speed
            // RMXLog(force.print)
            self.node.physicsBody!.applyForce(force, impulse: false)
        }
        
        func accelerateLeft(v: RMFloatB) {
            let force = self.leftVector * -v * self.speed
            //RMXLog(force.print)
            self.node.physicsBody!.applyForce(force, impulse: false)
        }
        
        
        func completeStop(){
            self.stop()
            self.node.physicsBody!.velocity = RMXVector3Zero
        }
        ///Stops all acceleration foces, not velocity
        func stop(){
            self.node.physicsBody!.clearAllForces()
        }
        
        var scale: RMXVector3 {
            return self.node.presentationNode().scale
        }
        
        class func rootNode(node: RMXNode, rootNode: RMXNode) -> RMXNode {
            if node.parentNode == rootNode || node.parentNode == nil {
                RMXLog("RootNode: \(node.name)")
                return node
            } else {
                println(node.parentNode)
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
    

    
    func addBehaviour(behaviour: (isOn: Bool) -> ()) {
        self.behaviours.append(behaviour)
        //self.behaviours.last?()
    }
    
    
    var viewPoint: RMXVector3{
        return self.position - self.forwardVector
    }
    

    
    
    var isGrounded: Bool {
        return self.position.y <= self.height / 2
    }
    
    var upThrust: RMFloatB {
        return self.node.physicsBody!.velocity.y
    }
    
    
}


extension RMXSprite {
    var transform: RMXMatrix4 {
        return self.node.presentationNode().transform
    }

    var position: RMXVector3 {
        return self.node.presentationNode().position
    }
    
    var upVector: RMXVector3 {
        let transform = self.transform
        let v = RMXVector3Make(transform.m21, transform.m22, transform.m23)
        return v
    }
    
    var leftVector: RMXVector3 {
        let transform = self.transform
        let v = RMXVector3Make(transform.m11,transform.m12,transform.m13)
        return v
    }
    
    var forwardVector: RMXVector3 {
        let transform = self.transform
        let v = RMXVector3Make(transform.m31, transform.m32, transform.m33)
        return v
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
    
    func makeAsSun(rDist: RMFloatB = 1000, rAxis: RMXVector3 = RMXVector3Make(0,0,1)) -> RMXSprite {
        if self.type == nil {
            self.type = .BACKGROUND
        }
        

        self.setRotationSpeed(speed: 1 * PI_OVER_180 / 10)

        
        let lightNode = RMXModels.getNode(shapeType: ShapeType.SPHERE.rawValue, mode: .ABSTRACT, radius: 100)
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeOmni
        lightNode.geometry?.firstMaterial!.emission.contents = NSColor.whiteColor()
        lightNode.geometry?.firstMaterial!.emission.intensity = 1
        self.node.addChildNode(lightNode)
       
        self.rAxis = rAxis
        self.node.pivot.m41 = rDist //(self.world!.radius) * 10
//        self.node.position.y = 5000
        return self
    }
    
   
}


