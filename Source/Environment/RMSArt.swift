//
//  RMSArt.swift
//  RattleGL
//
//  Created by Max Bilbow on 11/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GLKit

    import SceneKit


@available(OSX 10.10, *)
class RMXArt {
    static let colorBronzeDiff: [Float]  = [ 0.8, 0.6, 0.0, 1.0 ]
    static let colorBronzeSpec: [Float]  = [ 1.0, 1.0, 0.4, 1.0 ]
    static let colorBlue: [RMFloat]        = [ 0.0, 0.0, 0.1, 1.0 ]
    static let colorNone: [Float]        = [ 0.0, 0.0, 0.0, 0.0 ]
    static let colorRed: [RMFloat]         = [ 0.1, 0.0, 0.0, 1.0 ]
    static let colorGreen: [RMFloat]       = [ 0.0, 0.1, 0.0, 1.0 ]
    static let colorYellow: [Float]      = [ 1.0, 0.0, 0.0, 1.0 ]
    static let nillVector: [Float]       = [ 0  ,   0,  0,  0   ]
    
    static let greenVector: GLKVector4 = GLKVector4Make(0.0, 0.1, 0.0, 1.0)
    static let yellowVector: GLKVector4 = GLKVector4Make(1.0, 1.0, 0.0, 1.0)
    static let blueVector: GLKVector4 = GLKVector4Make(0.0, 0.0, 1.0, 1.0)
    static let redVector: GLKVector4 = GLKVector4Make(1.0, 0.0, 0.0, 1.0)

    
    class func initializeTestingEnvironment(world: RMXScene, withAxis drawAxis: Bool = true, withCubes noOfShapes: RMFloat = 1000, radius: RMFloat? = nil, shapes: ShapeType ...) -> RMXScene {
        
        //RMXArt.drawPlane(world)
        if drawAxis {
            RMXArt.drawAxis(world,radius: radius ?? world.radius)
        }
        if noOfShapes > 0 {
            RMXArt.randomObjects(world, noOfShapes: noOfShapes, radius: radius, ofType: shapes)
        }
        return world
    }
    
    

    
    class func drawAxis(world: RMXScene, radius: RMFloat) {//xCol y:(float*)yCol z:(float*)zCol{
        
        
        func drawAxis(axis: String) {
            var color: RMColor
            var scale: SCNVector3 = SCNVector3Make(10)
            var position = SCNVector3Make(0, y: scale.y / 2, z: 0)
            switch axis {
            case "x":
                scale.x = radius * 2
                color = RMColor.redColor()
                break
            case "y":
                color = RMColor.greenColor()
                position.y = scale.y + radius / 2
                scale.y = radius
                break
            case "z":
                scale.z = radius * 2
                color = RMColor.blueColor()
                break
            case "z1":
                color = RMColor.blueColor()
                position.z = (radius + scale.y) / 2
                scale.z = radius
                break
            case "z2":
                color = RMColor.blueColor()
                position.z = -(radius + scale.y) / 2// -radius / 2 - scale.y
                scale.z = radius
                break

            default:
                fatalError(__FUNCTION__)
            }
            let node = RMXModels.getNode(shapeType: ShapeType.CUBE, radius: 1, scale: scale, color: color)
            
            let sprite = RMXSprite(inWorld: world, geometry: node, type: RMXSpriteType.BACKGROUND, shape: .CUBE, unique: true)
            //sprite.node.runAction(SCNAction.repeatActionForever(SCNAction.moveTo(position, duration: 10000)))
            sprite.physicsBody?.mass *= 1000
            sprite.physicsBody?.damping = 1000
            sprite.physicsBody?.angularDamping = 1000
            
            
        }

        drawAxis("x")
        drawAxis("y")
        drawAxis("z1")
        drawAxis("z2")
    }
    
    class func randomObjects(world: RMXScene, noOfShapes: RMFloat = 100, radius r: RMFloat? = nil, ofType types: [ShapeType])    {
    //int max =100, min = -100;
    //BOOL gravity = true;
        let radius = r ?? world.radius
        
        for(var i: RMFloat = -noOfShapes / 2; i < noOfShapes / 2; ++i) {
            var randPos: [RMFloat]
            var X: RMFloat = 0; var Y: RMFloat = 0; var Z: RMFloat = 0
            func thisRandom(inout x: RMFloat, inout y: RMFloat, inout z: RMFloat) -> [RMFloat] {
                func drawCondition(x:RMFloat, inout y:RMFloat, z:RMFloat) -> Bool{
                    let position = SCNVector3Make(x,y: y,z: z)
                    let distance = SCNVector3Distance(position, b: SCNVector3Zero)
                    y = RMFloat(fabs(y))
                    
                    return distance < radius
                }
                repeat {
                    let points = RMX.doASum(radius, count: i, noOfShapes: noOfShapes )
                    x = points.x
                    y = points.y
                    z = points.z
                } while drawCondition(x,y: &y,z: z)
                return [ x, y, z ]
            }
            randPos = thisRandom(&X,y: &Y,z: &Z)

            let size = RMFloat(8) //RMFloat(random() % 5 + 5)
            let scale = SCNVector3Make(size,y: size,z: size)
            let shape: ShapeType = types[random() % types.count]


            let color = RMX.randomColor()
        
            let node = RMXModels.getNode(shapeType: shape, scale: scale, color: color)
            
                
            
            
            
            
            let sprite = RMXSprite(inWorld: world, geometry: node, type: .PASSIVE, shape: .CUBE, unique: false)
            sprite.setPosition( SCNVector3Random(world.radius, min: -world.radius, setY: world.ground + 20))

                
        }
    }
    
    
    class func randomColor() -> GLKVector4 {
    //float rCol[4];
        let rCol = GLKVector4Make(
            Float(random() % 10)/10,
            Float(random() % 10)/10,
            Float(random() % 10)/10,
        1)

        return rCol
    }
    
    
}




