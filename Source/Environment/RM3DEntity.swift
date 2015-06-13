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




@available(OSX 10.10, *)
extension SCNPhysicsContact {
    func getDefender(forChallenger challenger: RMXSprite) -> SCNNode {
        return self.nodeA == challenger ? nodeB : nodeA
    }
}
//@available(OSX 10.10, *)
typealias RMXSprite = RMXNode
/*
@available(OSX 10.10, *)
class RM333d : RMXNode, RMXTeamMember, RMXPawn {
    
    lazy var tracker: RMXTracker = RMXTracker(sprite: self)

    private var _rmxNode: RMXNode!
    
    var rootNode: NSObject? {
        return _rmxNode
    }
    var node: RMXNode {
        return self._rmxNode
    }
    
    override var uniqueID: String? {
        return "\(self._name)/\(self.rmxID!)"
    }
    
    override var print: String {
        return self.uniqueID!
    }
    
    var holder: RMXSprite?
    
    @available(*,deprecated=1)
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
    
    var scene: RMXScene {
        return self._world//.scene
    }
    var radius: RMFloat {
        
       // let radius = SCNVector3Length(self.boundingBox.max * self.scale)
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
    
    private var _world: RMXScene
    
    var world: RMXWorld {
        return _world
    }
    
   
    
    
    var type: RMXSpriteType
//    var wasJustThrown:Bool = false
    var anchor = SCNVector3Zero


    

    
    lazy var timer: RMXTimer? = RMXSpriteTimer(sprite: self)
    
    var name: String? {
        return self.uniqueID!
    }
    
//    var centerOfView: RMXPoint {
//        return self.position + self.forwardVector// * self.actions.reach
//    }
    
    private var _name: String = ""
    
    
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

    
    func setName(name: String? = nil) {
        let oldName = self.name
        self._name = name != nil && !name!.isEmpty ? name! : "Ent"
        self.node.name = self._name
        _updateName(ofNode: self.node, oldName: oldName)
//        NSLog("\(self.name) -- \(self.rmxNode.name!)")
        
    }


    func setAltitude(y: RMFloat, resetTransform: Bool = true) {
        self.node.position.y = y
        if resetTransform {
            self.resetTransform()
        }
    }
    
//    func isHolding(id: Int) -> Bool{
//        return self.item?.rmxID == id
//    }
//    
//    func isHoldingSprite(sprite: RMXSprite?) -> Bool{
//        return self.item?.rmxID == item?.rmxID
//    }
//    
//    func isHolding(node: SCNNode?) -> Bool{
//        return self.item?.rmxID == node?.rmxID
//    }
//    
//    
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
    

    private var _maxSquat: RMFloat = 0
    
    var startingPoint: SCNVector3 = SCNVector3Zero
    var x,y,z: RMFloat?
    
    
    


    
    
    var isActiveSprite: Bool {
        return self.rmxID == self.scene.activeSprite.rmxID
    }
    
    
    
    

    ///Set automated rotation (used mainly for the sun)
    ///@todo create a behavior protocal/class instead of fun pointers.
    var rAxis = SCNVector3Make(0,0,1)
    

    
    var isInWorld: Bool {
        return RMFloat(self.position.length) < self.scene.radius
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
    
    var itemPosition: SCNVector3 = SCNVector3Zero
    
    convenience init(world: RMXScene, type: RMXSpriteType = .ABSTRACT, shape: ShapeType = .NULL){
        self.init(inWorld: world, type: type, shape: shape)
    }

    convenience init(inWorld world: RMXScene, type: RMXSpriteType = .PASSIVE, shape: ShapeType = .CUBE, color: RMColor? = RMX.randomColor(), unique: Bool = false) {
        self.init(inWorld: world, geometry: RMXModels.getNode(shapeType: shape, color: color), type: type, shape: shape, unique: unique)
    }
    
    deinit {
        self.holder?.releaseItem()
        self.releaseItem()
        self.tracker.abort()
        self.aiDelegate = nil
        self.node.removeCollisionActions()
//        self.followers.removeAll(keepCapacity: false)
        self.attributes = nil
        self.node.removeFromParentNode()
        
    }
    var arm: SCNNode?
    init(inWorld world: RMXScene, geometry node: SCNNode, type: RMXSpriteType, shape: ShapeType = .CUBE, unique: Bool){
        self._world = world
        self.type = type
        self.shapeType = shape
        self.isUnique = unique
//        self.geometryNode = node
        super.init()
        self._rmxNode = RMXNode(sprite: self)
        self._rmxNode.setGeometryNode(node)
        self.attributes = SpriteAttributes(sprite: self)
        self.spriteDidInitialize()
    }
    
    var paused: Bool {
        return self.node.paused
    }
    
    ///could cause animation failure if deRetire() does not fire
    func reinitialize() {
        self.setPosition(position)
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
            self.node.addChildNode(self.arm!)
            self.setMass()
            
            break
        case _ where self.isPlayerOrAi:
            self._spriteLogic.append(self.manipulate)
            break
        default:
            break
        }
        
        if self.isPlayerOrAi {
            self.addCameras()
        }
        if self.aiDelegate == nil && self.requiresAI {
            self.aiDelegate = RMXAi(pawn: self)
        }
        //        RMXBrain.giveBrainTo(self)
        self.setName()
        self.setSpeed()
        //        NSLog(self.speed.toData())
        self.scene.insertChild(self, andNode: true)
        
        if type != .PLAYER && type != .AI {
            self.attributes.setTeamID(RMXSprite.NO_COLLISIONS)
        } else {
            self.attributes.setTeamID(RMXSprite.TEAM_ASSIGNABLE)
        }
        
   
       
        
    }
    
    func setNode(node: RMXNode){
        self._rmxNode = node
        self.setName()
    }
    

    var hasItem: Bool {
        return self.item != nil
    }
    
    private var _spriteLogic: [AiBehaviour] = []
    var logic: [AiBehaviour] {
        return _spriteLogic
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
            case _ where !self.isPlayerOrAi:
                self.attributes.setTeamID("\(-1)")
                break
            default:
                break
            }
        }
        let damping = self.physicsBody?.damping ?? 0.1
        if let speed = speed {
            _speed = speed
        } else {
            _speed = 150 * (self.mass + 1) * RMFloat(damping) * 2
        }
        
        if let rSpeed = rotationSpeed {
            _rotationSpeed = rSpeed
        } else {
            _rotationSpeed = 15 * (self.mass + 1) // (1 - rDamping)
        }

    }
    
    func validate() {
        if self.scene.hasGravity && self.scene.earth?.position.y > self.position.y {
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
        return self.isPlayerOrAi || self.type == .PASSIVE
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
    

    
    func runActions(name: String, actions: (SCNNode!) -> Void ...) {
        for action in actions {
            action(nil)
//            self.rmxNode.runAction(SCNAction.runBlock(action), forKey: "\(name)\(++count)")//.runBlock({ (node: RMXNode!) -> Void in
        }
        
    }
//    internal func headToTarget(node: SCNNode! = nil) -> Void {
//        self.tracker.headToTarget()
//    }
    

    

    func debug(yes: Bool = true){
        if yes {
            let transform = self.transform
            if self.isActiveSprite { RMLog("\nTRANSFORM:\n\(transform.print),\n   POV: \(self.viewPoint.print)") }
           
        
            if self.isActiveSprite { RMLog("\n\n   LFT: \(self.leftVector.print),\n    UP: \(self.upVector.print)\n   FWD: \(self.forwardVector.print)\n\n") }
        }
    }
  
    
    var cameras: Array<SCNNode> = Array<SCNNode>()
//    var cameraNumber: Int = 0

    
    func initPosition(startingPoint point: SCNVector3){
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
        self.startingPoint = SCNVector3Make(self.x!,self.y!,self.z!)
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
//        _useWorldCoordinates = !self.scene.activeCamera.isPOV
//    }
    

    
    ///Used when checkin whether or not to use local or global coordinates when controlling
    var isActiveCamera: Bool {
        return self.scene.activeCamera.rmxID == self.rmxID
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
                let gradient = -self.scene.activeCamera.eulerAngles.x
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
                let direction = (target - itemInHand.position)//.normalised
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
        var min = SCNVector3Zero
        var max = min
        self.node.getBoundingBoxMin(&min, max: &max)
        let radius = max.length
        RMLog("\(self.name) pos: \(self.position.print), R: \(radius.toData()), boxMin: \(min.print), boxMax: \(max.print)")
    }
    
//    @availability(*,deprecated=0,message="Not applicable to dynamic bodies")
    func manipulate(node: AnyObject! = nil) -> Void {
        if self.hasItem && self.item?.physicsBody?.type != .Dynamic {
            var newPos = self.position + self.forwardVector * (self.length / 2 + self.item!.radius)
            if let earth = self.scene.earth {
                let minHeight:RMFloat = earth.top.y + earth.position.y + self.item!.radius
                if self.scene.hasGravity && newPos.y < minHeight {
                    newPos.y = minHeight
                }
            }
            self.item!.setPosition(newPos)//, resetTransform: false)
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
//                itemIncoming.followers.removeAll(keepCapacity: false) ///TODO: this may not be necessary
                
                //Used to make body static here
                if itemIncoming.arm != nil {
                    if !itemIncoming.isPlayerOrAi { ///reduce mass to 1% of sprite unless its another player
                        itemIncoming.setMass(self.mass * 0.01)
                        itemIncoming.physicsBody?.restitution = 0.01
                        itemIncoming.physicsBody?.friction = 0.01
                    }
                    _itemInHand = itemIncoming
                    itemIncoming.holder = self
                    _arm = SCNPhysicsBallSocketJoint(bodyA: self.physicsBody!, anchorA: self.arm!.position, bodyB: itemIncoming.physicsBody!, anchorB: itemIncoming.arm!.position) //+ SCNVector3Make(item.arm.radius))
                    
                    self.scene.physicsWorld.addBehavior(_arm!)
                }
                //joint
                return true
            } else {
                ///Player can use tractor beam function on passive objects
                itemIncoming.isLocked = false
                if (self.isActiveSprite || self.isWithinSightOf(itemIncoming)) && itemIncoming.type == .PASSIVE { // || (self.isActiveSprite && itemIncoming.isPlayerOrAi ) { ///active player can grab anything for now
                    itemIncoming.tracker.setTarget(self, willJump: false, asProjectile: true, impulse: true, doOnArrival: { (target) -> () in// speed: 10 * item.mass
                        self.setItem(item: itemIncoming)
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
            if !itemInHand.isPlayerOrAi {
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
    
    
    func isWithinReachOf(item: RMXSprite) -> Bool{
        return self.distanceToSprite(item) <= self.armLength * 3
    }
    
    func isWithinSightOf(item: RMXSprite) -> Bool{
        return self.distanceToSprite(item) <= self.scene.radius / 4
    }
    
    func grab(object: AnyObject?) -> Bool {
        if self.item != nil { return false }
        if object?.isKindOfClass(SCNNode) ?? false {
            return self.setItem(item: (object as! SCNNode).sprite)
        } else if let sprite = object as? RMXSprite {
            return self.setItem(item: sprite)
        }
        return self.item != nil
    }
    
    
    func releaseItem() {
        self.setItem(item: nil)
    }
    
    @available(OSX 10.10, *)
    var boundingSphere: (center: SCNVector3, radius: RMFloat) {
        var center: SCNVector3 = SCNVector3Zero
        var radius: CGFloat = 0
        self.node.getBoundingSphereCenter(&center, radius: &radius)
        return (center, RMFloat(radius))
    }
    
    @available(OSX 10.10, *)
    var boundingBox: (min: SCNVector3, max: SCNVector3) {
        var min: SCNVector3 = SCNVector3Zero
        var max: SCNVector3 = SCNVector3Zero
        self.node.getBoundingBoxMin(&min, max: &max)
        return (min, max)
    }
    
//    internal var geometryNode: SCNNode?

    private var _jumpStrength: RMFloat {
        return fabs(RMFloat(self.weight) * self.jumpStrength)// * self.squatLevel/_maxSquat)
    }
    
    func jump() {
        if self.position.y < self.height * 10 {
            self.applyForce(SCNVector3Make(0, y: _jumpStrength, z: 0), impulse: true)
        }
    }
    
    private class func stop(sender: RMXSprite, objects: [AnyObject]?) -> AnyObject? {
        sender.completeStop()
        return nil
    }
    
    
    func setAngle(yaw: RMFloat? = nil, pitch: RMFloat? = nil, roll r: RMFloat? = nil) {
        self.setPosition(resetTransform: false)
        if let _ = yaw {
            self.node.orientation.y = 0
        }
        if let _ = pitch {
            self.node.orientation.x = 0
        }
        if let _ = r {
            self.node.orientation.z = 0
        }
        self.resetTransform()
        
    }
    
    @available(*,deprecated=0,message="Use rotate:theta:phi:roll instead")
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
            //            self.rmxNode.transform *= RMXMatrix4MakeRotation(speed * 0.0001, SCNVector3Make(0,0,1))
        }
        
    }

    
    
    var isPOV: Bool {
        return self.isActiveSprite && self.scene.activeCamera.isPointOfView
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
        return RMFloat((self.position - point).length)
    }
    
    func distanceToSprite(sprite:RMXSprite) -> RMFloat{
        return self.distanceToPoint(sprite.position)
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
        self.node.transform = self.transform
        if let position = position {
            self.node.position = position
            if self._startingPosition == nil {
                self._startingPosition = position
            }
        }
        if resetTransform {
            self.resetTransform()
        }
    }
    
    @available(*,deprecated=0)
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
            self.aiDelegate = RMXAi(pawn: self)
        }
    }
    
    
    var viewPoint: SCNVector3 {
        return self.position - self.forwardVector
    }
    
    
    
    
    var isGrounded: Bool {
        return self.velocity.y == 0 && self.scene.hasGravity
    }
    
    var upThrust: RMFloat {
        return self.physicsBody?.velocity.y ?? 0
    }

    
    var upVector: SCNVector3 {
        return self.transform.up
    }
    
    var leftVector: SCNVector3 {
        return self.transform.left
    }
    
    var forwardVector: SCNVector3 {
        return self.transform.forward
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
    
    func makeAsSun(rDist: RMFloat = 1000, rAxis: SCNVector3 = SCNVector3Make(1,y: 0,z: 0)) -> RMXSprite {
        //        self.type = .BACKGROUND
        
        
        
        self.setSpeed(rotationSpeed: 1 * PI_OVER_180 / 10)
        
        
        
        self.rAxis = rAxis
        self.node.pivot.m43 = -rDist
        
        
        return self
    }
    
    
}





@available(OSX 10.10, *)
extension RMXSprite : RMXLocatable {
    
    func getPosition() -> SCNVector3 {
        return self.position
    }
}

*/

*/*/*/*/



