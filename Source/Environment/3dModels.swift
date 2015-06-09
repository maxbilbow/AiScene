//
//  3dModels.swift
//  AiCubo
//
//  Created by Max Bilbow on 16/04/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
import SceneKit

@available(OSX 10.10,*)
typealias RMXModels = RM3DModels



@available(OSX 10.10, *)
class RM3DModels  {
    
    

    var rock: SCNGeometry?
    var oilDrum: SCNGeometry?
//    var ausfb: SCNGeometry?
    static let pongo: AnyObject? = SCNScene(named:"art.scnassets/Pongo/other/The Limited 4.dae")?.rootNode.clone()
    static let ausfb: AnyObject? = SCNScene(named:"art.scnassets/AUSFB/ausfb.dae")?.rootNode.clone()
    static let dog: AnyObject? = SCNScene(named:"art.scnassets/Dog/Dog.dae")?.rootNode.clone()
    static let pilot: AnyObject? = SCNScene(named:"art.scnassets/ArmyPilot/ArmyPilot.dae")?.rootNode.clone()
    
    static var ship: SCNGeometry {
        let url = NSBundle.mainBundle().URLForResource("art.scnassets/ship", withExtension: "dae")
        let source = SCNSceneSource(URL: url!, options: nil)
        let block = source.entryWithIdentifier("Scrap_MeshShape", withClass: SCNGeometry.self) as SCNGeometry!
        return block
    }
    
    static let oilDrum = SCNSceneSource(
        URL: NSBundle.mainBundle().URLForResource(
            "art.scnassets/oildrum/oildrum",
            withExtension: "dae")!,options: nil
        ).entryWithIdentifier("Cylinder_001-mesh",
            withClass: SCNGeometry.self) as SCNGeometry!
    
    static let rock = SCNSceneSource(
        URL: NSBundle.mainBundle().URLForResource(
            "art.scnassets/Rock1",
            withExtension: "dae")!,options: nil
        ).entryWithIdentifier("Cube-mesh",
            withClass: SCNGeometry.self) as SCNGeometry!
    
   
    
    
   
    class func getNode(shapeType type: ShapeType, radius r: RMFloat? = nil, height h: RMFloat? = nil, scale s: RMXSize? = nil, color: RMColor! = nil) -> SCNNode {
        var hasColor = false
        var radius = r ?? 1
        var height = h ?? radius
        let scale = s ?? SCNVector3Make(radius * 2,height * 2,radius * 2)
        if r == nil {
            radius = RMFloat(scale.average)
        }
        if h == nil {
            height = scale.y
        }
        
        var node: SCNNode
        switch(type){
        case .CUBE:
            node = SCNNode(geometry: SCNBox(
                width: CGFloat(scale.x),
                height:CGFloat(scale.y),
                length:CGFloat(scale.z),
                chamferRadius:0.0)
            )
            hasColor = true
            break
        case ShapeType.SPHERE, .SUN:
            node = SCNNode(geometry: SCNSphere(radius: CGFloat(radius)))
            hasColor = true
            break
        case ShapeType.CYLINDER:
            node = SCNNode(geometry: SCNCylinder(radius: CGFloat(radius), height: CGFloat(height)))
            hasColor = true
            break
        case ShapeType.ROCK:
            node = SCNNode(geometry: rock)
            node.scale *= 1 * radius
            break
        case ShapeType.PLANE:
             hasColor = true
            node = SCNNode(geometry: SCNPlane(width: CGFloat(scale.x), height: CGFloat(scale.y)))
            break
        case ShapeType.FLOOR:
            hasColor = true
//            node = SCNFloor
            node = SCNNode(geometry: SCNCylinder(radius: CGFloat(radius), height: 100))
            //node.transform = SCNMatrix4Rotate(node.transform, 90 * PI_OVER_180, 1, 0, 0)
            //node.geometry?.firstMaterial!.doubleSided = true
            
            break
        case ShapeType.PONGO:
            node = pongo as! RMXNode
            node.scale *= 0.001 * radius
            break
        case ShapeType.SPACE_SHIP:
            node = SCNNode(geometry: ship)
            node.scale *= 2
            break
        case ShapeType.OILDRUM:
            node = SCNNode(geometry: oilDrum)
            node.scale *= 1.5 * radius
            break
        case ShapeType.DOG:
            node = dog!.rootNode.clone() as SCNNode
            node.scale *= 1 * radius
            break
        case ShapeType.AUSFB:
            node = ausfb!.rootNode.clone() as SCNNode
            node.scale *= 0.01 * radius
            break
        case ShapeType.BOBBLE_MAN:
            let r: RMFloat = 8
            node = RMXModels.getNode(shapeType: ShapeType.SPHERE, radius: r, color: color)
            let head = RMXModels.getNode(shapeType: ShapeType.SPHERE, radius: r / 2)
            head.name = "head"
            node.addChildNode(head)
            head.position = SCNVector3Make(0, 2 * r * 0.9, 0) //TODO check
            break
        case ShapeType.NULL:
            node = SCNNode()
            node.scale = scale
            break
        default:
            node = SCNNode(geometry: SCNSphere(radius: CGFloat(radius)))
            hasColor = true
        }
        
        
        if hasColor && color != nil {
            node.geometry!.firstMaterial!.diffuse.contents = color
            node.geometry!.firstMaterial!.specular.contents = color
            
        }

        
        return node
    }

    

    
}