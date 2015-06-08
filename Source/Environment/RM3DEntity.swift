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



protocol RMXSpriteManager {
//    
}

extension SCNPhysicsContact {
    func getDefender(forChallenger challenger: RMXSprite) -> SCNNode {
        return self.nodeA == challenger.node ? nodeB : nodeA
    }
}


class RM3DEntity : RMXTeamMember, RMXUniqueEntity, RMXObject {
    lazy var tracker: RMXTracker = RMXTracker(sprite: self)
//    var hitTarget = false
//    var target: RMXSprite?
//    var doOnArrival: ((sender: RMXSprite, target: AnyObject)-> AnyObject?)?

    var node: RMXNode {
        return _rmxNode
    }
    
    var uniqueID: String? {
        return "\(self._name)/\(self.rmxID!)"
    }
    
    var print: String {
        return self.uniqueID!
    }
    
    var holder: RMXSprite?
    
    @availability(*,deprecated=1)
    var isHeld: Bool {
        return self.holder != nil
    }
    
    var aiDelegate: RMXAiDelegate?
    
    var attributes: SpriteAttributes!
    
    var children: [RMXSprite] = []
    
    var hasChildren: Bool {
        return self.children.isEmpty
    }

    private var _useWorldCoordinates = false
    
    var scene: RMXScene? {
        return self.world//.scene
    }
    var radius: RMFloat {
        
       // let radius = RMXVector3Length(self.boundingBox.max * self.scale)
        return self.boundingSphere.radius //* RMFloat(self.scale.average)//radius
    }

    lazy var rmxID: Int? = RMX.COUNT++
    var isUnique: Bool
    
    var hasFriction: Bool {
        return self.physicsBody?.friction != 0
    }
    
    private var _rotation: RMFloat = 0
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
    
    
//    var node: SCNNode {
//        return self.geometryNode ?? rmxNode
//    }
    
   
//        {
//        return _node
//    }
    
    private var _rmxNode: RMXNode!
    
    lazy var timer: RMXSpriteTimer = RMXSpriteTimer(sprite: self)
    
    var name: String? {
        return self.uniqueID!
    }
    
//    var centerOfView: RMXPoint {
//        return self.position + self.forwardVector// * self.actions.reach
//    }
    
    private var _name: String = ""
    
    
    private func _updateName(ofNode node: SCNNode, oldName: String?) {
        for node in node.childNodes {
            if let node = node as? SCNNode {
                if node.name != nil && oldName != nil {
                    
                    node.name = node.name?.stringByReplacingOccurrencesOfString(oldName!, withString: self.uniqueID!, options: NSStringCompareOptions.LiteralSearch, range: nil)
                    
                    _updateName(ofNode: node, oldName: oldName)
                } else {
                    node.name = self.uniqueID
                    
                }
            }
        }
    }

    
    func setName(name: String? = nil) {
        let oldName = self.name
        self._name = name != nil && !name!.isEmpty ? name! : "Ent"
        self.node.name = self._name
        _updateName(ofNode: self.node, oldName: oldName)
//        NSLog("\(self.name) -- \(self.rmxNode.name!)")
        
    }

    var altitude: RMFloat {
        return RMFloat(self.position.y)
    }
    
    func setAltitude(y: RMFloat, resetTransform: Bool = true) {
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
    
    func isHolding(node: SCNNode?) -> Bool{
        return self.item?.rmxID == node?.rmxID
    }
    
    
    private var _reach: RMFloat?
    
    var armLength: RMFloat {
        return self.radius + ( self.hasItem ? item!.radius : 0 )
//        let reach = _reach ?? self.length / 2
//        if let item = self.item {
//            return reach + item.radius
//        } else {
//            return reach + 1
//        }
    }
    
    var length: RMFloat {
        return self.boundingBox.max.z * 2 // * self.scale.z
    }
    
    var width: RMFloat {
        return self.boundingBox.max.x * 2//* self.scale.x
    }
    
    var height: RMFloat {
        return self.boundingBox.max.y * 2//* self.scale.y
    }
    
    var bottom: RMXVector {
        return self.boundingBox.min * self.upVector// * self.scale.y
    }
    
    var top: RMXVector {
        return self.boundingBox.max * self.upVector// * self.scale.y
    }
    
    var front: RMXVector {
        return self.boundingBox.max * self.forwardVector// * self.scale.z
    }
    
    var back: RMXVector {
        return self.boundingBox.min * self.forwardVector// * self.scale.z
    }
    
    var left: RMXVector {
        return self.boundingBox.min * self.leftVector// * self.scale.x
    }
    
    var right: RMXVector {
        return self.boundingBox.max * self.leftVector// * self.scale.x
    }
    

    private var _maxSquat: RMFloat = 0
    
    var startingPoint: RMXVector3 = RMXVector3Zero
    var x,y,z: RMFloat?
    
    
    


    
    
    var isActiveSprite: Bool {
        return self.rmxID == self.world.activeSprite.rmxID
    }
    
    
    
    

    ///Set automated rotation (used mainly for the sun)
    ///@todo create a behavior protocal/class instead of fun pointers.
    var rAxis = RMXVector3Make(0,0,1)
    

    
    var isInWorld: Bool {
        return RMFloat(self.position.length) < self.world.radius
    }
    
    
    var jumpStrength: RMFloat = 1
    var squatLevel:RMFloat = 0
    private var _prepairingToJump: Bool = false
    private var _goingUp:Bool = false
    private var _ignoreNextJump:Bool = false

    
    private var _itemInHand: RMXSprite?
    var item: RMXSprite? {
        return _itemInHand
    }
    
    var itemPosition: RMXVector3 = RMXVector3Zero
    
    convenience init(world: RMSWorld, type: RMXSpriteType = .ABSTRACT, shape: ShapeType = .NULL){
        self.init(inWorld: world, type: type, shape: shape)
    }

    convenience init(inWorld world: RMSWorld, type: RMXSpriteType = .PASSIVE, shape: ShapeType = .CUBE, color: RMColor? = RMXArt.randomNSColor(), unique: Bool = false) {
        self.init(inWorld: world, geometry: RMXModels.getNode(shapeType: shape, color: color), type: type, shape: shape, unique: unique)
    }
    
    deinit {
        self.holder?.releaseItem()
        self.releaseItem()
        self.tracker.abort()
        self.aiDelegate = nil
        self.node.removeCollisionActions()
        self.followers.removeAll(keepCapacity: false)
        self.attributes = nil
        self.node.removeFromParentNode()
        
    }
    var arm: SCNNode
    init(inWorld world: RMSWorld, geometry node: SCNNode? = nil, type: RMXSpriteType, shape: ShapeType = .CUBE, unique: Bool){
        self._world = world
        self.type = type
        self.shapeType = shape
        self.isUnique = unique
        self.geometryNode = node
        self.arm = RMXModels.getNode(shapeType: .SPHERE, radius: 2)
        self._rmxNode = RMXNode(sprite: self)
        self.attributes = SpriteAttributes(self)
        self.spriteDidInitialize()
    }
    
    func setNode(node: RMXNode){
        self._rmxNode = node
        self.setName()
    }
    

    var hasItem: Bool {
        return self.item != nil
    }
    
    private var _spriteLogic: [AiBehaviour] = []
    var spriteLogic: [AiBehaviour] {
        return _spriteLogic
    }
    
    func setSpeed(speed: RMFloat? = nil, rotationSpeed: RMFloat? = nil) {
        
        if speed == nil && rotationSpeed == nil {
            switch self.type {
            case .PLAYER, .AI, .PASSIVE:
                self._spriteLogic.append(self.tracker.headToTarget)
                break
            case .PLAYER, .AI:
                self._spriteLogic.append(self.manipulate)
                self.physicsBody?.damping = 0.5
                self.physicsBody?.angularDamping = 0.99
            case .PASSIVE:
                self.physicsBody?.damping = 0.5
                self.physicsBody?.angularDamping = 0.5
                break
            case .BACKGROUND:
                self.physicsBody?.restitution = 0.1
                self.physicsBody?.damping = 1000
                self.physicsBody?.angularDamping = 1000
                break
            case .PASSIVE, .BACKGROUND, .ABSTRACT:
                self.attributes.setTeamID("\(-1)")
                break
            default:
                break
            }
        }
        
        if let speed = speed {
            _speed = speed
        } else {
            _speed = 150 * (self.mass + 1) /// (1 - damping)
        }
        
        if let rSpeed = rotationSpeed {
            _rotationSpeed = rSpeed
        } else {
            _rotationSpeed = 15 * (self.mass + 1) /// (1 - rDamping)
        }

    }
    
    func validate() {
        if !self.world.validate(self) {
            //                NSLog("reset \(sprite.name)")
            let lim = Int(self.world.radius / 2)
            self.setPosition(position: RMXVector3Random(lim, -lim), resetTransform: true)
            self.releaseItem()
        }
    }
    
    var willCollide: Bool {
        return self.attributes.teamID != "-2"
    }
    
    @availability(*,deprecated=1)
    var hasFollowers: Bool {
        return false// followers.count > 0
    }
    
    @availability(*,deprecated=1)
    var followers: [ Int: RMXSprite ] = Dictionary<Int,RMXSprite>()
    
    @availability(*,deprecated=1)
    func follow(sprite: RMXSprite?){
        sprite?.followers[self.rmxID!] = self
    }
    @availability(*,deprecated=1)
    func stopFollowing(sprite: RMXSprite?) {
        sprite?.followers.removeValueForKey(self.rmxID!)
    }
    
    static let NO_COLLISIONS: String = "-2"
    static let TEAM_ASSIGNABLE: String = "0"
    static let TEAMLESS_MAVERICS: String = "-1"
    
    var requiresAI: Bool {
        return self.isPlayerOrAi || self.type == .PASSIVE
    }
    
    func spriteDidInitialize(){
        if self.isPlayerOrAi {
            self.addCameras()
        }
        if self.aiDelegate == nil && self.requiresAI {
            self.aiDelegate = RMXAi(sprite: self)
        }
//        RMXBrain.giveBrainTo(self)
        self.setName()
        self.setSpeed()
//        NSLog(self.speed.toData())
        self.world.insertChild(self, andNode: true)
        self.timer.activate()
        if type != .PLAYER && type != .AI {
            self.attributes.setTeamID(RMXSprite.NO_COLLISIONS)
        } else {
            self.attributes.setTeamID(RMXSprite.TEAM_ASSIGNABLE)
        }
        self.arm.physicsBody = SCNPhysicsBody.staticBody()
        self.arm.position = self.front
        self.node.addChildNode(self.arm)
        
    }
    
    func toggleGravity() {
       /// self.hasGravity = !self.hasGravity
        RMLog("Unimplemented")
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
    
//    var acceleration: RMXVector3?// = RMXVector3Zero
    private let _zNorm = 90 * PI_OVER_180
    

    
    func runActions(name: String, actions: (SCNNode!) -> Void ...) {
        var count = 0
        for action in actions {
            action(nil)
//            self.rmxNode.runAction(SCNAction.runBlock(action), forKey: "\(name)\(++count)")//.runBlock({ (node: RMXNode!) -> Void in
        }
        
    }
//    internal func headToTarget(node: SCNNode! = nil) -> Void {
//        self.tracker.headToTarget()
//    }
    

    

    func debug(_ yes: Bool = true){
        if yes {
            let transform = self.transform
            if self.isActiveSprite { RMLog("\nTRANSFORM:\n\(transform.print),\n   POV: \(self.viewPoint.print)") }
           
        
            if self.isActiveSprite { RMLog("\n\n   LFT: \(self.leftVector.print),\n    UP: \(self.upVector.print)\n   FWD: \(self.forwardVector.print)\n\n") }
        }
    }
  
    
    var cameras: Array<SCNNode> = Array<SCNNode>()
//    var cameraNumber: Int = 0

    
    func initPosition(startingPoint point: RMXVector3){
        func set(inout value: RMFloat?, new: RMFloat) -> RMFloat {
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
        //self.rmxNode.position = startingPoint
        
        
    }
    
    var isPlayerOrAi: Bool {
        return self.type == RMXSpriteType.PLAYER || self.type == RMXSpriteType.AI
    }
    
   

    var mass: RMFloat {
        if let body = self.physicsBody {
            return RMFloat(body.mass)
        } else {
            return 0
        }
    }
    
    func asPlayer() -> RMXSprite {
//        self.type = .PLAYER

        if let body = self.physicsBody {
//           body.rollingFriction = 1000//0.99
            body.angularDamping = 0.99
            body.damping = 0.5
            body.friction = 0.1
        } else {
            fatalError("Should already have physics body")
        }
        
        self.setSpeed()
        return self
    }
    
//    func addCamera(cameraNode: RMXNode){
//        self.cameras.append(cameraNode)
//    }

    internal func addCameras() {
        if self.cameras.count == 0 {
            if self.type == .PLAYER {
                RMXCamera.followCam(self, option: CameraOptions.FIXED)
                RMXCamera.headcam(self)
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
//        _useWorldCoordinates = !self.world.activeCamera.isPOV
//    }
    

    
    ///Used when checkin whether or not to use local or global coordinates when controlling
    var isActiveCamera: Bool {
        return self.world.activeCamera.rmxID == self.rmxID
    }
    
    private var _isTargetable: Bool?
    
    var isTargetable: Bool {
        return _isTargetable ?? ( self.type != .BACKGROUND && self.type != .ABSTRACT )
    }

    ///object as Node: thrown in direction of node
    ///object as Sprite: thrown and tracked to sprite
    ///object as position: thown in direction
    func throwItem(atObject object: AnyObject?, withForce strength: RMFloat, tracking: Bool) -> Bool {
        if let sprite = object as? RMXSprite {
            if !sprite.isTargetable {
                RMLog(" Sprite: \(sprite.name!) is not trackable", sender: self, id: "THROW")
                return false
            }
            if tracking {
                RMLog("SPRITE -> SPRITE: \(sprite.name!)", sender: self, id: "THROW")//, sender: self)
                return self.throwItem(atSprite: sprite, withForce: strength)
            } else {
                RMLog("NODE -> Position: \(node.position.print)", sender: self, id: "THROW")//, sender: self)
                return self.throwItem(atPosition: node.position, withForce: strength)
            }
        } else if let node = object as? SCNNode {
            if !(node.sprite?.isTargetable ?? true){
                RMLog(" Sprite: \(node.sprite!.name!) is not trackable", sender: self, id: "THROW")
                return false
            }
            if tracking {
                RMLog("NODE -> Sprite: \(node.sprite!.name!)", sender: self, id: "THROW")//, sender: self)
                return self.throwItem(atObject: node.sprite, withForce: strength, tracking: tracking)
            } else {
                RMLog("NODE -> Position: \(node.position)", sender: self, id: "THROW")//, sender: self)
                return self.throwItem(atPosition: node.position, withForce: strength)
            }
        } else if let position = object as? SCNVector3 {
            RMLog("VECTOR -> Position: \(position.print)", sender: self, id: "THROW")
            return self.throwItem(atPosition: position, withForce: strength)
        } else {
            RMLog("UNKNOWN Object: \(object?.description)", sender: self, id: "THROW")//, sender: self)
            return self.throwItem(force: strength)
        }
    }
    
    private func throwItem(atSprite sprite: RMXSprite?, withForce strength: RMFloat = 1) -> Bool{
        if let itemInHand = self.item {
            if let sprite = sprite {
                if sprite == self || sprite == itemInHand {
                    return false
                }
                RMLog("Item thrown at sprite (force: \(strength.print))", sender: self, id: "THROW")
                self.releaseItem()
                itemInHand.tracker.setTarget(sprite, speed: strength, ignoreClaims: true, asProjectile: true, impulse: true, willJump: false, doOnArrival: { (target) -> () in
                    RMXTeam.challenge(self.attributes, defender: target!.attributes, doOnWin: nil)
                })
                RMXTeam.throwChallenge(self, projectile: itemInHand)
                
            } else {
                 RMLog(" *Item thrown at sprite (force: \(strength.print)) but nothing to throw", sender: self, id: "THROW")
            }
        } else {
            RMLog("Nothing to throw",sender: sprite, id: SPRITE_TYPE)
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
            var direction = self.forwardVector
            if self.isActiveCamera {
                let gradient = -self.world.activeCamera.eulerAngles.x
                let mat = GLKMatrix4MakeRotation(Float(gradient), Float(1.0), 0.0, 0.0)
                direction = SCNVector3FromGLKVector3( GLKMatrix4MultiplyVector3WithTranslation(mat, SCNVector3ToGLKVector3( direction)))
            }
            self.releaseItem()
            RMXTeam.throwChallenge(self, projectile: itemInHand)
            let force = RMFloat((itemInHand.physicsBody?.damping ?? 0.1 ) + 1) * itemInHand.mass * ( strength < 150 ? 150 : strength )
            itemInHand.applyForce(direction * force, impulse: true)
        } else {
            RMLog(" *Item thrown with force but nothing to throw: \(strength.print)", sender: self, id: "THROW")
        }
        return self.item == nil
        
    }
    
    func throwItem(atPosition target: SCNVector3?, withForce strength: RMFloat) -> Bool {
        if let target = target {
            if let itemInHand = self.item {
                let direction = (target - self.position)//.normalised
                self.releaseItem()
                RMXTeam.throwChallenge(self, projectile: itemInHand)
                let force = RMFloat((itemInHand.physicsBody?.damping ?? 0.1 ) + 1) * strength * itemInHand.mass //* ( strength < 150 ? 150 : strength )
                itemInHand.applyForce( direction * force, impulse: true)
                RMLog("Throw Item thrown from: \(itemInHand.position.print) to \(target.print)", sender: self, id: "THROW")
                RMLog("          in Direction: \(direction.print))", sender: self, id: "THROW")
                RMLog("            with force: \((direction * force).print))", sender: self, id: "THROW")
            } else {
                RMLog(" *Item thrown in direction: \(target.print) but Nothing to throw", sender: self, id: "THROW")
            }
        }
        return self.item == nil
    }
    
    
    func printBounds() {
        var min = RMXVector3Zero
        var max = min
        self.node.getBoundingBoxMin(&min, max: &max)
        let radius = RMXVector3Length(max)
        RMLog("\(self.name) pos: \(self.position.print), R: \(radius.toData()), boxMin: \(min.print), boxMax: \(max.print)")
    }
    
//    @availability(*,deprecated=0,message="Not applicable to dynamic bodies")
    func manipulate(node: SCNNode! = nil) -> Void {
        if self.hasItem && self.item?.physicsBody?.type != .Dynamic {
            var newPos = self.position + self.forwardVector * (self.length / 2 + self.item!.radius)
            if let earth = self.world.earth {
                let minHeight:RMFloat = earth.top.y + earth.position.y + self.item!.radius
                if self.world.hasGravity && newPos.y < minHeight {
                    newPos.y = minHeight
                }
            }
            self.item!.setPosition(position: newPos)//, resetTransform: false)
            RMLog("\(self.name!) is holding a non-dynamic body", sender: self, id: "MISC")
        }
    }
    
    private var _arm: SCNPhysicsBehavior?
    
    func setMass(mass: RMFloat? = nil) {
//        self.physicsBody?.friction = mass != nil ? 0 : 0.2
        self.physicsBody?.mass = CGFloat(mass ?? 4 * PI * self.radius * self.radius)
    }
    
    var isLocked: Bool = false
    private func setItem(item itemIn: RMXSprite?) -> Bool {
        if let itemIncoming = itemIn {
            if itemIncoming.rmxID == self.rmxID || self.hasItem  || itemIncoming.isLocked { return false } else { itemIncoming.isLocked = true }
            if  itemIncoming.isActiveSprite && !self.canGrabPlayers {  RMLog("\(__FUNCTION__)- cant grab \(itemIncoming.name)", id: "THROW") ;return false  } //Prevent accidentily holding oneself
            if self.isWithinReachOf(itemIncoming) {
                itemIncoming.node.removeCollisionActions()
                _itemInHand = itemIncoming
                itemIncoming.followers.removeAll(keepCapacity: false) ///TODO: this may not be necessary
                itemIncoming.holder = self
                if itemIncoming.isPlayerOrAi {
                    itemIncoming.physicsBody?.type = .Static
                } else {
                    itemIncoming.setMass(mass: 1)
                    _arm = SCNPhysicsBallSocketJoint(bodyA: self.physicsBody, anchorA: self.arm.position, bodyB: itemIncoming.physicsBody, anchorB: itemIncoming.arm.position) //+ RMXVector3Make(item.arm.radius))
                    itemIncoming.physicsBody?.restitution = 0
                    self.scene?.physicsWorld.addBehavior(_arm)
                }
                //joint
                return true
            } else {
                if itemIncoming.type == .PASSIVE || (self.isActiveSprite && itemIncoming.isPlayerOrAi ) { ///active player can grab anything for now
                    itemIncoming.tracker.setTarget(self, willJump: false, asProjectile: true, impulse: true, doOnArrival: { (target) -> () in// speed: 10 * item.mass
                        self.setItem(item: itemIncoming)
//                        item.tracker.removeTarget()
                    })
                    itemIncoming.isLocked = false
                    return true
                }
                return false
            }
        } else if let itemInHand = self._itemInHand {
            if itemInHand.isPlayerOrAi {
                itemInHand.physicsBody?.type = .Dynamic
            } else {
                self.scene?.physicsWorld.removeBehavior(_arm)
                itemInHand.setMass()
                itemInHand.physicsBody?.restitution = 0.5
                _arm = nil
            }
            itemInHand.holder = nil
            itemInHand.followers.removeAll(keepCapacity: false)
            itemInHand.isLocked = false
            self._itemInHand = nil
            return true
        }
        else {
            return false
        }
    }
    
    
    func isWithinReachOf(item: RMXSprite) -> Bool{
        return self.distanceTo(item) <= self.armLength * 3
    }
    
    func grab(object: AnyObject?) -> Bool {
        if self.item != nil { return false }
        if object?.isKindOfClass(SCNNode) ?? false {
            return self.grab((object as! SCNNode).sprite)
        } else if let sprite = object as? RMXSprite {
            return self.grab(sprite)
        }
        return self.item != nil
    }
    
    ///returns true if item is now held (even if it is not a new item)
    func grab(item: RMXSprite?) -> Bool {
        return setItem(item: item)
    }
    
    func releaseItem() {
        self.setItem(item: nil)
    }
    
    
    var boundingSphere: (center: RMXVector3, radius: RMFloat) {
        var center: SCNVector3 = SCNVector3Zero
        var radius: CGFloat = 0
        self.node.getBoundingSphereCenter(&center, radius: &radius)
        return (center, RMFloat(radius))
    }
    
    var boundingBox: (min: RMXVector, max: RMXVector) {
        var min: SCNVector3 = SCNVector3Zero
        var max: SCNVector3 = SCNVector3Zero
        self.node.getBoundingBoxMin(&min, max: &max)
        return (min, max)
    }
    
    internal var geometryNode: SCNNode?

    private var _jumpStrength: RMFloat {
        return fabs(RMFloat(self.weight) * self.jumpStrength)// * self.squatLevel/_maxSquat)
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
    
    
    func setAngle(yaw: RMFloat? = nil, pitch: RMFloat? = nil, roll r: RMFloat? = nil) {
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
    
    @availability(*,deprecated=0,message="Use rotate:theta:phi:roll instead")
    func lookAround(theta t: RMFloat? = nil, phi p: RMFloat? = nil, roll r: RMFloat? = nil) {
        self.rotate(theta: t, phi: p, roll: r)
    }
    
    func rotate(theta t: RMFloat? = nil, phi p: RMFloat? = nil, roll r: RMFloat? = nil) {
        
        if let theta = t {
            let axis = self.transform.up
            let speed = self.rotationSpeed * theta
            self.physicsBody?.applyTorque(SCNVector4Make(axis.x,axis.y,axis.z, -speed), impulse: false)
        }
        if let phi = p {
            let axis = self.transform.left
            let speed = self.rotationSpeed * phi
            self.physicsBody?.applyTorque(SCNVector4Make(axis.x,axis.y,axis.z, speed), impulse: false)
        }
        if let roll = r {
            let axis = self.transform.forward
            let speed = self.rotationSpeed * roll
            self.physicsBody?.applyTorque(SCNVector4Make(axis.x,axis.y,axis.z, -speed), impulse: false)
            //            self.rmxNode.transform *= RMXMatrix4MakeRotation(speed * 0.0001, RMXVector3Make(0,0,1))
        }
        
    }

    
    
    var isPOV: Bool {
        return self.isActiveSprite && self.world.activeCamera.isPointOfView
    }
    
    
    
    func accelerate(left: RMFloat? = nil, up: RMFloat? = nil, forward: RMFloat? = nil) {
        if let left = left {
            self.accelerateLeft(left)
        }
        if let up = up {
            self.accelerateUp(up)
        }
        if let forward = forward {
            self.accelerateForward(forward)
        }
    }
    
    private func accelerateForward(v: RMFloat) {
        if !self.isPOV {
            self.applyForce(self.world.forwardVector * v * self.speed, atPosition: self.front)
        } else {
            self.applyForce(self.forwardVector * v * self.speed)
        }
    }
    
    private func accelerateUp(v: RMFloat) {
        if !self.isPOV {
            self.applyForce(self.world.upVector * v * self.speed, atPosition: self.front)
        } else {
            self.applyForce(self.upVector * v * self.speed)
        }
    }
    
    
    private func accelerateLeft(v: RMFloat) {
        if !self.isPOV {
            self.applyForce(self.world.leftVector * v * self.speed, atPosition: self.front)
        } else {
            self.applyForce(self.leftVector * v * self.speed)
        }
    }
    
    
    func completeStop(){
        self.stop()
        self.physicsBody?.velocity = RMXVector3Zero
    }
    
    
    ///Stops all acceleration foces, not velocity
    func stop(){
        self.physicsBody?.clearAllForces()
        //        self.acceleration = nil
    }
    
    var weight: CGFloat {
        return self.physicsBody!.mass * CGFloat(self.world.gravity.length * 2)
    }
    
    func distanceTo(point: RMXVector3) -> RMFloat{
        return RMFloat((self.position - point).length)
    }
    
    func distanceTo(object:RMXSprite) -> RMFloat{
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
        if resetTransform {
            self.resetTransform()
        }
    }
    
    @availability(*,deprecated=0)
    class func rootNode(node: SCNNode, rootNode: SCNNode) -> SCNNode {
        if node.parentNode == rootNode || node.parentNode == nil {
            RMLog("RootNode: \(node.name)")
            return node
        } else {
            RMLog(sender: node.parentNode)
            return self.rootNode(node.parentNode!, rootNode: rootNode)
        }
    }

    func addBehaviour(behaviour: AiBehaviour) {
        self._spriteLogic.append(behaviour)
        if self.aiDelegate == nil {
            self.aiDelegate = RMXAi(sprite: self)
        }
    }
    
    
    var viewPoint: RMXPoint {
        return self.position - self.forwardVector
    }
    
    
    
    
    var isGrounded: Bool {
        return self.velocity.y == 0 && self.world.hasGravity
    }
    
    var upThrust: RMFloat {
        return self.physicsBody?.velocity.y ?? 0
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
        
}
    
extension RMXSprite {
    
    
    func setColor(#color: NSColor){
        
        self.geometry?.firstMaterial!.diffuse.contents = color
        self.geometry?.firstMaterial!.diffuse.intensity = 1
        self.geometry?.firstMaterial!.specular.contents = color
        self.geometry?.firstMaterial!.specular.intensity = 1
        self.geometry?.firstMaterial!.ambient.contents = color
        self.geometry?.firstMaterial!.ambient.intensity = 1
        self.geometry?.firstMaterial!.transparent.intensity = 0
        
    }
    
    func makeAsSun(rDist: RMFloat = 1000, rAxis: RMXVector3 = RMXVector3Make(1,0,0)) -> RMXSprite {
        //        self.type = .BACKGROUND
        
        
        
        self.setSpeed(rotationSpeed: 1 * PI_OVER_180 / 10)
        
        
        
        self.rAxis = rAxis
        self.node.pivot.m43 = -rDist
        
        
        return self
    }
    
    
}






extension RMXSprite : RMXLocatable {
    
    func getPosition() -> SCNVector3 {
        return self.position
    }
}
