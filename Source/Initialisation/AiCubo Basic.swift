//
//  AiCubo Basic.swift
//  AiScene
//
//  Created by Max Bilbow on 23/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import SceneKit


 enum GameType { case TEST, EMPTY, SOCCER, POOL, DOMED, IN_GLOBE, TEAM_GAME }
class AiCubo {
   
    
    
    
    class func setUpWorld(interface: RMXInterface?, type: GameType = .TEAM_GAME, backupWorld: Bool = false) -> RMSWorld {
        if let interface = interface {

            let world = RMSWorld(interface: interface) //interface.world//
        
            //SetUpEnvironment
            switch type {
            case .EMPTY:
//                self.simpleUniquePlayer(world)
                if world.hasGravity {
                    world.toggleGravity()
                }
//                let poppy = RMX.makePoppy(world: world, master: world.activeSprite)
                RMXArt.initializeTestingEnvironment(world,withAxis: true, withCubes: 10, radius: RMSWorld.RADIUS , shapes: .CYLINDER, .ROCK)
                
                break
            case .TEST:
                _testingEnvironment(interface, world: world)
                RMXArt.initializeTestingEnvironment(world,withAxis: true, withCubes: 100, radius: RMSWorld.RADIUS * 5, shapes: .BOBBLE_MAN, .CYLINDER, .CYLINDER, .CUBE, .SPHERE, .ROCK)
                for player in world.players {
                    if player.type == RMXSpriteType.AI && !player.isUnique {
                        RMXAi.addRandomMovement(to: player)
                    }
                }
                break
            case .DOMED:
                _domedEnvironment(interface, world: world)
                break
            case .IN_GLOBE:
                _insideGlobe(interface, world: world)
                break
            case .TEAM_GAME:
                _teamGame(interface, world: world)
                break
            default:
                _testingEnvironment(interface, world: world)
                break
            }
            let ambientLightNode = SCNNode()
            ambientLightNode.light = SCNLight()
            ambientLightNode.light!.type = SCNLightTypeAmbient
            ambientLightNode.light!.color = NSColor.darkGrayColor()
            world.scene.rootNode.addChildNode(ambientLightNode)
//            interface.gameView!.scene = world.scene
//            interface.gameView.pointOfView = world.activeCamera
            return world
        } else {
            fatalError("inteface not initialised")
        }
        
        
    }
    
    class func simpleUniquePlayer(world: RMSWorld) -> RMXSprite {
        //Set up player
        let player = self.simpleSprite(world, type: .PLAYER, isUnique: true)
        
        //        world.cameras += player.cameras
        
        return player
    }
    
    class func simpleSprite(world: RMSWorld, sprite: RMXSprite? = nil, type: RMXSpriteType = .PASSIVE, isUnique: Bool) -> RMXSprite {
        
        let player = sprite ?? RMXSprite.new(inWorld: world, node: RMXModels.getNode(shapeType: ShapeType.BOBBLE_MAN, radius: 6, color: RMXArt.randomNSColor(), mode: type), type: type, isUnique: isUnique).asPlayer()
        
        player.setPosition(position: RMXVector3Random(max: 50, min: -50))//(0, 50, 50))//, resetTransform: <#Bool#>

        
        
        RMXAi.autoStablise(player)

        
        
        return player
    }
    
    class func addTrailingCamera(to sprite: RMXSprite, world: RMSWorld) {
        if sprite.type == .PLAYER {
//            let followCam = RMXCamera.followCam(sprite.node, option: .FREE)
//            sprite.cameras.append(followCam)
        }
    }
    
    internal class func _soccerGame(interface: RMXInterface, world: RMSWorld) {
  
    }
    
    internal class func _insideGlobe(interface: RMXInterface, world: RMSWorld) {
        _testingEnvironment(interface, world: world)
        let earth = world.scene.rootNode.childNodeWithName("Earth", recursively: true)!
        let globe = RMXSprite.new(inWorld: world, node: RMXModels.getNode(shapeType: ShapeType.SPHERE, mode: .BACKGROUND, radius: RMSWorld.RADIUS * 20, color: NSColor.yellowColor()), type: .BACKGROUND, isUnique: true)
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
    
    internal class func _domedEnvironment(interface: RMXInterface, world: RMSWorld) {
        _testingEnvironment(interface, world: world)
        
    }
    
    internal class func _testingEnvironment(interface: RMXInterface, world: RMSWorld){
        let player = world.activeSprite
        //Set Up Player 2
        let p2 = self.simpleUniquePlayer(world)
        p2.setName(name: "Player")
        
        //Set up Poppy
        let poppy = RMX.makePoppy(world: world, master: player)
        poppy.setName(name: "Poppy")
        poppy.attributes.setTeam(ID: -1)
        //            world.players["Poppy"] =
        
        //Set up background
        let worldRadius = RMSWorld.RADIUS * 10
        
        let sun: RMXSprite = RMXSprite.new(inWorld: world, type: .BACKGROUND, isUnique: true).makeAsSun(rDist: worldRadius)
        sun.addAi({ (node: RMXNode!) -> Void in
            sun.node.transform *= RMXMatrix4MakeRotation( -sun.rotationSpeed,  sun.rAxis)
        })
        let lightNode = RMXModels.getNode(shapeType: ShapeType.SPHERE, mode: .BACKGROUND, radius: 100)
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeOmni
        lightNode.geometry?.firstMaterial!.emission.contents = NSColor.whiteColor()
        lightNode.geometry?.firstMaterial!.emission.intensity = 1
        sun.node.addChildNode(lightNode)
        
        let earth: RMXSprite = RMXSprite.new(inWorld: world, node: RMXModels.getNode(shapeType: ShapeType.FLOOR, mode: .BACKGROUND, radius: worldRadius, color: NSColor.yellowColor()), type: .BACKGROUND, isUnique: true)
    
        world.scene.physicsWorld.gravity = RMXVector3Make(0,-9.8 * 10,0)
      
        
        earth.setName(name: "Earth")
        let earthPosition = RMXVector3Make(0,-worldRadius / 2, 0)
        earth.setPosition(position: RMXVector3Make(0,-worldRadius / 2, 0))
        earth.node.runAction(SCNAction.repeatActionForever(SCNAction.moveTo(earthPosition, duration: 1)))
        

        

        
        //camera
        RMXCamera.headcam(sun)
        
        
        

//        world.cameras += player.cameras
        world.cameras += p2.cameras
        world.cameras += poppy.cameras
        world.cameras += earth.cameras
        world.cameras += sun.cameras
        
        let topCam = RMXCamera.free(inWorld: world)
        topCam.pivot.m43 = RMSWorld.RADIUS * -5
        topCam.eulerAngles.x = -70 * PI_OVER_180
//            world.cameras.append(topCam)
        
        let farCam = RMXCamera.free(inWorld: world)
        farCam.position = RMXVector3Make(0 , 100, RMSWorld.RADIUS)
//            world.cameras.append(farCam)
        
        world.aiOn = true

        
        
    }
    
    internal class func _teamGame(interface: RMXInterface, world: RMSWorld){

        _testingEnvironment(interface, world: world)
        RMXArt.initializeTestingEnvironment(world,withAxis: false, withCubes: 100, radius: RMSWorld.RADIUS * 5, shapes: .BOBBLE_MAN, .CYLINDER, .CYLINDER, .SPHERE)
        let player = world.activeSprite
        let teamA = RMXTeam(gameWorld: world, captain: player)
        player.attributes.invincible = true
        let teamB = RMXTeam(gameWorld: world)
        
        
        
        var aOrB = true
        for player in world.nonTeamPlayers {
            let team = aOrB ? teamA : teamB
            if !player.isUnique {
                team.addPlayer(player)
            }
            aOrB = !aOrB
        }
        
       
        
        for teamMate in world.teamPlayers {
            if teamMate.type == RMXSpriteType.AI && !teamMate.isUnique {
                RMXAi.offenciveBehaviour(to: teamMate)
            }
        }
        
    }

}