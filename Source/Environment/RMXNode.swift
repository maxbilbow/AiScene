                //
//  RMXNode.swift
//  RattleGL3-0
//
//  Created by Max Bilbow on 10/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//
import GLKit
import Foundation
//import RMXKit
import SceneKit

                
extension RMXNode {
    var isPlayerOrAi: Bool {
        return self.isActor
    }
}

                
//@available(OSX 10.9, *)
class RMXNode : SCNNode, RMXTeamMember, RMXPawn, RMXObject {

    static var current: RMXNode? {
        return RMXScene.current.activeSprite
    }
    
    private let _rmxid: Int = RMX.COUNT++
    var rmxID: Int? {
        return _rmxid
    }
    
    lazy var tracker: RMXTracker = RMXTracker(sprite: self)


    var uniqueID: String? {
        return "\(self.name!)/\(self.rmxID!)"
    }
    
    
    var world: RMXWorld {
        return self.scene
    }
    
    var aiDelegate: RMXAiDelegate?
    
    var type: RMXSpriteType
    
    private var _spriteLogic: Array<AiBehaviour> = []
    
    var logic: Array<AiBehaviour> {
        return _spriteLogic
    }

    private var _scene: RMXScene
    
    var print: String {
        return self.uniqueID!
    }
    
    var holder: RMXNode?
    
    var attributes: SpriteAttributes!
    
    var scene: RMXScene {
        return self._scene//.scene
    }
      
    
    var isUnique: Bool
    
    var hasFriction: Bool {
        return self.physicsBody?.friction != 0
    }
    
    private var _rotation: RMFloat = 0

    var shapeType: ShapeType


    lazy var timer: RMXTimer? = RMXSpriteTimer(sprite: self)
    
    private func _updateName(ofNode node: SCNNode, oldName: String?) {
        
        for node in node.childNodes {
            if node.name != nil && oldName != nil {
                
                node.name = node.name?.stringByReplacingOccurrencesOfString(oldName!, withString: self.uniqueID!, options: NSStringCompareOptions.LiteralSearch, range: nil)
                
                _updateName(ofNode: node, oldName: oldName)
            } else {
                node.name = self.uniqueID
                
            }
        }
        
    }
    
    
    func updateName(name: String? = nil) {
        let oldName = self.name
        self.name = name != nil && !name!.isEmpty ? name! : "Ent"
        _updateName(ofNode: self, oldName: oldName)
    }
    

    
    var length: RMFloat {
        let bounds = self.boundingBox;
        return bounds.max.z - bounds.min.z
    }
    
    var width: RMFloat {
        let bounds = self.boundingBox;
        return bounds.max.x - bounds.min.x
    }
    
    var height: RMFloat {
        let bounds = self.boundingBox;
        return bounds.max.y - bounds.min.y
    }
    
    var bottom: SCNVector3 {
        return self.boundingBox.min * self.upVector// * self.scale.y
    }
    
    var top: SCNVector3 {
        return self.boundingBox.max * self.upVector// * self.scale.y
    }
    
    var front: SCNVector3 {
        return self.boundingBox.max * self.forwardVector// * self.scale.z
    }
    
    var back: SCNVector3 {
        return self.boundingBox.min * self.forwardVector// * self.scale.z
    }
    
    var left: SCNVector3 {
        return self.boundingBox.min * self.leftVector// * self.scale.x
    }
    
    var right: SCNVector3 {
        return self.boundingBox.max * self.leftVector// * self.scale.x
    }
    
    
    var startingPoint: SCNVector3?//?// = SCNVector3Zero
    
    var isLocalPlayer: Bool {
        return self.rmxID == RMXNode.current?.rmxID
    }
    
    ///Set automated rotation (used mainly for the sun)
    ///@todo create a behavior protocal/class instead of fun pointers.
    var rAxis = SCNVector3Make(0,0,1)
    
    var isInWorld: Bool {
        return RMFloat(self.getPosition().length) < self.scene.radius
    }
    
    
    var jumpStrength: RMFloat = 1
    var squatLevel:RMFloat = 0
//    private var _prepairingToJump: Bool = false
//    private var _goingUp:Bool = false
//    private var _ignoreNextJump:Bool = false
    
    
    private var _itemInHand: RMXNode?
    var item: RMXNode? {
        return _itemInHand
    }

    
    convenience init(world: RMXScene = RMXScene.current, type: RMXSpriteType = .ABSTRACT, shape: ShapeType = .NULL){
        self.init(inWorld: world, type: type, shape: shape)
    }
    
    convenience init(inWorld world: RMXScene, type: RMXSpriteType = .PASSIVE, shape: ShapeType = .CUBE, color: RMColor? = RMX.randomColor(), unique: Bool = false) {
        self.init(inWorld: world, geometryNode: RMXModels.getNode(shapeType: shape, color: color, inWorld: world), type: type, shape: shape, unique: unique)
    }
    
    deinit {
        self.holder?.releaseItem()
        self.releaseItem()
        self.tracker.abort()
        self.aiDelegate = nil
        self.removeCollisionActions()
        //        self.followers.removeAll(keepCapacity: false)
        self.attributes = nil
        self.removeFromParentNode()
    }
    
    private var safeInit = false
    var arm: SCNNode?
    init(inWorld scene: RMXScene, geometryNode: SCNNode?, type: RMXSpriteType, shape: ShapeType = .CUBE, unique: Bool, safeInit: Bool = false){
        self._scene = scene
        self.type = type
        self.shapeType = shape
        self.isUnique = unique
        //        self.geometryNode = node
        super.init()
        if let node = geometryNode {
            self.setGeometryNode(node)
        } else {
            self.setGeometryNode(RMXModels.getNode(shapeType: shape))
        }
        self.attributes = SpriteAttributes(sprite: self)
        self.safeInit = safeInit
        self.spriteDidInitialize()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    ///could cause animation failure if deRetire() does not fire
    func reinitialize() {
        self.setPosition(self.startingPoint ?? self.getPosition())
        self.validate()
        self.attributes.retire()
        RMLog("could cause animation failure if deRetire() does not fire")
    }
    
    
    
    func spriteDidInitialize(){
        switch self.type {
        case .PLAYER, .AI, .PASSIVE:
            self._spriteLogic.append(self.tracker.headToTarget)
            self._spriteLogic.append((self.timer as! RMXSpriteTimer).activate)
            self.arm = RMXModels.getNode(shapeType: .SPHERE, radius: 2)
            self.arm?.physicsBody = SCNPhysicsBody.staticBody()
            self.arm?.position = self.front
            self.addChildNode(self.arm!)
            self.setMass()
            
            break
        case _ where self.isActor:
            self._spriteLogic.append(self.manipulate)
            break
        default:
            break
        }
        
        if self.isActor && !self.safeInit {
            self.addCameras()
        }
        if self.aiDelegate == nil && self.requiresAI {
            self.aiDelegate = RMXAi(pawn: self)
        }
        //        RMXBrain.giveBrainTo(self)
        self.updateName()
        self.setSpeed()
        //        NSLog(self.speed.toData())
        self.scene.insertChild(self, andNode: true)
        
        if type != .PLAYER && type != .AI {
            self.attributes.setTeamID(RMXNode.NO_COLLISIONS)
        } else {
            self.attributes.setTeamID(RMXNode.TEAM_ASSIGNABLE)
        }
        
        
        
        
    }
    
    var isHoldingItem: Bool {
        return self.arm?.childNodes.count == 2
    }
    
   
    
    func setSpeed(speed: RMFloat? = nil, rotationSpeed: RMFloat? = nil) {
        
        if speed == nil && rotationSpeed == nil {
            switch self.type {
            case _ where self.type == .PLAYER || self.type == .AI:
                self.physicsBody?.damping = 0.5
                self.physicsBody?.angularDamping = 0.99
            case .PASSIVE:
                self.physicsBody?.damping = 0.5
                self.physicsBody?.angularDamping = 0.8
                break
            case .BACKGROUND:
                self.physicsBody?.restitution = 0.1
                self.physicsBody?.damping = 1000
                self.physicsBody?.angularDamping = 1000
                break
            case _ where !self.isActor:
                self.attributes.setTeamID("\(-1)")
                break
            default:
                break
            }
        }
        let damping: CGFloat = self.physicsBody?.damping ?? 0.1
        _speed = speed ?? 100 * RMFloat((self.physicsBody?.mass ?? 1) * damping) * 2
        _rotationSpeed = rotationSpeed ?? 15 * RMFloat(self.physicsBody?.mass ?? 1) // (1 - rDamping)
        
    }
    
    func validate() {
        if self.scene.hasGravity && self.scene.earth?.getPosition().y > self.getPosition().y {
            //                NSLog("reset \(sprite.name)")
            let lim = self.scene.radius
            self.setPosition(SCNVector3Random(lim, min: -lim, setY: self.scene.ground + 100), resetTransform: true)
            self.attributes.retire()
        }
    }
    
    var willCollide: Bool {
        return self.attributes.teamID != "-2"
    }
    
    
    static let NO_COLLISIONS: String = "-2"
    static let TEAM_ASSIGNABLE: String = "0"
    static let TEAMLESS_MAVERICS: String = "-1"
    
    var requiresAI: Bool {
        return self.isActor || self.type == .PASSIVE
    }
    
    
    
    
    
    var theta: RMFloat = 0
    var phi: RMFloat = 0//90 * PI_OVER_180
    var roll: RMFloat = 0//90 * PI_OVER_180
    //    var orientation = RMXMatrix4Identity
    
    private var _rotationSpeed: RMFloat = 0
    var rotationSpeed: RMFloat {
        return _rotationSpeed
    }
    
    private var _speed: RMFloat = 0
    var speed: RMFloat {
        return _speed
    }
    var canGrabPlayers: Bool = false
    
    //    var acceleration: SCNVector3?// = SCNVector3Zero
    private let _zNorm = 90 * PI_OVER_180
    
    

 

    var cameras: Array<SCNNode> = Array<SCNNode>()
    
    var isActor: Bool {
        return self.type == RMXSpriteType.PLAYER || self.type == RMXSpriteType.AI
    }
    
    
    internal func addCameras() {
        if self.cameras.count == 0 {
            if self.type == .PLAYER {
                RMXCamera.headcam(self)
                RMXCamera.followCam(self, option: CameraOptions.FIXED)
                RMXCamera.followCam(self, option: CameraOptions.FREE)
            } else {
                RMXCamera.headcam(self)
                RMXCamera.followCam(self, option: CameraOptions.FIXED)
            }
            
            
        } else {
            RMLog("cameras already set up for \(self.name)")
        }
        
    }
    
    
    
    //    func updateCoordinateSystem() {
    //        _useWorldCoordinates = !self.scene.activeCamera.isPOV
    //    }
    
    
    
    ///Used when checkin whether or not to use local or global coordinates when controlling
    var isActiveCamera: Bool {
        return (self.scene.activeCamera as? RMXCameraNode)?.rmxID == self.rmxID
    }
    
    private var _isTargetable: Bool?
    
    var isTargetable: Bool {
        return _isTargetable ?? ( self.type != .BACKGROUND && self.type != .ABSTRACT )
    }
    
    ///object as Node: thrown in direction of node
    ///object as Sprite: thrown and tracked to sprite
    ///object as position: thown in direction
    func throwItem(at object: AnyObject?, withForce strength: RMFloat, tracking: Bool) -> Bool {
        if let node = object as? RMXNode {
            if !node.isTargetable {
                RMLog(" Sprite: \(node.name) is not targetable", sender: self, id: "THROW")
                return false
            }
            if tracking {
                RMLog("SPRITE -> SPRITE: \(node.name)", sender: self, id: "THROW")//, sender: self)
                return self.throwItem(atPawn: node, withForce: strength)
            } else {
                RMLog("NODE -> Position: \(node.getPosition().print)", sender: self, id: "THROW")//, sender: self)
                return self.throwItem(atPosition: node.getPosition(), withForce: strength)
            }
        } else if let node = object as? SCNNode {
            if !(node.rmxNode?.isTargetable ?? true){
                RMLog(" Sprite: \(node.name) is not trackable", sender: self, id: "THROW")
                return false
            }
            if tracking {
                RMLog("NODE -> Sprite: \(node.pawn?.name)", sender: self, id: "THROW")//, sender: self)
                return self.throwItem(at: node.pawn, withForce: strength, tracking: tracking)
            } else {
                RMLog("NODE -> Position: \(node.getPosition())", sender: self, id: "THROW")//, sender: self)
                return self.throwItem(atPosition: node.getPosition(), withForce: strength)
            }
        } else if let position = object as? SCNVector3 {
            RMLog("VECTOR -> Position: \(position.print)", sender: self, id: "THROW")
            return self.throwItem(atPosition: position, withForce: strength)
        } else {
            RMLog("UNKNOWN Object: \(object?.description)", sender: self, id: "THROW")//, sender: self)
            return self.throwItem(force: strength)
        }
    }
    
    private func throwItem(atPawn pawn: RMXNode?, withForce strength: RMFloat = 1) -> Bool{
        if let itemInHand = self.item {
            if let sprite = pawn {
                if sprite.rmxID == self.rmxID || sprite.rmxID == itemInHand.rmxID {
                    return false
                }
                RMLog("Item thrown at sprite (force: \(strength.print))", sender: self, id: "THROW")
                self.releaseItem()
                itemInHand.tracker.setTarget(sprite, speed: strength, asProjectile: true, impulse: true, willJump: false, doOnArrival: { (target) -> () in
                    RMXTeam.challenge(self.attributes, defender: target!.attributes, doOnWin: nil)
                })
                RMXTeam.throwChallenge(self, projectile: itemInHand)
                
            } else {
                RMLog(" *Item thrown at sprite (force: \(strength.print)) but nothing to throw", sender: self, id: "THROW")
            }
        } else {
            RMLog("Nothing to throw",sender: self, id: SPRITE_TYPE)
        }
        return self.item == nil
    }
    
    private lazy var SPRITE_ACTIONS: String = self.uniqueID!
    private  var SPRITE_TYPE: String {
        return "Sprites: \(self.type.rawValue)"
    }
    
    
    
    func throwItem(force strength: RMFloat) -> Bool {
        if let itemInHand = self.item {
            RMLog("Item thrown with force: \(strength.print)", sender: self, id: "THROW")
            let direction = self.forwardVector
//            if self.isLocalPlayer {
//                let gradient = -self.scene.activeCamera.eulerAngles.x
//                let mat = GLKMatrix4MakeRotation(Float(gradient), Float(1.0), 0.0, 0.0)
//                direction = SCNVector3FromGLKVector3( GLKMatrix4MultiplyVector3WithTranslation(mat, SCNVector3ToGLKVector3( direction)))
//            }
            self.releaseItem()
            RMXTeam.throwChallenge(self, projectile: itemInHand)
            let force = itemInHand.suggestedThrowingForce(strength < 150 ? 150 : strength)
            itemInHand.applyForce(direction * force, impulse: true)
        } else {
            RMLog(" *Item thrown with force but nothing to throw: \(strength.print)", sender: self, id: "THROW")
        }
        return self.item == nil
        
    }
    func suggestedThrowingForce(force: RMFloat = 1) -> RMFloat {
        let damping = (self.physicsBody?.damping ?? 0.1 ) + 1
        let mass = self.physicsBody?.mass ?? 1
        return RMFloat(damping * mass) * force
    }
    
    func throwItem(atPosition target: SCNVector3?, withForce strength: RMFloat) -> Bool {
        if let target = target {
            if let itemInHand = self.item {
                let direction = (target - itemInHand.getPosition())//.normalised
                self.releaseItem()
                RMXTeam.throwChallenge(self, projectile: itemInHand)
                let force: RMFloat = itemInHand.suggestedThrowingForce()
                itemInHand.applyForce( direction * force, impulse: true)
                RMLog("Throw Item thrown from: \(itemInHand.getPosition().print) to \(target.print)", sender: self, id: "THROW")
                RMLog("          in Direction: \(direction.print))", sender: self, id: "THROW")
                RMLog("            with force: \((direction * force).print))", sender: self, id: "THROW")
            } else {
                RMLog(" *Item thrown in direction: \(target.print) but Nothing to throw", sender: self, id: "THROW")
            }
        }
        return self.item == nil
    }
    
    
    
    func manipulate(node: AnyObject! = nil) -> Void {
        if self.isHoldingItem && self.item?.physicsBody?.type != .Dynamic {
            var newPos = self.getPosition() + self.forwardVector * (self.length / 2 + RMFloat(self.item!.radius * 0.5))
            if let earth = self.scene.earth as? RMXNode {
                let minHeight:RMFloat = earth.top.y + earth.getPosition().y + RMFloat(self.item!.radius)
                if self.scene.hasGravity && newPos.y < minHeight {
                    newPos.y = minHeight
                }
            }
            self.item!.setPosition(newPos)//, resetTransform: false)
            RMLog("\(self.name!) is holding a non-dynamic body", sender: self, id: "MISC")
        }
    }
    
    private var _arm: SCNPhysicsBehavior?
    
    func setMass(mass: CGFloat? = nil) {
        self.physicsBody?.mass = mass ?? 4 * PI_CG * self.radius * self.radius
    }
    
    enum GrabbingRule {
        case Yes, No, Tractor, HeadTowards
    }
    
    func isAbleToGrab(node: RMXNode) -> GrabbingRule {
        if node.isLocked || node.type != .PASSIVE || self.isHoldingItem || node == self {
            return .No
        }
        if isWithinReachOf(node) {
            return .Yes
        } else if isWithinSightOf(node) {
            return .Tractor
        } else {
            return .HeadTowards
        }
    
    }
    
    var isLocked: Bool = false
    private func setItemInHand(node: SCNNode?) -> Bool {
        if let itemIncoming = node as? RMXNode ?? node?.rmxNode {
            switch self.isAbleToGrab(itemIncoming) {
            case .Yes:
                
            }
            if self.isWithinReachOf(itemIncoming) {
                itemIncoming.removeCollisionActions()
                //                itemIncoming.followers.removeAll(keepCapacity: false) ///TODO: this may not be necessary
                
                //Used to make body static here
                if itemIncoming.arm != nil {
                    if !itemIncoming.isActor { ///reduce mass to 1% of sprite unless its another player
                        itemIncoming.setMass(self.physicsBody!.mass * 0.01)
                        itemIncoming.physicsBody?.restitution = 0.01
                        itemIncoming.physicsBody?.friction = 0.01
                    }
                    _itemInHand = itemIncoming
                    itemIncoming.holder = self
                    _arm = SCNPhysicsBallSocketJoint(bodyA: self.physicsBody!, anchorA: self.arm!.getPosition(), bodyB: itemIncoming.physicsBody!, anchorB: itemIncoming.arm!.getPosition()) //+ SCNVector3Make(item.arm.radius))
                    
                    self.scene.physicsWorld.addBehavior(_arm!)
                }
                //joint
                return true
            } else {
                ///Player can use tractor beam function on passive objects
                itemIncoming.isLocked = false
                if (self.isLocalPlayer || self.isWithinSightOf(itemIncoming)) && itemIncoming.type == .PASSIVE { // || (self.isLocalPlayer && itemIncoming.isActor ) { ///active player can grab anything for now
                    itemIncoming.tracker.setTarget(self, willJump: false, asProjectile: true, impulse: true, doOnArrival: { (target) -> () in// speed: 10 * item.mass
                        self.setItemInHand(itemIncoming)
                        //                        item.tracker.removeTarget()
                    })
                    return true
                }
                
                return false
            }
        } else if let itemInHand = self._itemInHand {
            
            //this used to make dynamic again here
            //                itemInHand.physicsBody?.type = .Dynamic
            self._itemInHand = nil
            self.scene.physicsWorld.removeBehavior(_arm!)
            if !itemInHand.isActor {
                itemInHand.setMass()
                itemInHand.physicsBody?.restitution = 0.5
                itemInHand.physicsBody?.friction = 0.5
            }
            _arm = nil
            itemInHand.holder = nil
            //            itemInHand.followers.removeAll(keepCapacity: false)
            itemInHand.isLocked = false
            
            return true
        }
        else {
            return false
        }
    }
    
    func isWithinReachOf(item: RMXNode) -> Bool{
        return self.distanceToSprite(item) <= RMFloat(self.radius + item.radius) * 2
    }
    
    func isWithinSightOf(item: RMXNode) -> Bool{
        return self.distanceToSprite(item) <= RMFloat(self.scene.radius) / 4
    }
    
    func grabItem(object: AnyObject?) -> Bool {
        if self.item != nil { return false }
        if let sprite = object as? RMXNode {
            return self.setItemInHand(sprite)
        } else if object?.isKindOfClass(SCNNode) ?? false {
            return self.setItemInHand((object as! SCNNode).rmxNode)
        }
        return self.item != nil
    }
    
    
    func releaseItem() {
        self.setItemInHand(nil)
    }
    
    
 

    
    func jump() {
        if self.getPosition().y < self.height * 10 {
            let jumpStrength = fabs(RMFloat(self.weight) * self.jumpStrength)
            self.applyForce(SCNVector3Make(0, y: jumpStrength, z: 0), impulse: true)
        }
    }
    
    
    @available(*,deprecated=0,message="Use rotate:theta:phi:roll instead")
    func lookAround(theta t: RMFloat? = nil, phi p: RMFloat? = nil, roll r: RMFloat? = nil) {
        self.rotate(theta: t, phi: p, roll: r)
    }
    
    func rotate(theta t: RMFloat? = nil, phi p: RMFloat? = nil, roll r: RMFloat? = nil) {
        
        if let theta = t {
            let axis = self.upVector
            let speed = self.rotationSpeed * theta
            self.physicsBody?.applyTorque(SCNVector4Make(axis.x,axis.y,axis.z, -speed), impulse: false)
        }
        if let phi = p {
            let axis = self.leftVector
            let speed = self.rotationSpeed * phi
            self.physicsBody?.applyTorque(SCNVector4Make(axis.x,axis.y,axis.z, speed), impulse: false)
        }
        if let roll = r {
            let axis = self.forwardVector
            let speed = self.rotationSpeed * roll
            self.physicsBody?.applyTorque(SCNVector4Make(axis.x,axis.y,axis.z, -speed), impulse: false)
            //            self.rmxNode.transform *= RMXMatrix4MakeRotation(speed * 0.0001, SCNVector3Make(0,0,1))
        }
        
    }
    
    var isPOV: Bool {
        return self.scene.activeCamera.isPointOfView// && self.isLocalPlayer
    }

    func accelerate(left: RMFloat? = nil, up: RMFloat? = nil, forward: RMFloat? = nil) {
        self.accelerate(.MOVE_LEFT, speed: left)
        self.accelerate(.MOVE_UP, speed: up)
        self.accelerate(.MOVE_FORWARD, speed: forward)
    }
    
    private func accelerate(direction: UserAction, speed: RMFloat?) {
        if let speed = speed {
            let isPov = self.isPOV
            var vector: SCNVector3!; let position: SCNVector3 = isPov ? SCNVector3Zero : self.front
            switch direction {
            case .MOVE_LEFT:
                vector = (isPov ? self.leftVector : self.scene.leftVector) * speed * self.speed
                break
            case .MOVE_UP:
                vector = (isPov ? self.upVector : self.scene.upVector) * speed * self.speed
                break
            case .MOVE_FORWARD:
                vector = (isPov ? self.forwardVector : self.scene.forwardVector) * speed * self.speed
                break
            default:
                fatalError()
            }
            self.physicsBody?.applyForce(vector, atPosition: position, impulse: false)
        }
    }

    /*private func accelerateForward(v: RMFloat) {
        if !self.isPOV {
            self.applyForce(self.scene.forwardVector * v * self.speed, atPosition: self.front)
        } else {
            self.applyForce(self.forwardVector * v * self.speed)
        }
    }
    
    private func accelerateUp(v: RMFloat) {
        if !self.isPOV {
            self.applyForce(self.scene.upVector * v * self.speed, atPosition: self.front)
        } else {
            self.applyForce(self.upVector * v * self.speed)
        }
    }
    
    
    private func accelerateLeft(v: RMFloat) {
        if !self.isPOV {
            self.applyForce(self.scene.leftVector * v * self.speed, atPosition: self.front)
        } else {
            self.applyForce(self.leftVector * v * self.speed)
        }
    }
    */
    
    func completeStop(){
        self.stop()
        self.physicsBody?.velocity = SCNVector3Zero
    }
    
    
    ///Stops all acceleration foces, not velocity
    func stop(){
        self.physicsBody?.clearAllForces()
        //        self.acceleration = nil
    }
    
    var weight: CGFloat {
        return self.physicsBody!.mass * CGFloat(self.scene.gravity.length * 2)
    }
    
    func distanceToPoint(point: SCNVector3) -> RMFloat{
        return RMFloat((self.getPosition() - point).length)
    }
    
    func distanceToSprite(sprite:RMXNode) -> RMFloat{
        return self.distanceToPoint(sprite.getPosition())
    }
    
    var velocity: SCNVector3 {
        if let body = self.physicsBody {
            return body.velocity //body.velocity
        } else {
            return SCNVector3Zero
        }
    }
    
    private var _startingPosition: SCNVector3?
    func setPosition(position: SCNVector3? = nil, resetTransform: Bool = true){
        self.transform = self.transform
        if let position = position {
            self.position = position
            if self._startingPosition == nil {
                self._startingPosition = position
            }
        }
        if resetTransform {
            self.resetTransform()
        }
    }
    
        
    func addBehaviour(behaviour: AiBehaviour) {
        self._spriteLogic.append(behaviour)
        if self.aiDelegate == nil {
            self.aiDelegate = RMXAi(pawn: self)
        }
    }
    
    var upVector: SCNVector3 {
        return self.presentationNode().transform.up
    }
    
    var leftVector: SCNVector3 {
        return self.presentationNode().transform.left
    }
    
    var forwardVector: SCNVector3 {
        return self.presentationNode().transform.forward
    }
    
    
    func setColor(color color: RMColor){
        
        self.geometry?.firstMaterial!.diffuse.contents = color
        self.geometry?.firstMaterial!.diffuse.intensity = 1
        self.geometry?.firstMaterial!.specular.contents = color
        self.geometry?.firstMaterial!.specular.intensity = 1
        self.geometry?.firstMaterial!.ambient.contents = color
        self.geometry?.firstMaterial!.ambient.intensity = 1
        self.geometry?.firstMaterial!.transparent.intensity = 0
        
    }
    
    func makeAsSun(rDist: RMFloat = 1000, rAxis: SCNVector3 = SCNVector3Make(1,y: 0,z: 0)) -> RMXNode {
        //        self.type = .BACKGROUND
        
        
        
        self.setSpeed(rotationSpeed: 1 * PI_OVER_180 / 10)
        
        
        
        self.rAxis = rAxis
        self.pivot.m43 = -rDist
        
        
        return self
    }

   
    
    func addCollisionAction(named name: String, removeAfterTime time: NSTimeInterval = 3, action: AiCollisionBehaviour) {
        self.collisionActions[name] = action
        if time > 0 {
            NSTimer.scheduledTimerWithTimeInterval(time, target: self, selector: "removeDueCollisionAction:", userInfo: name, repeats: false)
        }
    }
    
    
    
    func removeDueCollisionAction(timer: NSTimer) {
        
        if let name = timer.userInfo as? String {
            RMLog("Collision Action: \(name) was removed from \(self.name!)", id: "Collisions")
            self.collisionActions.removeValueForKey(name)
        }
    }
    

    func removeCollisionActions() {
        self.collisionActions.removeAll(keepCapacity: true)
    }

    func setGeometryNode(node: SCNNode) {
        node.name = "geometry"
    
        
        self.addChildNode(node)
        if node.geometry is SCNFloor {
            node.physicsBody = SCNPhysicsBody.staticBody()
        }
        switch self.type {
        case _ where self.isActor || self.type == .PASSIVE:
            self.physicsBody = SCNPhysicsBody.dynamicBody()
            self.physicsBody?.friction = 0.1
//            self.physicsBody?.rollingFriction = 0.1
            break
        case .AI, .PASSIVE:
            self.physicsBody?.damping = 0.3
            self.physicsBody?.angularDamping = 0.2
            //            self.physicsBody?.restitution = 0.1
        case _ where self.isActor:
            self.physicsBody?.damping = 0.5
            self.physicsBody?.angularDamping = 0.5
            break
        case .PLAYER:
            self.physicsBody?.angularDamping = 0.99
            break
        case .BACKGROUND:
//            if !(node.geometry is SCNFloor) {
                self.physicsBody = SCNPhysicsBody.staticBody()
//            }
            self.physicsBody!.friction = 0.01
            break
        case .KINEMATIC:
            self.physicsBody = SCNPhysicsBody.kinematicBody()
            break
        case .ABSTRACT, .CAMERA:
            self.physicsBody?.mass = 0
            break
        default:
            fatalError()
        }
        

        
        
        self.setMass()
        
        switch self.shapeType {
        case .BOBBLE_MAN:
            
            break
        case .NULL:
            
            break
        default:
            break
        }
        

    }


    var geometryNode: SCNNode? {
        return self.childNodeWithName("geometry", recursively: false)
    }
    
    private var collisionActions: [String:AiCollisionBehaviour] = [:]
    
    func collisionAction(contact: SCNPhysicsContact) {
        for collision in self.collisionActions {
            collision.1(contact)
        }
    }
    
    override func runAction(action: SCNAction, forKey key: String?, completionHandler block: (() -> Void)?) {
        super.runAction(action, forKey: key, completionHandler: block)
    }
    
}
            
                
                
@available(OSX 10.10, *)
extension RMXNode {
    
    
    
    func getGeometry() -> SCNGeometry? {
        return self.geometry ?? self.geometryNode?.geometry
    }

    func applyForce(direction: SCNVector3, atPosition: SCNVector3? = nil, impulse: Bool = false) {
        if let atPosition = atPosition {
            self.physicsBody?.applyForce(direction, atPosition: atPosition, impulse: impulse)
        } else {
            self.physicsBody?.applyForce(direction, impulse: impulse)
        }
    }
    
    func resetTransform() {
        self.physicsBody?.resetTransform()
    }
   
}





