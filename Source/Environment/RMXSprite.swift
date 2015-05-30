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



class RMXSprite : RMXSpriteManager, RMXTeamMember {
    lazy var tracker: RMXTracker = RMXTracker(sprite: self)
//    var hitTarget = false
//    var target: RMXSprite?
//    var doOnArrival: ((sender: RMXSprite, target: AnyObject)-> AnyObject?)?
    

    var aiOn: Bool = false
    
    var holder: RMXSprite?
    
    @availability(*,deprecated=1)
    var isHeld: Bool {
        return self.holder != nil
    }
    
    var attributes: SpriteAttributes!
    
    var children: [RMXSprite] = []
    
    var hasChildren: Bool {
        return self.children.isEmpty
    }

    private var _useWorldCoordinates = false
    
    var scene: RMXScene? {
        return self.world.scene
    }
    var radius: RMFloatB {
        
       // let radius = RMXVector3Length(self.boundingBox.max * self.scale)
        return self.boundingSphere.radius * RMFloatB(self.scale.average)//radius
    }
    static var COUNT: Int = 0
    lazy var rmxID: Int = RMXSprite.COUNT++
    var isUnique: Bool = false
    
    var hasFriction: Bool {
        return self.node.physicsBody?.friction != 0
    }
    
    private var _rotation: RMFloatB = 0
//    var isVisible: Bool = true
//    var isLight: Bool = false
    var shapeType: ShapeType = .NULL
    
    private var _world: RMSWorld
    
    var world: RMSWorld {
        return _world
    }
    
    var type: RMXSpriteType
//    var wasJustThrown:Bool = false
    var anchor = RMXVector3Zero

    
//    lazy var body: RMSPhysicsBody? = RMSPhysicsBody(self)
    
    var parentNode: RMXNode? {
        return self.node.parentNode
    }
    
    var node: RMXNode {
        return self._node
    }
    
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
    
    
    
    
    var behaviours: Array<(RMXNode!) -> Void> = Array<(RMXNode!) -> Void>()

    
    
    var isActiveSprite: Bool {
        return self.rmxID == self.world.activeSprite?.rmxID
    }
    
    
    
    

    ///Set automated rotation (used mainly for the sun)
    ///@todo create a behavior protocal/class instead of fun pointers.
    var rAxis = RMXVector3Make(0,0,1)
    

    
    var isInWorld: Bool {
        return RMFloatB(self.position.length) < self.world.radius
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
    

    init(inWorld world: RMSWorld, node: RMXNode = RMXNode(), type: RMXSpriteType){
        _world = world
        _node = node
        self.type = type
        self.attributes = SpriteAttributes(self)
        self.spriteDidInitialize()
    }
    
    func setNode(node: RMXNode){
        self._node = node
        self.setName()
    }
    

    var hasItem: Bool {
        return self.item != nil
    }
    
    
   
    
    class func new(inWorld world: RMSWorld, node: RMXNode? = nil, type: RMXSpriteType, isUnique: Bool) -> RMXSprite {
        
        let sprite = RMXSprite(inWorld: world, node: node ?? RMXNode(), type: type)
        sprite.isUnique = isUnique
        world.insertChild(sprite, andNode: true)
        sprite.addCameras()

        RMXBrain.giveBrainTo(sprite)
        
        if sprite.isUnique && sprite.isPlayer {
//            sprite.addCameras()
        }
        
        return sprite
    }
    
    func spriteDidInitialize(){
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
    
    func animate() {
        switch self.type {
        case .AI, .PLAYER, .PLAYER_OR_AI:
            self.runActions("animate", actions: self.processAi, self.manipulate, self.headToTarget)
            return
        case .PASSIVE:
            self.runActions("animate", actions: self.processAi, self.headToTarget)
            return
        case .BACKGROUND:
            self.runActions("animate", actions: self.processAi)
            return
        default:
            self.runActions("animate", actions: self.processAi)
            return
        }
    }
    

    func debug(_ yes: Bool = true){
        if yes {
            let transform = self.node.transform
            if self.isActiveSprite { RMXLog("\nTRANSFORM:\n\(transform.print),\n   POV: \(self.viewPoint.print)") }
           
        
            if self.isActiveSprite { RMXLog("\n\n   LFT: \(self.leftVector.print),\n    UP: \(self.upVector.print)\n   FWD: \(self.forwardVector.print)\n\n") }
        }
    }
  
    
    var cameras: Array<RMXCameraNode> = Array<RMXCameraNode>()
//    var cameraNumber: Int = 0

    
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
    
    var isPlayer: Bool {
        return self.type == RMXSpriteType.PLAYER || self.type == RMXSpriteType.AI
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
    
    func asPlayer() -> RMXSprite {
//        self.type = .PLAYER

        if let body = self.node.physicsBody {
//           body.rollingFriction = 1000//0.99
            body.angularDamping = 0.99
            body.damping = 0.5
            body.friction = 0.1
        } else {
            fatalError("Should already have physics body")
        }
    

        return self
    }
    
//    func addCamera(cameraNode: RMXNode){
//        self.cameras.append(cameraNode)
//    }

    internal func addCameras() {
        if self.cameras.count == 0 {
            if self.type == .PLAYER {
                RMXCamera.followCam(self, option: CameraOptions.FIXED).pov()
                RMXCamera.headcam(self).pov()
                RMXCamera.followCam(self, option: CameraOptions.FREE)
            } else if self.isUnique {
                RMXCamera.headcam(self)
                RMXCamera.followCam(self, option: CameraOptions.FIXED)
            }
            

        } else {
            fatalError("cameras already set up for \(self.name)")
        }
        
    }

    
    func removeBehaviours(){
        self.behaviours.removeAll()
    }
    
    func updateCoordinateSystem() {
        _useWorldCoordinates = self.isActiveSprite && !self.isActiveCamera
    }
    

    
    ///Used when checkin whether or not to use local or global coordinates when controlling
    var isActiveCamera: Bool {
        return self.world.activeCamera.rmxID == self.rmxID
    }

    func throwItem(atObject object: AnyObject?, withForce strength: RMFloatB) {
        if let sprite = object as? RMXSprite {
            self.throwItem(atSprite: sprite, withForce: strength)
        } else if let node = object as? RMXNode {
            self.throwItem(atSprite: node.sprite, withForce: strength)
        } else if let position = object as? RMXVector {
            self.throwItem(atPosition: position, withForce: strength)
        }
    }
    
    func throwItem(atSprite sprite: RMXSprite?, withForce strength: RMFloatB) {
        if let item = self.item {
            if let sprite = sprite {
                if sprite.rmxID != self.rmxID && sprite.rmxID != item.rmxID {
                    item.tracker.setTarget(target: sprite, speed: 10 * item.mass, impulse: true, willJump: false, doOnArrival: { (target) -> () in
                        RMSActionProcessor.explode(item, force: strength / 200, range: 500)
                        RMXTeam.challenge(self.attributes, defender: target!.attributes)
                        item.tracker.setTarget()
                    })
                    self.releaseItem()
                }
            }
        } else {
            RMXLog("Nothing to throw")
        }
    }
    
    func throwItem(force strength: RMFloatB) {
        if let itemInHand = self.item {
            var direction = self.forwardVector
            if self.isActiveCamera {
                let gradient = self.world.activeCamera.eulerAngles.x
                let mat = GLKMatrix4MakeRotation(Float(gradient), Float(1.0), 0.0, 0.0)
                direction = SCNVector3FromGLKVector3( GLKMatrix4MultiplyVector3WithTranslation(mat, SCNVector3ToGLKVector3( direction)))
            }
            itemInHand.applyForce(self.velocity + direction * strength * itemInHand.mass, impulse: false)
        }
        
    }
    
    func throwItem(atPosition target: RMXVector3, withForce strength: RMFloatB) {
        if let itemInHand = self.item {
            let direction = (target - itemInHand.position).normalised
            self.releaseItem()
            itemInHand.applyForce(self.velocity + direction * strength * itemInHand.mass, impulse: false)
        } else {
            RMXLog("Nothing to throw")
        }
    }
    
    @availability(*,deprecated=1)
    func throwItem(strength: RMFloatB = 1, var atNode targetNode: RMXNode? = nil, atPoint point: RMXVector? = nil) -> Bool { //, atTarget target: AnyObject? = nil) -> Bool {
        
        if let itemInHand = self.item {
            self.setItem(item: nil)
            var direction: RMXVector = self.forwardVector
            
            if let point = point {
                direction = (point - itemInHand.position).normalised
            } else if let rootNode = targetNode?.getRootNode(inScene: self.scene!) {
                if rootNode.rmxID != self.rmxID && rootNode.rmxID != itemInHand.rmxID {
                    let target = RMXSprite.rootNode(targetNode!, rootNode: self.scene!.rootNode)
                    
                    itemInHand.tracker.setTarget(target: target.sprite, speed: 10 * itemInHand.mass, impulse: true, willJump: false, doOnArrival: { (target) -> () in
                        RMSActionProcessor.explode(itemInHand, force: strength / 200, range: 500)
                        RMXTeam.challenge(self.attributes, defender: target!.attributes)
                        itemInHand.tracker.setTarget()
                    })
                    return true
                }
            } else if let target = targetNode {
                direction = (target.presentationNode().position - itemInHand.position).normalised
            }
            
            if self.isActiveCamera {
                let gradient = self.world.activeCamera.eulerAngles.x
                let mat = GLKMatrix4MakeRotation(Float(gradient), Float(1.0), 0.0, 0.0)
                direction = SCNVector3FromGLKVector3( GLKMatrix4MultiplyVector3WithTranslation(mat, SCNVector3ToGLKVector3( direction)))
            }
            
            if let body = itemInHand.node.physicsBody {
                if let target = targetNode {
                    if target.rmxID != self.rmxID && target.rmxID != itemInHand.rmxID && !target.isActiveSprite {
                        itemInHand.tracker.setTarget(target: target.sprite, speed: 10 * itemInHand.mass, impulse: true, willJump: false, doOnArrival: { (target) -> () in
                            RMSActionProcessor.explode(itemInHand, force: strength / 200, range: 500)
                            itemInHand.tracker.setTarget()
                        })
                        return true
                    }
                } else {
                    itemInHand.applyForce(self.velocity + direction * strength * itemInHand.mass, impulse: false)
                }
                if self.isActiveSprite {
                    self.world.interface.av.playSound(RMXInterface.THROW_ITEM, info: self.position)
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
            if world.hasGravity && newPos.y < itemRadius {
                newPos.y = itemRadius
            }
//            item.node.runAction(SCNAction.moveTo(newPos, duration: 1), forKey: "manipulate")
            item.setPosition(position: newPos)//, resetTransform: false)
           
        }
    }
    
    var isLocked: Bool = false
    private func setItem(item itemIn: RMXSprite?) {
        
        if let item = itemIn {
            if !item.isLocked { fatalError("item should be locked") }
            if  item.isActiveSprite && !self.canGrabPlayers { return  } //Prevent accidentily holding oneself
            if self.isWithinReachOf(item) {
                _itemInHand = item
                _itemInHand?.holder = self
                if let body = _itemInHand?.node.physicsBody {
                    body.type = .Kinematic
                }
                return
            } else {
                let speed = item.speed
                if !item.tracker.hasTarget {
                    item.tracker.setTarget(target: self, speed: 400 * (item.mass + 1), willJump: false, doOnArrival: { (target) -> () in
                        self.grab(item)
                        item.tracker.setTarget()
                        item.speed = speed
                    })
                }
                item.isLocked = false
            }
        } else {
            if let item = self.item {
                if let body = _itemInHand?.node.physicsBody {
                    body.type = .Dynamic
                }
                item.holder = nil
                _itemInHand = nil
                item.isLocked = false
            }
        }
    }
    
    func isWithinReachOf(item: RMXSprite) -> Bool{
        return self.distanceTo(item) <= self.armLength * 3
    }
    
    func grab(object: AnyObject?) {
        if let node = object as? RMXNode {
            self.grab(node.sprite)
        } else if let sprite = object as? RMXSprite {
            self.grab(sprite)
        }
    }
    
    ///returns true if item is now held (even if it is not a new item)
    func grab(item: RMXSprite?) -> Bool {
        if self.hasItem { return true }
        if let item = item {
            if item.isLocked {
                return false
            } else {
                item.isLocked = true
                if item.rmxID == self.rmxID {
                    item.isLocked = false
                    return false
                }
                self.setItem(item: item)
                return self.hasItem
            }
        }
        return false
    }
    
    func releaseItem() {
        if self.hasItem {
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

    var useWorldCoordinates: Bool {
        return self.type == .PLAYER && !self.world.activeCamera.isPOV //_useWorldCoordinates
    }
    
    
    func accelerateForward(v: RMFloatB) {
        if self.useWorldCoordinates {
            self.applyForce(self.world.forwardVector * v * self.speed, atPosition: self.front)
        } else {
            self.applyForce(self.forwardVector * v * self.speed)
        }
    }
    
    func accelerateUp(v: RMFloatB) {
        if self.useWorldCoordinates {
            self.applyForce(self.world.upVector * v * self.speed, atPosition: self.front)
        } else {
            self.applyForce(self.upVector * v * self.speed)
        }
    }
    
    
    func accelerateLeft(v: RMFloatB) {
        if self.useWorldCoordinates {
            self.applyForce(self.world.leftVector * v * self.speed, atPosition: self.front)
        } else {
            self.applyForce(self.leftVector * v * self.speed)
        }
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
        return Float(self.node.physicsBody!.mass) * self.world.gravity.length * 2
    }
    
    func distanceTo(point: RMXVector3) -> RMFloatB{
        return RMFloatB((self.position - point).length)
    }
    
    func distanceTo(object:RMXSprite) -> RMFloatB{
        return self.distanceTo(object.position)
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
    





    
    func addAi(ai: AiBehaviour) {
        self.behaviours.append(ai)
        //self.behaviours.last?()
    }
    
    
    var viewPoint: RMXPoint {
        return self.position - self.forwardVector
    }
    
    
    
    
    var isGrounded: Bool {
        return self.velocity.y == 0 && self.world.hasGravity
    }
    
    var upThrust: RMFloatB {
        return self.node.physicsBody!.velocity.y
    }

    
    var upVector: RMXVector {
        return self.transform.up
    }
    
    var leftVector: RMXVector {
        
        return self.transform.left
    }
    
    var forwardVector: RMXVector {
        return self.transform.forward
    }

    
        
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
    
    
    func setColor(#color: NSColor){
        
        self.node.geometry?.firstMaterial!.diffuse.contents = color
        self.node.geometry?.firstMaterial!.diffuse.intensity = 1
        self.node.geometry?.firstMaterial!.specular.contents = color
        self.node.geometry?.firstMaterial!.specular.intensity = 1
        self.node.geometry?.firstMaterial!.ambient.contents = color
        self.node.geometry?.firstMaterial!.ambient.intensity = 1
        self.node.geometry?.firstMaterial!.transparent.intensity = 0
        
    }
    
    func makeAsSun(rDist: RMFloatB = 1000, rAxis: RMXVector3 = RMXVector3Make(1,0,0)) -> RMXSprite {
        //        self.type = .BACKGROUND
        
        
        
        self.rotationSpeed = 1 * PI_OVER_180 / 10
        
        
        
        self.rAxis = rAxis
        self.node.pivot.m43 = -rDist
        
        
        return self
    }
    
    
}






extension RMXSprite : RMXLocatable {
    
    func getPosition() -> RMXVector {
        return self.position
    }
}
