//
//  AiCubo Basic.swift
//  AiScene
//
//  Created by Max Bilbow on 23/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import SceneKit



class AiCubo {
    enum Type { case TEST, EMPTY, SOCCER, POOL, DOMED, IN_GLOBE }
    
    class func basicPlayer(world: RMSWorld) -> RMXSprite {
        //Set up player
        let player = self.simpleSprite(world, sprite: world.activeSprite, type: .PLAYER)
        world.cameras += player.cameras
        world.activeSprite = player
        self.addTrailingCamera(to: player)
        return player
    }
    
    class func setUpWorld(interface: RMXInterface?, type: Type = .EMPTY, backupWorld: Bool = false){
        if let interface = interface {
            if let world = interface.world {
                world.deleteWorld(backup: backupWorld)
                //SetUpEnvironment
                switch type {
                case .EMPTY:
                    self.basicPlayer(world)
                    if world.hasGravity {
                        world.toggleGravity()
                    }
                    let poppy = RMX.makePoppy(world: world, master: world.activeSprite!)
                    RMXArt.initializeTestingEnvironment(world,withAxis: false, withCubes: 1, radius: world.radius / 2)
                    
                    break
                case .TEST:
                    _testingEnvironment(interface)
                    break
                case .DOMED:
                    _domedEnvironment(interface)
                    break
                case .IN_GLOBE:
                    _insideGlobe(interface)
                    break
                default:
                    _testingEnvironment(interface)
                    break
                }
                let ambientLightNode = SCNNode()
                ambientLightNode.light = SCNLight()
                ambientLightNode.light!.type = SCNLightTypeAmbient
                ambientLightNode.light!.color = NSColor.darkGrayColor()
                world.scene.rootNode.addChildNode(ambientLightNode)
                interface.gameView!.scene = world.scene
                interface.gameView.pointOfView = world.activeCamera

            } else {
                fatalError("World not initialised")
            }
        } else {
            fatalError("inteface not initialised")
        }
        
        
    }
    
    class func simpleSprite(world: RMSWorld, sprite: RMXSprite? = nil, type: RMXSpriteType = .PASSIVE) -> RMXSprite {
        let player = sprite ?? RMXSprite.new(parent: world, node: RMXModels.getNode(shapeType: ShapeType.BOBBLE_MAN.rawValue, radius: 5, color: RMXArt.randomNSColor(), mode: type), type: type, isUnique: false).asPlayerOrAI()
        player.setPosition(position: RMXVector3Random(max: 50, min: -50))//(0, 50, 50))//, resetTransform: <#Bool#>

        if let head = player.node.childNodeWithName("head", recursively: false) {
            player.cameras.append(head)
        }
        
        RMXAi.autoStablise(player)

        
        
        return player
    }
    
    class func addTrailingCamera(to sprite: RMXSprite) {
        if let followCam: RMXNode = sprite.cameras.first?.clone() as? RMXNode {
            let followSprite = RMXSprite.new(parent: sprite.world!, node: followCam, type: .PASSIVE, isUnique: true)
            followSprite.addBehaviour({ (isOn) -> () in
                followSprite.node.position = sprite.position
            })
            sprite.world?.cameras.append(followCam)
        }
    }
    
    internal class func _soccerGame(interface: RMXInterface) {
        if let world = interface.world {
            
        }
    }
    
    internal class func _insideGlobe(interface: RMXInterface) {
        if let world = interface.world {
            _testingEnvironment(interface)
            let earth = world.scene.rootNode.childNodeWithName("Earth", recursively: true)!
            let globe = RMXSprite.new(parent: world, node: RMXModels.getNode(shapeType: ShapeType.SPHERE.rawValue, mode: .BACKGROUND, radius: RMSWorld.RADIUS * 10, color: NSColor.yellowColor()), type: .BACKGROUND, isUnique: true)
            globe.node.geometry!.firstMaterial?.doubleSided = true
            if let gNode: SCNSphere = globe.node.geometry as? SCNSphere {
                gNode.geodesic = true
                
            }
            world.scene.rootNode.replaceChildNode(earth, with: globe.node)
            for child in world.children {
                if child.rmxID != globe.rmxID {
                    child.node.removeFromParentNode()
                    globe.node.addChildNode(child.node)//TODO: fix it
                }
            }
            
            world.toggleGravity()
        }
        
    }
    
    internal class func _domedEnvironment(interface: RMXInterface) {
        _testingEnvironment(interface)
        
    }
    
    internal class func _testingEnvironment(interface: RMXInterface){
        if let world = interface.world {
            let player = self.basicPlayer(world)
            
            //Set Up Player 2
            let p2 = self.simpleSprite(world)
            world.cameras += p2.cameras
            
            //Set up Poppy
            let poppy = RMX.makePoppy(world: world, master: player)
            //            world.players["Poppy"] =
            
            //Set up background
            let worldRadius = RMSWorld.RADIUS * 10
            
            let sun: RMXSprite = RMXSprite.new(parent: world, type: .BACKGROUND, isUnique: true).makeAsSun(rDist: worldRadius)
            sun.addBehaviour { (isOn) -> () in
                sun.node.transform *= RMXMatrix4MakeRotation( -sun.rotationSpeed,  sun.rAxis)
            }
            let lightNode = RMXModels.getNode(shapeType: ShapeType.SPHERE.rawValue, mode: .ABSTRACT, radius: 100)
            lightNode.light = SCNLight()
            lightNode.light!.type = SCNLightTypeOmni
            lightNode.geometry?.firstMaterial!.emission.contents = NSColor.whiteColor()
            lightNode.geometry?.firstMaterial!.emission.intensity = 1
            sun.node.addChildNode(lightNode)
            
            
            let earth: RMXSprite = RMXSprite.new(parent: world, node: RMXModels.getNode(shapeType: ShapeType.FLOOR.rawValue, mode: .BACKGROUND, radius: worldRadius, color: NSColor.yellowColor()), type: .BACKGROUND, isUnique: true)
            
            world.scene.physicsWorld.gravity = RMXVector3Make(0,-9.8 * 10,0)
            
            //            earth.physicsField = SCNPhysicsField.radialGravityField()
            
            //            earth.physicsField!.categoryBitMask = Int(SCNPhysicsCollisionCategory.Default.rawValue)
            
            earth.setName(name: "Earth")
//            earth.node.name = "Earth"
            let earthPosition = RMXVector3Make(0,-worldRadius / 2, 0)
            earth.setPosition(position: RMXVector3Make(0,-worldRadius / 2, 0))
            earth.node.runAction(SCNAction.repeatActionForever(SCNAction.moveTo(earthPosition, duration: 1)))
            
            
            // retrieve the ship node
            if let node = world.scene.rootNode.childNodeWithName("ship", recursively: true) {
                let ship = RMXSprite.new(parent: world, node: node, type: .AI, isUnique: true)
                node.physicsBody = SCNPhysicsBody.dynamicBody()
                node.physicsBody!.mass = 0.1
                //TODO make ship fly
            }
            
            
            RMXArt.initializeTestingEnvironment(world,withAxis: true, withCubes: 200, radius: earth.radius / 2)
            
            //cameras
            let sunCam: RMXNode = RMXNode()
            world.scene.rootNode.addChildNode(sunCam)
            
            sunCam.camera = RMX.standardCamera()
            sunCam.position = RMXVector3Make(0 , 100, RMSWorld.RADIUS)
            sun.cameras.append(sunCam)
            //            poppy.addCamera()
            
            world.cameras += poppy.cameras //.addCamera(poppy.cameraNode)//.node)
            world.cameras += earth.cameras
            world.cameras += sun.cameras
            
            let topCam: RMXNode = RMXNode()
            topCam.pivot.m43 = RMSWorld.RADIUS * -5
            topCam.eulerAngles.x = -90 * PI_OVER_180
            topCam.camera = RMX.standardCamera()
            world.cameras.append(topCam)
            world.aiOn = true
        }
        
    }
    
    
    

}