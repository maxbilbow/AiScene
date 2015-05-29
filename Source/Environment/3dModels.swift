//
//  3dModels.swift
//  AiCubo
//
//  Created by Max Bilbow on 16/04/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
import SceneKit

typealias RMXModels = RM3DModels

enum ShapeType: Int { case CUBE , SPHERE, CYLINDER, ROCK, OILDRUM, BOBBLE_MAN, LAST,SPACE_SHIP, PILOT,  PLANE, FLOOR, DOG, AUSFB,PONGO, NULL }

class RM3DModels : RMXModelsProtocol {
    
    #if SceneKit
    var rock: SCNGeometry?
    var oilDrum: SCNGeometry?
//    var ausfb: SCNGeometry?
    static let pongo: AnyObject? = RMXScene(named:"art.scnassets/Pongo/other/The Limited 4.dae")?.rootNode.clone()
    static let ausfb: AnyObject? = RMXScene(named:"art.scnassets/AUSFB/ausfb.dae")?.rootNode.clone()
    static let dog: AnyObject? = RMXScene(named:"art.scnassets/Dog/Dog.dae")?.rootNode.clone()
    static let pilot: AnyObject? = RMXScene(named:"art.scnassets/ArmyPilot/ArmyPilot.dae")?.rootNode.clone()
    
    static var ship: SCNGeometry {
        let url = NSBundle.mainBundle().URLForResource("art.scnassets/ship", withExtension: "dae")
        let source = SCNSceneSource(URL: url!, options: nil)
        let block = source!.entryWithIdentifier("Scrap_MeshShape", withClass: SCNGeometry.self) as! SCNGeometry
        return block
    }
    
    static let oilDrum = SCNSceneSource(
        URL: NSBundle.mainBundle().URLForResource(
            "art.scnassets/oildrum/oildrum",
            withExtension: "dae")!,options: nil
        )!.entryWithIdentifier("Cylinder_001-mesh",
            withClass: SCNGeometry.self) as! SCNGeometry
    
    static let rock = SCNSceneSource(
        URL: NSBundle.mainBundle().URLForResource(
            "art.scnassets/Rock1",
            withExtension: "dae")!,options: nil
        )!.entryWithIdentifier("Cube-mesh",
            withClass: SCNGeometry.self) as! SCNGeometry
    
   
    
    
   
    class func getNode(shapeType type: Int, mode: RMXSpriteType = .PASSIVE, radius r: RMFloatB? = nil, height h: RMFloatB? = nil, scale s: RMXSize? = nil, color: NSColor! = nil) -> RMXNode {
        var hasColor = false
        var radius = r ?? 1
        var height = h ?? radius
        var scale = s ?? SCNVector3Make(radius * 2,height * 2,radius * 2)
        if r == nil {
            radius = RMFloatB(scale.average)
        }
        if h == nil {
            height = scale.y
        }
        
        var node: RMXNode
        switch(type){
        case ShapeType.CUBE.rawValue:
            node = RMXNode(geometry: SCNBox(
                width: RMFloat(scale.x),
                height:RMFloat(scale.y),
                length:RMFloat(scale.z),
                chamferRadius:0.0)
            )
            hasColor = true
            break
        case ShapeType.SPHERE.rawValue:
            node = RMXNode(geometry: SCNSphere(radius: RMFloat(radius)))
            hasColor = true
            break
        case ShapeType.CYLINDER.rawValue:
            node = RMXNode(geometry: SCNCylinder(radius: RMFloat(radius), height: RMFloat(height)))
            hasColor = true
            break
        case ShapeType.ROCK.rawValue:
            node = RMXNode(geometry: rock)
            node.scale *= 1 * radius
            break
        case ShapeType.PLANE.rawValue:
             hasColor = true
            node = RMXNode(geometry: SCNPlane(width: RMFloat(scale.x), height: RMFloat(scale.y)))
            break
        case ShapeType.FLOOR.rawValue:
            hasColor = true
            node = RMXNode(geometry: SCNCylinder(radius: RMFloat(radius), height: RMFloat(radius)))
            //node.transform = SCNMatrix4Rotate(node.transform, 90 * PI_OVER_180, 1, 0, 0)
            //node.geometry?.firstMaterial!.doubleSided = true
            
            break
        case ShapeType.PONGO.rawValue:
            node = pongo as! RMXNode
            node.scale *= 0.001 * radius
            break
        case ShapeType.SPACE_SHIP.rawValue:
            node = RMXNode(geometry: ship)
            node.scale *= 2
            break
        case ShapeType.OILDRUM.rawValue:
            node = RMXNode(geometry: oilDrum)
            node.scale *= 1.5 * radius
            break
        case ShapeType.DOG.rawValue:
            node = dog!.rootNode.clone() as! RMXNode
            node.scale *= 1 * radius
            break
        case ShapeType.AUSFB.rawValue:
            node = ausfb!.rootNode.clone() as! RMXNode
            node.scale *= 0.01 * radius
            break
        case ShapeType.BOBBLE_MAN.rawValue:
            node = RMXModels.getNode(shapeType: ShapeType.SPHERE.rawValue, mode: mode, radius: radius, color: color)
//            let head = RMXCameraNode(geometry: SCNSphere(radius: RMFloat(radius * 0.5)))
            let head = RMXModels.getNode(shapeType: ShapeType.SPHERE.rawValue, mode: .KINEMATIC, radius: radius * 0.5)
            head.name = "head"
//            head.physicsBody = SCNPhysicsBody.kinematicBody()
//            head.physicsBody!.mass = -10
            node.addChildNode(head)
            head.position = SCNVector3Make(0, 2 * radius * 0.9, 0) //TODO check
//            radius = 0 ///to make mass zero
            break
        case ShapeType.NULL.rawValue:
            node = RMXNode()
            node.scale = scale
            break
        default:
            node = RMXNode(geometry: SCNSphere(radius: RMFloat(radius)))
            hasColor = true
        }
        
        
        if hasColor && color != nil {
            node.geometry!.firstMaterial!.diffuse.contents = color
            node.geometry!.firstMaterial!.specular.contents = color
            
        }
        
        switch (mode){
        case .AI, .PLAYER, .PASSIVE:
            node.physicsBody = SCNPhysicsBody.dynamicBody()
            node.physicsBody!.restitution = 0.1
            break
        case .BACKGROUND:
            node.physicsBody = SCNPhysicsBody.staticBody()
            node.physicsBody!.restitution = 0.1
            node.physicsBody!.damping = 1000
            node.physicsBody!.angularDamping = 1000
        case .KINEMATIC:
            node.physicsBody = SCNPhysicsBody.kinematicBody()
            node.physicsBody!.restitution = 0.1
        default:
            if node.physicsBody == nil {
                node.physicsBody = SCNPhysicsBody()//.staticBody()
                node.physicsBody!.restitution = 0.0
            }
        }
        
        if type != ShapeType.NULL.rawValue {
            node.physicsBody!.mass = 4 * CGFloat(PI * radius * radius)// * 600
        } else {
            node.physicsBody!.mass = 0
        }
        
        return node
    }
    
    
    
    
    #elseif SpriteKit
    
    #endif
    
}