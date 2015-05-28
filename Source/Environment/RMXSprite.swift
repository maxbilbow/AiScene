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
enum RMXSpriteType { case  AI, PLAYER, BACKGROUND, PASSIVE, ABSTRACT, KINEMATIC, PLAYER_OR_AI }

protocol RMXSpriteManager {
//    
}



class RMXSprite : RMXSpriteManager {
    lazy var tracker: RMXTracker = RMXTracker(sprite: self)
//    var hitTarget = false
//    var target: RMXSprite?
//    var doOnArrival: ((sender: RMXSprite, target: AnyObject)-> AnyObject?)?
    
    lazy var environments: SpriteArray = SpriteArray(parent: self)
    var aiOn: Bool = false
    
    var holder: RMXSprite?
    
    var isHeld: Bool {
        return self.holder != nil
    }
    
    var children: [RMXSprite] {
        return environments.current
    }
    
    var childSpriteArray: SpriteArray{
        return self.environments
    }
    var hasChildren: Bool {
        return self.children.isEmpty
    }
    
    var usesWorldCoordinates = false
    
//    var cameraNode: RMXNode {
//        return self.cameras[self.cameraNumber]
//    }
    
    var color: GLKVector4 = GLKVector4Make(0.5,0.5,0.5,1)
    var scene: RMXScene? {
        return world!.scene
    }
    var radius: RMFloatB {
        
       // let radius = RMXVector3Length(self.boundingBox.max * self.scale)
        return self.boundingSphere.radius * RMFloatB(self.scale.average)//radius
    }
    static var COUNT: Int = 0
    var rmxID: Int = RMXSprite.COUNT
    var isUnique: Bool = false
    
    var hasFriction: Bool {
        return self.node.physicsBody?.friction != 0
    }
    
    private var _rotation: RMFloatB = 0
//    var isVisible: Bool = true
//    var isLight: Bool = false
    var shapeType: ShapeType = .NULL
    
    var world: RMSWorld?
    
    var type: RMXSpriteType!
//    var wasJustThrown:Bool = false
    var anchor = RMXVector3Zero
    
    var parentSprite: RMXSprite?
    
//    lazy var body: RMSPhysicsBody? = RMSPhysicsBody(self)
    
    var parentNode: RMXNode? {
        #if SceneKit
        return self.node.parentNode
        #elseif SpriteKit
        return self.node.parent
        #endif
        
    }
    
    var node: RMXNode {
        return self._node
    }
    
    var parent: RMXSprite?
    
    private var _node: RMXNode
    
    
    var name: String {
        return "\(_name)-\(self.rmxID)"
    }
    
    var centerOfView: RMXPoint {
        return self.position + self.forwardVector// * self.actions.reach
    }
    
    private var _name: String = "SPRITE"
    
    func setName(name: String? = nil) {
        if let name = name {
            self._name = name
            RMXLog("Name set to \(self.name)")
        } else if let name = self.node.name {
            RMXLog("node is '\(name)' (!= \(self.name)) - sprite will be named '\(_name)-\(name)-\(self.rmxID)'")
            if self.name != name { self._name += "-\(name)" }
        } else {
            RMXLog(self.node.name ?? "node is nameless - but will be named '\(self.name)'")
            //self.node.name = self.name
        }
        self.node.name = self._name
        
        
    }
    var altitude: RMFloatB {
        return RMFloatB(self.position.y)
    }
    
    func setAltitude(y: RMFloatB, resetTransform: Bool = true) {
        self.node.position.y = y
        if resetTransform {
            self.resetTransform()
        }
    }
    
    func isHolding(id: Int) -> Bool{
        return self.item?.rmxID == id
    }
    
    func isHolding(item: RMXSprite?) -> Bool{
        return self.item?.rmxID == item?.rmxID
    }
    
    func isHolding(node: RMXNode?) -> Bool{
        return self.item?.rmxID == node?.rmxID
    }
    
    
    private var _reach: RMFloatB?
    
    var armLength: RMFloatB {
        return self.radius + ( self.hasItem ? item!.radius : 0 )
//        let reach = _reach ?? self.length / 2
//        if let item = self.item {
//            return reach + item.radius
//        } else {
//            return reach + 1
//        }
    }
    
    var length: RMFloatB {
        return self.boundingBox.max.z * self.scale.z
    }
    
    var width: RMFloatB {
        return self.boundingBox.max.x * self.scale.x
    }
    
    var height: RMFloatB {
        return self.boundingBox.max.y * self.scale.y
    }
    
    var bottom: RMXVector {
        return self.boundingBox.min * self.upVector * self.scale.y
    }
    
    var top: RMXVector {
        return self.boundingBox.max * self.upVector * self.scale.y
    }
    
    var front: RMXVector {
        return self.boundingBox.max * self.forwardVector * self.scale.z
    }
    
    var back: RMXVector {
        return self.boundingBox.min * self.forwardVector * self.scale.z
    }
    
    var left: RMXVector {
        return self.boundingBox.min * self.leftVector * self.scale.x
    }
    
    var right: RMXVector {
        return self.boundingBox.max * self.leftVector * self.scale.x
    }
    
    private var _jumpState: JumpState = .NOT_JUMPING
    private var _maxSquat: RMFloatB = 0
    
    var startingPoint: RMXVector3 = RMXVector3Zero
    var x,y,z: RMFloatB?
    
    
    
    
    var behaviours: [(RMXNode!) -> Void] = Array<(RMXNode!) -> Void>()

    
    
    
    var isObserver: Bool {
        return self == self.world!.observer!
    }
    
    var isActiveSprite: Bool {
        return self == self.world!.activeSprite!
    }
    
    
    
    

    ///Set automated rotation (used mainly for the sun)
    ///@todo create a behavior protocal/class instead of fun pointers.
    var rAxis = RMXVector3Make(0,0,1)
    

    
    var isInWorld: Bool {
        return self.distanceTo() < RMFloatB(self.world!.radius)
    }
    
    
    var jumpStrength: RMFloatB = 1
    var squatLevel:RMFloatB = 0
    private var _prepairingToJump: Bool = false
    private var _goingUp:Bool = false
    private var _ignoreNextJump:Bool = false

    
    private var _itemInHand: RMXSprite?
    var item: RMXSprite? {
        return _itemInHand
    }
    var itemPosition: RMXVector3 = RMXVector3Zero
    

    init(node: RMXNode = RMXNode(), type: RMXSpriteType){
        _node = node
        self.type = type
        self.spriteDidInitialize()
    }
    
    func setNode(node: RMXNode){
        self._node = node
        self.setName()
    }
    

    var hasItem: Bool {
        return self.item != nil
    }
    
    
   
    
    class func new(parent p: AnyObject, node: RMXNode? = nil, type: RMXSpriteType, isUnique: Bool) -> RMXSprite {
        
        let sprite = RMXSprite(node: node ?? RMXNode(), type: type)
        sprite.isUnique = isUnique
            if let world = p as? RMSWorld {
                world.insertChild(sprite, andNode: true)
            } else if let parent = p as? RMXSprite {
                parent.insertChild(sprite, andNode: false)//TODO:: is this right?
            
            } else {
                fatalError("Not yet compatable")
            }
        if type == .AI && !sprite.isUnique {
            RMXAi.addRandomMovement(to: sprite)
        } else {
            sprite.addCameras()
        }
        RMXBrain.giveBrainTo(sprite)
        return sprite
    }
    
    func spriteDidInitialize(){
        RMXSprite.COUNT++
        if self.parentSprite != nil {
            self.world = self.parentSprite!.world
        }
        self.setName()
    }
    
    func toggleGravity() {
       /// self.hasGravity = !self.hasGravity
        RMXLog("Unimplemented")
    }
    
    var theta: RMFloatB = 0
    var phi: RMFloatB = 0//90 * PI_OVER_180
    var roll: RMFloatB = 0//90 * PI_OVER_180
//    var orientation = RMXMatrix4Identity
    var rotationSpeed: RMFloatB = 1

    var speed:RMFloatB = 1
    var canGrabPlayers: Bool = false
    
//    var acceleration: RMXVector3?// = RMXVector3Zero
    private let _zNorm = 90 * PI_OVER_180
    
    func processAi(node: SCNNode! = nil) -> Void {
        for behaviour in self.behaviours {
            behaviour(node)
        }
    }
    
    func runActions(name: String, actions: (SCNNode!) -> Void ...) {
        var count = 0
        for action in actions {
            action(nil)
//            self.node.runAction(SCNAction.runBlock(action), forKey: "\(name)\(++count)")//.runBlock({ (node: RMXNode!) -> Void in
        }
    }
    internal func headToTarget(node: SCNNode! = nil) -> Void {
        self.tracker.headToTarget()
    }
    
    func animate(aiOn: Bool = false) {
        if let type = self.type {
            
            switch type {
            case .AI, .PLAYER, .PLAYER_OR_AI:
                self.runActions("animate", actions: self.processAi, self.manipulate, self.headToTarget)
                break
            case .PASSIVE:
                self.runActions("animate", actions: self.processAi, self.headToTarget)
                break
            case .BACKGROUND:
                self.runActions("animate", actions: self.processAi)
               break
            default:
                self.runActions("animate", actions: self.processAi)
                break
            }
            
            for child in children {
                child.animate()
            }
            
            
        }
    }
    
    #if SceneKit
    func debug(_ yes: Bool = true){
        if yes {
            let transform = self.node.transform
            if self.isObserver { RMXLog("\nTRANSFORM:\n\(transform.print),\n   POV: \(self.viewPoint.print)") }
           
        
            if self.isObserver { RMXLog("\n\n   LFT: \(self.leftVector.print),\n    UP: \(self.upVector.print)\n   FWD: \(self.forwardVector.print)\n\n") }
        }
    }
    #elseif SpriteKit
    func debug(_ yes: Bool = true){
        if yes {
        
        }
    }
    #endif
    
    var cameras: Array<RMXNode> = Array<RMXNode>()
//    var cameraNumber: Int = 0

}

extension RMXSprite : RMXLocatable {

    func getPosition() -> RMXVector {
        return self.position
    }
    
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
        self.resetTransform()
        //self.node.position = startingPoint
        
        
    }
    
    
    private func setShape(shapeType type: ShapeType, scale s: RMXSize?) {
            let scale = s ?? self.node.scale
            self.setNode(RMXModels.getNode(shapeType: type.rawValue, scale: scale))
    }
    
    @availability(*,unavailable)
    func asShape(radius: RMFloatB? = nil, height: RMFloatB? = nil, scale: RMXSize? = nil, shape shapeType: ShapeType = .CUBE, asType type: RMXSpriteType = .PASSIVE, color: NSColor? = nil) -> RMXSprite {
        
        
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
    
    func asPlayerOrAI() -> RMXSprite {
        if self.type == nil {
            self.type = .PLAYER
        }

        if let body = self.node.physicsBody {
//           body.rollingFriction = 1000//0.99
            body.angularDamping = 0.99
            #if SceneKit
            body.damping = 0.5
                #elseif SpriteKit
                body.linearDamping = 0.5
            #endif
            body.friction = 0.1
        } else {
            fatalError("Should already have physics body")
        }
    

//        self.addCamera()
        return self
    }
    
//    func addCamera(cameraNode: RMXNode){
//        self.cameras.append(cameraNode)
//    }

    internal func addCameras() {
        var pos: SCNVector3
        if self.cameras.count == 0 {
            self.node.camera = RMX.standardCamera()
            
            let yScale: RMFloatB = self.type == .BACKGROUND ? 1 : 3
            let zScale: RMFloatB = self.type == .BACKGROUND ? 2 : 2 * 5
            pos = SCNVector3Make(0,self.height * yScale, self.radius * zScale)
            
            let followNode = RMXNode()
//            followNode.camera?.technique
            self.cameras.append(followNode)
            self.node.addChildNode(followNode)
            followNode.position.y = pos.y
//            followNode.pivot.m41 = pos.x
//            followNode.pivot.m42 = pos.y
            followNode.pivot.m43 = -pos.z
            if zScale > 1 { followNode.eulerAngles.x = -15 * PI_OVER_180 }
            followNode.camera = RMX.standardCamera()
        } else {
            fatalError("cameras already set up for \(self.name)")
        }
        
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
    
    
    
    
}
extension RMXSprite {
    
    var activeCamera: RMXNode? {
        for node in self.node.childNodes {
            if node as? NSObject == self.world?.activeCamera {
                return node as? RMXNode
            }
        }
        return nil
    }
    
    func throwItem(strength: RMFloatB = 1, var atNode targetNode: RMXNode? = nil, atPoint point: RMXVector? = nil) -> Bool { //, atTarget target: AnyObject? = nil) -> Bool {
        
        if let itemInHand = self.item {
            self.setItem(item: nil)
            var direction: RMXVector = self.forwardVector
            
            if let point = point {
                direction = (point - itemInHand.position).normalised
            } else if let rootNode = targetNode?.getRootNode(inScene: self.scene!) {
                if rootNode.rmxID != self.rmxID && rootNode.rmxID != itemInHand.rmxID {
                    let target = RMXSprite.rootNode(targetNode!, rootNode: self.scene!.rootNode)
                    
                    itemInHand.tracker.setTarget(target: target, speed: 10 * itemInHand.mass, impulse: true, willJump: false, doOnArrival: { (target) -> () in
                        RMSActionProcessor.explode(itemInHand, force: strength / 200, range: 500)
                        itemInHand.tracker.setTarget()
                    })
                    return true
                }
            } else if let target = targetNode {
                direction = (target.presentationNode().position - itemInHand.position).normalised
            }
            
            if let cameraNode = self.activeCamera {
                let gradient = cameraNode.eulerAngles.x
                let mat = GLKMatrix4MakeRotation(Float(gradient), Float(1.0), 0.0, 0.0)
                direction = SCNVector3FromGLKVector3( GLKMatrix4MultiplyVector3WithTranslation(mat, SCNVector3ToGLKVector3( direction)))
            }
            
            if let body = itemInHand.node.physicsBody {
                if let target = targetNode {
                    if target.rmxID != self.rmxID && target.rmxID != itemInHand.rmxID && !target.isActiveSprite {
                        itemInHand.tracker.setTarget(target: target, speed: 10 * itemInHand.mass, impulse: true, willJump: false, doOnArrival: { (target) -> () in
                            RMSActionProcessor.explode(itemInHand, force: strength / 200, range: 500)
                            itemInHand.tracker.setTarget()
                        })
                        return true
                    }
                } else {
                    itemInHand.applyForce(self.velocity + direction * strength * itemInHand.mass, impulse: false)
                }
                if self.isActiveSprite {
                    self.world!.interface.av.playSound(RMXInterface.THROW_ITEM, info: self.position)
                }
                RMXLog("\(itemInHand.name) was just thrown")
            } else {
                RMXLog("\(itemInHand.name) had no body")
            }
            
            return true
        } else {
            return false
        }
    }
    
    func printBounds() {
        var min = RMXVector3Zero
        var max = min
        self.node.getBoundingBoxMin(&min, max: &max)
        let radius = RMXVector3Length(max * self.scale)
        RMXLog("\(self.name) pos: \(self.position.print), R: \(radius.toData()), boxMin: \(min.print), boxMax: \(max.print)")
    }
    func manipulate(node: SCNNode! = nil) -> Void {
        if let item = self.item {
            let itemRadius = item.radius // 2
            var newPos = self.position + self.forwardVector * (self.radius + itemRadius)
            if world!.hasGravity && newPos.y < itemRadius {
                newPos.y = itemRadius
            }
//            item.node.runAction(SCNAction.moveTo(newPos, duration: 1), forKey: "manipulate")
            item.setPosition(position: newPos)//, resetTransform: false)
           
        }
    }
    
    private func setItem(item itemIn: RMXSprite?) {
        if let item = itemIn {
            if item.rmxID == self.rmxID || item.isHeld || item.isActiveSprite { self.setItem(item: nil); return } //Prevent accidentily holding oneself
            if self.isWithinReachOf(item) {
                _itemInHand = item
                _itemInHand?.holder = self
                if let body = _itemInHand?.node.physicsBody {
                    body.type = .Kinematic
                }
            } else {
                let speed = item.speed
                if !item.tracker.hasTarget {
                    item.tracker.setTarget(target: self.node, speed: 500 * (item.mass + 1), willJump: false, doOnArrival: { (target) -> () in
                        self.grab(item: item)
                        item.tracker.setTarget()
                        item.speed = speed
                    })
                }
            }
        } else {
            if let item = self.item {
                if let body = _itemInHand?.node.physicsBody {
                    body.type = .Dynamic
                }
                item.holder = nil
            }
            _itemInHand = nil
        }
    }
    
    func isWithinReachOf(item: RMXSprite) -> Bool{
        return self.distanceTo(item) <= self.armLength * 3
    }
    
    func grab(node: RMXNode? = nil)  {
        self.grab(item: node?.sprite)
    }
    
    
    func grab(item: RMXSprite? = nil)  {
        if self.hasItem { return }
        if let item = item {
            if item.isHeld {
                if item.type == .AI || self.canGrabPlayers {
                    self.setItem(item: item.holder)
                } else {
                    return
                }
            } else {
                self.setItem(item: item)
            }
        }
        if self.item?.rmxID == self.rmxID {
            self.setItem(item: nil)
        }
    }
    
    func releaseItem() {
        if self.item != nil {
            self.setItem(item: nil)
        }
    }
    
    
    enum JumpState { case PREPARING_TO_JUMP, JUMPING, GOING_UP, COMING_DOWN, NOT_JUMPING }
    
    var boundingSphere: (center: RMXVector3, radius: RMFloatB) {
        var center: SCNVector3 = SCNVector3Zero
        var radius: RMFloat = 0
        self.node.getBoundingSphereCenter(&center, radius: &radius)
        return (center, RMFloatB(radius))
    }
    
    var boundingBox: (min: RMXVector, max: RMXVector) {
        var min: SCNVector3 = SCNVector3Zero
        var max: SCNVector3 = SCNVector3Zero
        self.node.getBoundingBoxMin(&min, max: &max)
        return (min, max)
    }

    private var _jumpStrength: RMFloatB {
        return fabs(RMFloatB(self.weight) * self.jumpStrength)// * self.squatLevel/_maxSquat)
    }
    
    func jump() {
        if self.position.y < self.height * 10 {
            self.applyForce(RMXVector3Make(0, _jumpStrength, 0), impulse: true)
        }

        
    }

    
    private class func stop(sender: RMXSprite, objects: [AnyObject]?) -> AnyObject? {
        sender.completeStop()
        return nil
    }
    

    
    ///TODO hitCondition instead of self.hitTarget
    @availability(*,deprecated=1)
    func headTo(object: RMXSprite?, var speed: RMFloatB = 1, doOnArrival: (sender: RMXSprite, objects: [AnyObject]?)-> AnyObject? = RMXSprite.stop, objects: AnyObject ... )-> AnyObject? {
        if let object = object {
            let target = object.position //?? self.position * 10
            let dist = RMXVector3Distance(self.position, target)
            let reach = object.radius // ?? self.radius
            if dist >= fabs(self.armLength) * 2 {
                #if OPENGL_OSX
                    speed *= 0.5
                #endif
                let direction = RMXVector3Normalize(target - self.position)
                self.applyForce(direction * speed, atPosition: self.front,  impulse: false)
                
            } else {
                let result: AnyObject? = doOnArrival(sender: self, objects: objects)
                return result ?? dist
            }
            return dist
        }
        return nil
    }
    
///TODO Theta may be -ve?
    @availability(*,obsoleted=1.0)
    func turnToFace(object: RMXSprite, rSpeed: RMFloatB = 1) -> RMFloatB {
        var goto = object.centerOfView
        
        
        let theta = -RMXGetTheta(vectorA: self.position, vectorB: goto)
        if theta > 0.1 {
            self.lookAround(theta: self.rotationSpeed * rSpeed)
        }
        
        /*else {
            let phi = -RMXGetPhi(vectorA: self.position, vectorB: goto) //+ PI_OVER_2
            self.body.setPhi(upDownRadians: phi)
        }*/

        return self.distanceTo(point: goto)
    }
    
   
    
}



