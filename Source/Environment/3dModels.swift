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

enum ShapeType: Int { case CUBE , SPHERE, CYLINDER, ROCK, OILDRUM , AUSFB, PONGO, LAST, PILOT,  PLANE, FLOOR, DOG, NULL }

class RM3DModels : RMXModelsProtocol {
    
    #if SceneKit
    var rock: SCNGeometry?
    var oilDrum: SCNGeometry?
//    var ausfb: SCNGeometry?
    static let pongo = RMXScene(named:"art.scnassets/Pongo/other/The Limited 4.dae")
    static let ausfb = RMXScene(named:"art.scnassets/AUSFB/ausfb.dae")
    static let dog = RMXScene(named:"art.scnassets/Dog/Dog.dae")
    static let pilot = RMXScene(named:"art.scnassets/ArmyPilot/ArmyPilot.dae")
    
   
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
            let url = NSBundle.mainBundle().URLForResource("art.scnassets/Rock1", withExtension: "dae")
            let source = SCNSceneSource(URL: url!, options: nil)
            let block = source!.entryWithIdentifier("Cube-mesh", withClass: SCNGeometry.self) as! SCNGeometry
            node = RMXNode(geometry: block)
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
            node = pongo?.rootNode.clone() as! RMXNode
            node.scale *= 0.001 * radius
            break
        case ShapeType.OILDRUM.rawValue:
            let url = NSBundle.mainBundle().URLForResource("art.scnassets/oildrum/oildrum", withExtension: "dae")
            let source = SCNSceneSource(URL: url!, options: nil)
            let block = source!.entryWithIdentifier("Cylinder_001-mesh", withClass: SCNGeometry.self) as! SCNGeometry
            node = RMXNode(geometry: block)
            node.scale *= 1 * radius
            break
        case ShapeType.DOG.rawValue:
            node = dog!.rootNode.clone() as! RMXNode
            node.scale *= 1 * radius
            break
            
        case ShapeType.AUSFB.rawValue:
            node = ausfb!.rootNode.clone() as! RMXNode
            node.scale *= 0.01 * radius
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
        case .WORLD, .BACKGROUND:
            node.physicsBody = SCNPhysicsBody.staticBody()
            node.physicsBody!.restitution = 0.0
            node.physicsBody!.damping = 1
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
            node.physicsBody!.mass = 4 *  CGFloat(PI * radius * radius)// * 600
        } else {
            node.physicsBody!.mass = 0
        }
        
        return node
    }
    
    #elseif SpriteKit
    
    #endif
    
}