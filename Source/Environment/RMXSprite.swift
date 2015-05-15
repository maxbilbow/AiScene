//
//  RMXInteraction.swift
//  RattleGL
//
//  Created by Max Bilbow on 17/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation

import SceneKit
import GLKit
    
enum JumpState { case PREPARING_TO_JUMP, JUMPING, GOING_UP, COMING_DOWN, NOT_JUMPING }
enum RMXSpriteType { case  AI, PLAYER, BACKGROUND, PASSIVE, WORLD, ABSTRACT, KINEMATIC }

protocol RMXSpriteManager {
//    
}
class RMXSprite : RMXSpriteManager {
    
    lazy var environments: ChildSpriteArray = ChildSpriteArray(parent: self)
    var aiOn: Bool = false
    
    var children: [RMXSprite] {
        return environments.current
    }
    
    var childSpriteArray: ChildSpriteArray{
        return self.environments
    }
    var hasChildren: Bool {
        return self.children.isEmpty
    }
    
    
    var cameraNode: SCNNode {
        return self.cameras[self.cameraNumber]
    }
    
    var color: GLKVector4 = GLKVector4Make(0.5,0.5,0.5,1)
    var scene: SCNScene? {
        return world!.scene
    }
    var radius: RMFloatB {
        return RMFloatB(self.scale.average)
    }
    static var COUNT: Int = 0
    var rmxID: Int = RMXSprite.COUNT
    var isUnique: Bool = false
    var hasFriction = true
    var hasGravity = false
    private var _rotation: RMFloatB = 0
    var isVisible: Bool = true
    var isLight: Bool = false
    var shapeType: ShapeType = .NULL
    
    var world: RMSWorld?
    
    var type: RMXSpriteType!
    var wasJustThrown:Bool = false
    var anchor = RMXVector3Zero
    
    var parentSprite: RMXSprite?
    
//    lazy var body: RMSPhysicsBody? = RMSPhysicsBody(self)
    
    var parentNode: SCNNode? {
        return self.node.parentNode
    }
    
    var node: SCNNode {
        return self._node
    }
    
    var parent: RMXSprite?
    
    private var _node: SCNNode
    
    
    var name: String {
        return "\(_name)-\(self.rmxID)"
    }
    
    var centerOfView: RMXVector3 {
        return self.position + self.forwardVector// * self.actions.reach
    }
    
    var isAnimated: Bool = true
    private var _name: String = "SPRITE"
    
    func setName(name: String? = nil) {
        if let name = name {
            self._name = name
            NSLog("Name set to \(self.name)")
        } else if let name = self.node.name {
            NSLog("node is '\(name)' (!= \(self.name)) - sprite will be named '\(_name)-\(name)-\(self.rmxID)'")
            if self.name != name { self._name += "-\(name)" }
        } else {
            NSLog(self.node.name ?? "node is nameless - but will be named '\(self.name)'")
            //self.node.name = self.name
        }
        self.node.name = self.name
        
        
    }
    var altitude: RMFloatB {
        return self.position.y
    }
    private var armLength: RMFloatB = 0
    var reach: RMFloatB {
        return self.node.scale.z + self.armLength
    }
    
    
    private var _jumpState: JumpState = .NOT_JUMPING
    private var _maxSquat: RMFloatB = 0
    
    var startingPoint: RMXVector3 = RMXVector3Zero
    var x,y,z: RMFloatB?
    
    
   
    
    var behaviours: [(Bool) -> ()] = Array<(Bool) -> ()>()

    //    var children: UnsafeMutablePointer<[Int : RMXNode]> {
    //        return environments.current
    //    }
    
    var variables: [ String: Variable] = [ "isBouncing" : Variable(i: 1) ]
    
    
    
    var isObserver: Bool {
        return self == self.world!.observer
    }
    
    var isActiveSprite: Bool {
        return self == self.world!.activeSprite
    }
    
    
    
    

    ///Set automated rotation (used mainly for the sun)
    ///@todo create a behavior protocal/class instead of fun pointers.
    var rAxis = RMXVector3Make(0,0,1)
    
    var rotationCenterDistance:RMFloatB = 0
    var isRotating = false
    
    var isInWorld: Bool {
        return self.distanceTo() < RMFloatB(self.world!.radius)
    }
    
    
    class func Unique(parent:AnyObject?, asType type: RMXSpriteType = .PASSIVE) -> RMXSprite {
        let result = RMXSprite.new(parent: parent!)
        result.type = type
        result.isUnique = true
        
        return result
    }

    
    var jumpStrength: RMFloatB = 10
    var squatLevel:RMFloatB = 0
    private var _prepairingToJump: Bool = false
    private var _goingUp:Bool = false
    private var _ignoreNextJump:Bool = false
    private var _itemWasAnimated:Bool = false
    private var _itemHadGravity:Bool = false
    

    var item: RMXSprite?
    var itemPosition: RMXVector3 = RMXVector3Zero
    

    init(node: SCNNode = RMXNode()){
        _node = node
        
        self.spriteDidInitialize()
    }
    
    func setNode(node: SCNNode){
        self._node = node
        self.setName()
    }
    
    var usesBehaviour = true

    var hasItem: Bool {
        return self.item != nil
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
    
    class func new(parent p: AnyObject, node: SCNNode? = nil) -> RMXSprite {
        
        let sprite = RMXSprite(node: node ?? RMXNode())
    
            if let world = p as? RMSWorld {
                
//                let minHeight = parent.ground + sprite.height / 3
//                if sprite.y < minHeight {
//                    sprite.y = minHeight
//                }
                world.insertChild(sprite, andNode: true)
            } else if let parent = p as? RMXSprite {
                parent.insertChild(sprite, andNode: false)//TODO:: is this right?
            
            } else {
                fatalError("Not yet compatable")
            }
        return sprite
    }
    
    func spriteDidInitialize(){
        RMXSprite.COUNT++
        #if SceneKit
           // self.node.physicsBody = SCNPhysicsBody.staticBody()
           // self.node.physicsBody!.restitution = 0.5
//TODO
        #endif
        if self.parentSprite != nil {
            self.world = self.parentSprite!.world
        }
        self.setName()
    }
    
    func toggleGravity() {
        self.hasGravity = !self.hasGravity
    }
    
    var theta: RMFloatB = 0
    var phi: RMFloatB = 0//90 * PI_OVER_180
    var roll: RMFloatB = 0//90 * PI_OVER_180
//    var orientation = RMXMatrix4Identity
    var rotationSpeed: RMFloatB = 1

    var speed:RMFloatB = 1

    
    var acceleration: RMXVector3 = RMXVector3Zero
    private let _zNorm = 90 * PI_OVER_180
    
    func processAi(aiOn isOn: Bool = true) {
        for behaviour in self.behaviours {
            behaviour(isOn)
        }
    }
    
    func animate(aiOn: Bool = false) {
        if let type = self.type {
            switch type {
            case .AI:
                self.processAi(aiOn: aiOn)
                self.manipulate()
                self.jumpTest()
                break
            case .PLAYER:
                self.manipulate()
                self.jumpTest()
                break
            case .PASSIVE:
                break
            case .BACKGROUND:
                ///add this as a behaviour (create the variables outside of function before adding)
                if self.isRotating {
                    self.node.transform *= RMXMatrix4MakeRotation(self.rotationSpeed, self.rAxis)
                    //TODO if body, then resettransform
                }
            default:
                break
            }
            
            for child in children {
                child.animate()
            }
        
            
        }
    }
    
    func debug(_ yes: Bool = true){
        if yes {
            let transform = self.node.transform
            if self.isObserver { RMXLog("\nTRANSFORM:\n\(transform.print),\n   POV: \(self.viewPoint.print)") }
           
        
            if self.isObserver { RMXLog("\n\n   LFT: \(self.leftVector.print),\n    UP: \(self.upVector.print)\n   FWD: \(self.forwardVector.print)\n\n") }
        }
    }
    
    lazy var cameras: Array<SCNNode> = [ self.node ]
    var cameraNumber: Int = 0

}

extension RMXSprite {

    func initPosition(startingPoint point: RMXVector3){
        func set(inout value: RMFloatB?, new: RMFloatB) -> RMFloatB {
            if let X = value {
                return X
            } else {
                value = new
                return new
            }
        }
        self.x = self.x ?? point.x
        self.y = self.y ?? point.y
        self.z = self.z ?? point.z
        self.startingPoint = RMXVector3Make(self.x!,self.y!,self.z!)
        //self.node.position = startingPoint
        
        
    }
    
    
    private func setShape(shapeType type: ShapeType, scale s: RMXVector3?) {
            let scale = s ?? self.node.scale
            self.setNode(RMXModels.getNode(shapeType: type.rawValue, scale: scale))
    }
    
    func asShape(radius: RMFloatB? = nil, height: RMFloatB? = nil, scale: RMXVector3? = nil, shape shapeType: ShapeType = .CUBE, asType type: RMXSpriteType = .PASSIVE, color: NSColor? = nil) -> RMXSprite {
        
        func needsNewBody(n: SCNNode, type: SCNPhysicsBodyType = .Dynamic) -> Bool{
            if let body = n.physicsBody {
                if type == body.type {
                    return false
                }
            }
            return true
        }
        self.setNode(RMXModels.getNode(shapeType: shapeType.rawValue,mode: type, scale: scale, radius: radius, height: height, color: color))
        return self
    }

    var mass: RMFloatB {
        if let body = self.node.physicsBody {
            return RMFloatB(body.mass)
        } else {
            return 0
        }
    }
    
    func asPlayerOrAI(position: RMXVector3 = RMXVector3Zero) -> RMXSprite {
        if self.type == nil {
            self.type = .PLAYER
        }
        
        self.speed = 1000 * self.mass / 10
        self.rotationSpeed = 150 * self.mass / 5

        if let body = self.node.physicsBody {
//           body.rollingFriction = 1000//0.99
            body.angularDamping = 0.99
            body.damping = 0.5
            body.friction = 0.0
        } else {
            if self.node.geometry == nil {
                self.node.physicsBody = SCNPhysicsBody.dynamicBody()//TODO check
            }
        }
            self.node.camera = RMXCamera()
            self.armLength = self.radius * RMFloatB(2)
            self.hasGravity = false
        
    
//        self.node.physicsBody!.restitution = 0
        self.y = self.world!.radius
        self.initPosition(startingPoint: position)
        self.addCamera()
        return self
    }
    func getNextCamera() -> SCNNode {
        self.cameraNumber = self.cameraNumber + 1 >= self.cameras.count ? 0 : self.cameraNumber + 1
        return self.cameras[self.cameraNumber]
    }
    
    func getPreviousCamera() -> SCNNode {
        self.cameraNumber = self.cameraNumber - 1 < 0 ? self.cameras.count - 1 : self.cameraNumber - 1
        return self.cameras[self.cameraNumber]
    }
    func addCamera(cameraNode: SCNNode){
        self.cameras.append(cameraNode)
    }

    func addCamera(position: SCNVector3? = nil) {
        var pos: SCNVector3
        if let p = position {
            pos = p
        } else {
            pos = SCNVector3Make(0,self.radius * 3, self.radius * 3 * 50)
        }
        
        let cameraNode = SCNNode()
        
        self.cameras.append(cameraNode)
        self.node.addChildNode(cameraNode)
        cameraNode.position = pos
        cameraNode.camera = RMXCamera()
    }
    
    
   
}


extension RMXSprite {
    
    func insertChild(child: RMXSprite, andNode:Bool = true){
        child.parentSprite = self
        child.world = self.world
        #if SceneKit
            if andNode {
                    self.node.addChildNode(child.node)
            }
            
        #endif
    }
    
    
    func insertChildren(#children: [Int:RMXSprite], andNodes:Bool = true){
        for child in children {
            self.insertChild(child.1, andNode: andNodes)
        }
    }
    
    
    func expellChild(id rmxID: Int){
        if let child = self.childSpriteArray.get(rmxID) {
            if child.parentSprite! == self {
                //child.parent! = self.world
                self.childSpriteArray.remove(rmxID)
            }
        }
        
    }
    
    func expellChild(child: RMXSprite){
        if child.parentSprite! == self {
            child.parentSprite!.world = self.world
            self.childSpriteArray.remove(child.rmxID)
        }
    }
    
    func removeBehaviours(){
        self.behaviours.removeAll()
    }
    
    
    
    
  
    
    func toggleFriction() {
        self.hasFriction = !self.hasFriction
    }
}
extension RMXSprite {
    
    func throwItem(strength: RMFloatB) -> Bool
    {
        if let itemInHand = self.item {
            itemInHand.isAnimated = true
            itemInHand.hasGravity = _itemHadGravity
            let fwd4 = self.forwardVector * -1
            let fwd3 = RMXVector3Make(fwd4.x, fwd4.y, fwd4.z)
//            self.item!.node.physicsBody!.velocity = self.node.physicsBody!.velocity + RMXVector3MultiplyScalar(fwd3,strength)
            if let body = itemInHand.node.physicsBody {
                body.applyForce(self.velocity + RMXVector3MultiplyScalar(fwd3,strength), impulse: false)
                RMXLog("\(itemInHand.name) was just thrown")
            } else {
                RMXLog("\(itemInHand.name) had no body")
            }
            self.item!.wasJustThrown = true
            self.setItem(item: nil)
            return true
        } else {
            return false
        }
    }
    
    func manipulate() {
        if let item = self.item {
            let fwd = self.forwardVector * -1
            self.item!.setPosition(self.viewPoint + RMXVector3MultiplyScalar(fwd, self.reach + self.item!.reach))            
        }
    }
    
    private func setItem(item itemIn: RMXSprite?){
        if let item = itemIn {
            self.item = item
//            self.insertChild(item)
//            self.item!.node.position = RMXVector3Zero
//            self.item!.node.position.z = self.reach + self.item!.reach
            _itemWasAnimated = item.isAnimated
            _itemHadGravity = item.hasGravity
            item.hasGravity = false
            item.isAnimated = true
            self.armLength = self.reach
        } else if let item = self.item {
            item.isAnimated = true
            item.hasGravity = _itemHadGravity
//            self.world.insertChild(item)
            
            self.item = nil
        }
    }
    
    func isWithinReachOf(item: RMXSprite) -> Bool{
        return self.distanceTo(item) <= self.reach + item.radius
    }
    
    func grabItem(item itemIn: RMXSprite? = nil) -> RMXSprite? {
        if self.hasItem { return self.item }
        if let item = itemIn {
            if self.isWithinReachOf(item) || true {
                self.setItem(item: item)
                return item
            }
        }
//        } else if let item = self.world!.closestObjectTo(self) {
//            if self.item == nil && self.isWithinReachOf(item) {
//                self.setItem(item: item)
//                return item
//            }
//        }
        return nil
    }
    
    func releaseItem() {
        if item != nil { RMXLog("DROPPED: \(item!.name)") }
        if self.item != nil {
            self.item!.isAnimated = true //_itemWasAnimated
            self.item!.hasGravity = _itemHadGravity
//            #if SceneKit
//            self.item!.node.removeFromParentNode()
//                #endif
//            self.world.insertChild(self.item!)
            self.setItem(item: nil)
        }
    }
    
    func extendArmLength(i: RMFloatB)    {
        if self.armLength + i > 1 {
            self.armLength += i
        }
    }
    
    
    enum JumpState { case PREPARING_TO_JUMP, JUMPING, GOING_UP, COMING_DOWN, NOT_JUMPING }
    
    var height: RMFloatB {
        return self.radius * 3 // sself.node.scale.y
    }
    
    func jumpTest() -> JumpState {
        
        switch (_jumpState) {
        case .NOT_JUMPING:
            return _jumpState
        case .PREPARING_TO_JUMP:
            if self.squatLevel > _maxSquat{
                _jumpState = .JUMPING
            } else {
                let increment: RMFloatB = _maxSquat / 50
                self.squatLevel += increment
            }
            break
        case .JUMPING:
            if self.altitude > self.height || _jumpStrength < self.weight {//|| self.body.velocity.y <= 0 {
                _jumpState = .GOING_UP
                self.squatLevel = 0
            } else {
                //RMXVector3PlusY(&self.node.physicsBody!.velocity, _jumpStrength) //TODO check mass is necessary below
                self.node.physicsBody?.applyForce(RMXVector3Make(0, _jumpStrength * self.mass, 0), impulse: false)
            }
            break
        case .GOING_UP:
            if self.node.physicsBody!.velocity.y <= 0 {
                _jumpState = .COMING_DOWN
            } else {
                //Anything to do?
            }
            break
        case .COMING_DOWN:
            if self.altitude <= self.radius {
                _jumpState = .NOT_JUMPING
            }
            break
        default:
            fatalError("Shouldn't get here")
        }
        return _jumpState
    }
    
    func prepareToJump() -> Bool{
        if _jumpState == .NOT_JUMPING && self.isGrounded {
            _jumpState = .PREPARING_TO_JUMP
            _maxSquat = self.radius / 4
            return true
        } else {
            return false
        }
    }
    
    private var _jumpStrength: RMFloatB {
        return fabs(self.weight * self.jumpStrength * self.squatLevel/_maxSquat)
    }
    func jump() {
        if _jumpState == .PREPARING_TO_JUMP {
            _jumpState = .JUMPING
        }
    }

    func setReach(reach: RMFloatB) {
        self.armLength = reach
    }
    
    private class func stop(sender: RMXSprite, objects: [AnyObject]?) -> AnyObject? {
        sender.completeStop()
        return nil
    }
    
    func headTo(object: RMXSprite, var speed: RMFloatB = 1, doOnArrival: (sender: RMXSprite, objects: [AnyObject]?)-> AnyObject? = RMXSprite.stop, objects: AnyObject ... )-> AnyObject? {
        let dist = self.turnToFace(object, rSpeed: speed)
        if  dist >= fabs(object.reach + self.reach) {
            #if OPENGL_OSX
                speed *= 0.5
            #endif
            self.accelerateForward(speed)
            if !self.hasGravity {
                let climb = speed * 0.1
                if self.altitude < object.altitude {
                    self.node.physicsBody?.applyForce(SCNVector3Make(0,climb,0), impulse: true)
                } else if self.altitude > object.altitude {
                    self.node.physicsBody?.applyForce(SCNVector3Make(0,-climb / 2,0), impulse: true)
                } else {
                    self.stop()
                    //RMXVector3SetY(&self.node.physicsBody!.velocity, 0)
                }
            }
            
        } else {
            let result: AnyObject? = doOnArrival(sender: self, objects: objects)
            return result ?? dist
        }
        return dist

    }
    
///TODO Theta may be -ve?
    func turnToFace(object: RMXSprite, rSpeed: RMFloatB = 1) -> RMFloatB {
        var goto = object.centerOfView
        
        
        let theta = -RMXGetTheta(vectorA: self.position, vectorB: goto)
        if theta > 0.1 {
            self.lookAround(theta: self.rotationSpeed * rSpeed)
        }
        
        if self.hasGravity { //TODO delete and fix below
            RMXVector3SetY(&goto,self.position.y)
        }

        
        /*else {
            let phi = -RMXGetPhi(vectorA: self.position, vectorB: goto) //+ PI_OVER_2
            self.body.setPhi(upDownRadians: phi)
        }*/

        return self.distanceTo(point: goto)
    }
    
   
    
}



